#!/bin/bash
# Claude AI System Deployment Script
# Deploys autonomous multi-domain AI system with safety constraints
set -euo pipefail

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_FILE="${REPO_ROOT}/manifest.json"
DEPLOY_ROOT="${HOME}"

# Logging setup
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    log "ERROR: $*"
    exit 1
}

# Credential management with 1Password integration
get_r2_credentials() {
    local access_key=""
    local secret_key=""
    local endpoint=""
    
    # Try 1Password first
    if command -v op &> /dev/null && op account get &>/dev/null; then
        log "Attempting to retrieve R2 credentials from 1Password..."
        access_key=$(op read "op://vault/R2-Claude-System/access-key" 2>/dev/null || true)
        secret_key=$(op read "op://vault/R2-Claude-System/secret-key" 2>/dev/null || true)
        endpoint=$(op read "op://vault/R2-Claude-System/endpoint" 2>/dev/null || true)
    fi
    
    # Fall back to environment variables
    if [[ -z "$access_key" ]]; then
        access_key="${CLAUDE_R2_ACCESS_KEY:-}"
        secret_key="${CLAUDE_R2_SECRET_KEY:-}"
        endpoint="${CLAUDE_R2_ENDPOINT:-}"
    fi
    
    # Prompt as last resort
    if [[ -z "$access_key" ]]; then
        read -p "R2 Access Key: " access_key
        read -s -p "R2 Secret Key: " secret_key
        echo
        read -p "R2 Endpoint (e.g., https://your-account.r2.cloudflarestorage.com): " endpoint
    fi
    
    if [[ -z "$access_key" || -z "$secret_key" || -z "$endpoint" ]]; then
        error "R2 credentials not found. Please set up 1Password or environment variables."
    fi
    
    # Export for rclone/aws commands
    export AWS_ACCESS_KEY_ID="$access_key"
    export AWS_SECRET_ACCESS_KEY="$secret_key"
    export AWS_ENDPOINT_URL="$endpoint"
}

# Asset download and verification
download_asset() {
    local asset_name="$1"
    local url="$2"
    local expected_sha256="$3"
    local target_dir="$4"
    
    log "Downloading $asset_name..."
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    local temp_file="${temp_dir}/$(basename "$url")"
    
    # Download with aws cli (compatible with R2)
    if ! aws s3 cp "$url" "$temp_file" --endpoint-url="$AWS_ENDPOINT_URL"; then
        rm -rf "$temp_dir"
        error "Failed to download $asset_name from $url"
    fi
    
    # Verify checksum
    local actual_sha256
    actual_sha256=$(sha256sum "$temp_file" | cut -d' ' -f1)
    if [[ "$actual_sha256" != "$expected_sha256" ]]; then
        rm -rf "$temp_dir"
        error "Checksum mismatch for $asset_name. Expected: $expected_sha256, Got: $actual_sha256"
    fi
    
    # Extract to target
    mkdir -p "$target_dir"
    if [[ "$temp_file" == *.tar.gz ]]; then
        tar -xzf "$temp_file" -C "$target_dir"
    else
        cp "$temp_file" "$target_dir/"
    fi
    
    rm -rf "$temp_dir"
    log "Successfully deployed $asset_name to $target_dir"
}

# Phase 1: Agent Library Deployment
deploy_agents() {
    log "Phase 1: Deploying agent library..."
    
    if [[ ! -f "$MANIFEST_FILE" ]]; then
        error "Manifest file not found: $MANIFEST_FILE"
    fi
    
    # Parse manifest for agents
    local agents_url agents_sha256 agents_count
    agents_url=$(jq -r '.assets.agents.url' "$MANIFEST_FILE")
    agents_sha256=$(jq -r '.assets.agents.sha256' "$MANIFEST_FILE")
    agents_count=$(jq -r '.assets.agents.count' "$MANIFEST_FILE")
    
    # Download and deploy
    local agents_target="${DEPLOY_ROOT}/agents"
    download_asset "agents" "$agents_url" "$agents_sha256" "$agents_target"
    
    # Validate count
    local actual_count
    actual_count=$(find "$agents_target" -name "*.md" -type f | wc -l)
    if [[ "$actual_count" -ne "$agents_count" ]]; then
        error "Agent count mismatch. Expected: $agents_count, Found: $actual_count"
    fi
    
    log "Phase 1 complete: $actual_count agents deployed"
}

# Phase 2: MCP Server Deployment
deploy_mcp_servers() {
    log "Phase 2: Deploying MCP servers..."
    
    # Parse manifest for MCP servers
    local mcp_url mcp_sha256
    mcp_url=$(jq -r '.assets.mcp_servers.url' "$MANIFEST_FILE")
    mcp_sha256=$(jq -r '.assets.mcp_servers.sha256' "$MANIFEST_FILE")
    
    # Download and deploy
    local mcp_target="${DEPLOY_ROOT}/mcp-servers"
    download_asset "mcp-servers" "$mcp_url" "$mcp_sha256" "$mcp_target"
    
    # Install dependencies for each server
    for server_dir in "$mcp_target"/*; do
        if [[ -d "$server_dir" && -f "$server_dir/package.json" ]]; then
            log "Installing dependencies for $(basename "$server_dir")..."
            (cd "$server_dir" && npm install --production)
        fi
    done
    
    log "Phase 2 complete: MCP servers deployed"
}

# Phase 3: Claude-Flow Integration
deploy_claude_flow() {
    log "Phase 3: Deploying Claude-Flow orchestration..."
    
    # Install claude-flow
    if ! npx claude-flow@alpha init --force; then
        error "Failed to install claude-flow"
    fi
    
    # Register MCP server
    if ! claude mcp add claude-flow "npx claude-flow@alpha mcp"; then
        log "Warning: Failed to register claude-flow MCP server (may already exist)"
    fi
    
    log "Phase 3 complete: Claude-Flow orchestration ready"
}

# Validation functions
validate_system() {
    log "Validating system deployment..."
    
    # Check agents
    if [[ -d "${DEPLOY_ROOT}/agents" ]]; then
        local agent_count
        agent_count=$(find "${DEPLOY_ROOT}/agents" -name "*.md" -type f | wc -l)
        log "✓ Found $agent_count agent files"
    else
        log "✗ Agents directory not found"
        return 1
    fi
    
    # Check MCP servers
    if [[ -d "${DEPLOY_ROOT}/mcp-servers" ]]; then
        local mcp_count
        mcp_count=$(find "${DEPLOY_ROOT}/mcp-servers" -maxdepth 1 -type d | wc -l)
        log "✓ Found $((mcp_count - 1)) MCP server directories"
    else
        log "✗ MCP servers directory not found"
        return 1
    fi
    
    log "System validation complete"
}

# Main deployment function
main() {
    local phase="${1:-all}"
    
    log "Starting Claude AI System deployment (phase: $phase)"
    
    case "$phase" in
        "agents"|"1")
            get_r2_credentials
            deploy_agents
            ;;
        "mcp"|"2")
            get_r2_credentials
            deploy_mcp_servers
            ;;
        "claude-flow"|"3")
            deploy_claude_flow
            ;;
        "all")
            get_r2_credentials
            deploy_agents
            deploy_mcp_servers
            deploy_claude_flow
            validate_system
            ;;
        "validate")
            validate_system
            ;;
        *)
            echo "Usage: $0 [agents|mcp|claude-flow|all|validate]"
            echo "  agents      - Deploy agent library only"
            echo "  mcp         - Deploy MCP servers only"
            echo "  claude-flow - Deploy orchestration only"
            echo "  all         - Deploy complete system (default)"
            echo "  validate    - Validate current deployment"
            exit 1
            ;;
    esac
    
    # Clear credentials from environment
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_ENDPOINT_URL
    
    log "Deployment complete!"
}

# Execute main function
main "$@"