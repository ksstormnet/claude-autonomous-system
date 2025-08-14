#!/bin/bash
# Claude AI System Deployment Script - Cloudflare Native Version
# Deploys autonomous multi-domain AI system using Cloudflare toolchain
set -euo pipefail

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_FILE="${REPO_ROOT}/manifest.json"
DEPLOY_ROOT="${HOME}"
CLOUDFLARE_ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:-54919652c0ba9b83cb0ae04cb5ea90f3}"

# Logging setup
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    log "ERROR: $*"
    exit 1
}

# Secure Credential Management - 1Password Only (No Filesystem Storage)
get_r2_credentials() {
    log "Retrieving R2 credentials securely from 1Password..."
    
    # Verify 1Password CLI is available
    if ! command -v op &> /dev/null; then
        error "1Password CLI not found. Install with: curl -sSfL https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list && sudo apt update && sudo apt install 1password-cli"
    fi
    
    # Check 1Password authentication status
    log "Checking 1Password authentication..."
    if ! op whoami &>/dev/null; then
        log "1Password CLI not authenticated. Attempting signin..."
        
        # Try desktop app integration first
        if op account list &>/dev/null; then
            log "Using 1Password desktop app integration"
        else
            # Manual signin required
            log "Manual 1Password signin required"
            echo "Please sign in to 1Password CLI. Available methods:"
            echo "1. Desktop integration: Ensure 1Password app is running with CLI integration enabled"
            echo "2. Manual signin: op signin --account your-account.1password.com"
            echo "3. Service account: Set OP_SERVICE_ACCOUNT_TOKEN environment variable"
            error "1Password authentication required before continuing"
        fi
    fi
    
    # Retrieve credentials from 1Password (in memory only)
    log "Retrieving R2 credentials from 1Password item 'R2-Claude-System'..."
    
    local access_key secret_key endpoint_url
    
    if ! access_key=$(op item get "R2-Claude-System" --field="access-key" 2>/dev/null); then
        error "Failed to retrieve access-key from 1Password item 'R2-Claude-System'. 
Please create this item with fields:
- access-key: Your Cloudflare R2 Access Key ID
- secret-key: Your Cloudflare R2 Secret Access Key  
- endpoint: https://your-account-id.r2.cloudflarestorage.com"
    fi
    
    if ! secret_key=$(op item get "R2-Claude-System" --field="secret-key" 2>/dev/null); then
        error "Failed to retrieve secret-key from 1Password item 'R2-Claude-System'"
    fi
    
    if ! endpoint_url=$(op item get "R2-Claude-System" --field="endpoint" 2>/dev/null); then
        # Use default endpoint if not specified
        endpoint_url="https://${CLOUDFLARE_ACCOUNT_ID}.r2.cloudflarestorage.com"
        log "Using default R2 endpoint: $endpoint_url"
    fi
    
    # Export credentials to current session only (no filesystem storage)
    export AWS_ACCESS_KEY_ID="$access_key"
    export AWS_SECRET_ACCESS_KEY="$secret_key"
    export AWS_ENDPOINT_URL="$endpoint_url"
    
    # Verify credentials are set
    if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" ]]; then
        error "Failed to export R2 credentials from 1Password"
    fi
    
    log "✓ R2 credentials securely loaded from 1Password (session only, no disk storage)"
}

# Verify Cloudflare authentication
verify_cf_auth() {
    log "Verifying Cloudflare authentication..."
    
    if ! command -v npx &> /dev/null; then
        error "Node.js/NPX not found. Please install Node.js"
    fi
    
    # Test wrangler authentication
    if ! CLOUDFLARE_ACCOUNT_ID="$CLOUDFLARE_ACCOUNT_ID" npx wrangler whoami &>/dev/null; then
        error "Wrangler authentication failed. Please run: npx wrangler login"
    fi
    
    log "✓ Cloudflare authentication verified for account: $CLOUDFLARE_ACCOUNT_ID"
}

# Asset download and verification using Wrangler
download_asset() {
    local asset_name="$1"
    local bucket_key="$2"  # Format: bucket/path/file.tar.gz
    local expected_sha256="$3"
    local target_dir="$4"
    
    log "Downloading $asset_name via Cloudflare R2..."
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    local temp_file="${temp_dir}/$(basename "$bucket_key")"
    
    # Download with Wrangler
    if ! CLOUDFLARE_ACCOUNT_ID="$CLOUDFLARE_ACCOUNT_ID" npx wrangler r2 object get "$bucket_key" --file "$temp_file" --remote; then
        rm -rf "$temp_dir"
        error "Failed to download $asset_name from R2: $bucket_key"
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
    log "✓ Successfully deployed $asset_name to $target_dir"
}

# Phase 1: Agent Library Deployment
deploy_agents() {
    log "Phase 1: Deploying agent library via Cloudflare R2..."
    
    if [[ ! -f "$MANIFEST_FILE" ]]; then
        error "Manifest file not found: $MANIFEST_FILE"
    fi
    
    # Parse manifest for agents
    local agents_url agents_sha256 agents_count
    agents_url=$(jq -r '.assets.agents.url' "$MANIFEST_FILE")
    agents_sha256=$(jq -r '.assets.agents.sha256' "$MANIFEST_FILE")
    agents_count=$(jq -r '.assets.agents.count' "$MANIFEST_FILE")
    
    # Convert S3 URL to Wrangler format (claude-system/agents/agents-v1.0.tar.gz)
    local bucket_key
    bucket_key=$(echo "$agents_url" | sed 's|s3://||')
    
    # Download and deploy
    local agents_target="${DEPLOY_ROOT}/agents"
    download_asset "agents" "$bucket_key" "$agents_sha256" "$agents_target"
    
    # Validate count
    local actual_count
    actual_count=$(find "$agents_target" -name "*.md" -type f | wc -l)
    if [[ "$actual_count" -ne "$agents_count" ]]; then
        error "Agent count mismatch. Expected: $agents_count, Found: $actual_count"
    fi
    
    log "✓ Phase 1 complete: $actual_count agents deployed via Cloudflare R2"
}

# Phase 2: MCP Server Deployment
deploy_mcp_servers() {
    log "Phase 2: Deploying MCP servers via Cloudflare R2..."
    
    # Parse manifest for MCP servers
    local mcp_url mcp_sha256
    mcp_url=$(jq -r '.assets.mcp_servers.url' "$MANIFEST_FILE")
    mcp_sha256=$(jq -r '.assets.mcp_servers.sha256' "$MANIFEST_FILE")
    
    # Convert S3 URL to Wrangler format
    local bucket_key
    bucket_key=$(echo "$mcp_url" | sed 's|s3://||')
    
    # Download and deploy
    local mcp_target="${DEPLOY_ROOT}/mcp-servers"
    download_asset "mcp-servers" "$bucket_key" "$mcp_sha256" "$mcp_target"
    
    # Install dependencies for each server
    for server_dir in "$mcp_target"/*; do
        if [[ -d "$server_dir" && -f "$server_dir/package.json" ]]; then
            log "Installing dependencies for $(basename "$server_dir")..."
            (cd "$server_dir" && npm install --production)
        fi
    done
    
    log "✓ Phase 2 complete: MCP servers deployed via Cloudflare R2"
}

# Phase 3: Advanced Orchestration & Cloudflare Integration
deploy_advanced_orchestration() {
    log "Phase 3: Deploying advanced orchestration with native CF integration..."
    
    # Install claude-flow
    if ! npx claude-flow@alpha init --force; then
        error "Failed to install claude-flow"
    fi
    
    # Register claude-flow MCP server
    if ! claude mcp add claude-flow "npx claude-flow@alpha mcp"; then
        log "Warning: Failed to register claude-flow MCP server (may already exist)"
    fi
    
    # Register Cloudflare MCP with proper account ID
    log "Configuring native Cloudflare MCP integration..."
    if ! claude mcp add cloudflare "npx @cloudflare/mcp-server-cloudflare run $CLOUDFLARE_ACCOUNT_ID"; then
        log "Warning: Failed to register Cloudflare MCP server (may already exist)"
    fi
    
    # Note: CLOUDFLARE_ACCOUNT_ID managed via environment, not persisted to disk
    log "Using CLOUDFLARE_ACCOUNT_ID: $CLOUDFLARE_ACCOUNT_ID (session only)"
    
    log "✓ Phase 3 complete: Native Cloudflare integration active"
}

# Validation functions
validate_system() {
    log "Validating Cloudflare-native deployment..."
    
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
    
    # Test Cloudflare authentication
    if CLOUDFLARE_ACCOUNT_ID="$CLOUDFLARE_ACCOUNT_ID" npx wrangler whoami &>/dev/null; then
        log "✓ Cloudflare authentication working"
    else
        log "✗ Cloudflare authentication failed"
        return 1
    fi
    
    log "✓ Cloudflare-native system validation complete"
}

# Main deployment function
main() {
    local phase="${1:-all}"
    
    log "Starting Claude AI System deployment with native Cloudflare integration (phase: $phase)"
    
    case "$phase" in
        "agents"|"1")
            verify_cf_auth
            get_r2_credentials
            deploy_agents
            ;;
        "mcp"|"2")
            verify_cf_auth
            get_r2_credentials
            deploy_mcp_servers
            ;;
        "orchestration"|"3")
            deploy_advanced_orchestration
            ;;
        "all")
            verify_cf_auth
            get_r2_credentials
            deploy_agents
            deploy_mcp_servers
            deploy_advanced_orchestration
            validate_system
            ;;
        "validate")
            verify_cf_auth
            validate_system
            ;;
        *)
            echo "Usage: $0 [agents|mcp|orchestration|all|validate]"
            echo "  agents        - Deploy agent library via CF R2"
            echo "  mcp           - Deploy MCP servers via CF R2"
            echo "  orchestration - Deploy claude-flow + native CF MCP"
            echo "  all           - Deploy complete system (default)"
            echo "  validate      - Validate CF-native deployment"
            echo ""
            echo "Environment Variables:"
            echo "  CLOUDFLARE_ACCOUNT_ID - CF Account ID (default: 54919652c0ba9b83cb0ae04cb5ea90f3)"
            echo ""
            echo "Secure Credential Requirements:"
            echo "  - 1Password CLI must be installed and authenticated"
            echo "  - 1Password item 'R2-Claude-System' with fields:"
            echo "    * access-key: Cloudflare R2 Access Key ID"
            echo "    * secret-key: Cloudflare R2 Secret Access Key"
            echo "    * endpoint: https://account-id.r2.cloudflarestorage.com (optional)"
            echo ""
            echo "Security: Credentials loaded in memory only, never stored on disk"
            exit 1
            ;;
    esac
    
    log "✓ Cloudflare-native deployment complete!"
}

# Execute main function
main "$@"