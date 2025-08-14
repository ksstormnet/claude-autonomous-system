#!/bin/bash
# Simple deployment script without 1Password dependency
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

# Load R2 credentials from file
load_r2_credentials() {
    log "Loading R2 credentials..."
    
    if [[ -f ~/Desktop/r2-creds.txt ]]; then
        source ~/Desktop/r2-creds.txt
        log "✓ R2 credentials loaded from ~/Desktop/r2-creds.txt"
    elif [[ -n "${AWS_ACCESS_KEY_ID:-}" && -n "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
        log "✓ R2 credentials found in environment"
    else
        error "R2 credentials not found. Please either:
1. Ensure ~/Desktop/r2-creds.txt exists with credentials
2. Set environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_ENDPOINT_URL"
    fi
    
    # Set default endpoint if not provided
    if [[ -z "${AWS_ENDPOINT_URL:-}" ]]; then
        export AWS_ENDPOINT_URL="https://${CLOUDFLARE_ACCOUNT_ID}.r2.cloudflarestorage.com"
        log "✓ Using default R2 endpoint: $AWS_ENDPOINT_URL"
    fi
    
    log "✓ R2 credentials ready for deployment"
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
        error "Failed to download $asset_name from R2"
    fi
    
    # Verify checksum
    local actual_sha256
    actual_sha256=$(sha256sum "$temp_file" | cut -d' ' -f1)
    if [[ "$actual_sha256" != "$expected_sha256" ]]; then
        error "Checksum mismatch for $asset_name. Expected: $expected_sha256, Got: $actual_sha256"
    fi
    
    log "✓ $asset_name downloaded and verified"
    
    # Extract to target
    mkdir -p "$target_dir"
    if tar -xzf "$temp_file" -C "$target_dir"; then
        log "✓ $asset_name extracted to $target_dir"
    else
        error "Failed to extract $asset_name"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Deploy agents
deploy_agents() {
    log "Deploying agent library via Cloudflare R2..."
    
    # Parse manifest
    local agents_url agents_sha256
    agents_url=$(jq -r '.assets.agents.url' "$MANIFEST_FILE")
    agents_sha256=$(jq -r '.assets.agents.sha256' "$MANIFEST_FILE")
    
    # Convert S3 URL to R2 bucket/key format
    local bucket_key
    bucket_key=$(echo "$agents_url" | sed 's|s3://||')
    
    # Download and deploy
    local agents_target="${DEPLOY_ROOT}/agents"
    download_asset "agents" "$bucket_key" "$agents_sha256" "$agents_target"
    
    # Count deployed agents
    local agent_count
    agent_count=$(find "$agents_target" -name "*.md" -type f | wc -l)
    log "✓ Deployed $agent_count specialized agents"
    
    log "✓ Agent library deployment complete"
}

# Deploy MCP servers
deploy_mcp_servers() {
    log "Deploying CME business intelligence servers via Cloudflare R2..."
    
    # Parse manifest
    local mcp_url mcp_sha256
    mcp_url=$(jq -r '.assets.mcp_servers.url' "$MANIFEST_FILE")
    mcp_sha256=$(jq -r '.assets.mcp_servers.sha256' "$MANIFEST_FILE")
    
    # Convert S3 URL to R2 bucket/key format
    local bucket_key
    bucket_key=$(echo "$mcp_url" | sed 's|s3://||')
    
    # Download and deploy
    local mcp_target="${DEPLOY_ROOT}/mcp-servers"
    download_asset "cme-servers" "$bucket_key" "$mcp_sha256" "$mcp_target"
    
    # Install dependencies for each server
    for server_dir in "$mcp_target"/CME-*; do
        if [[ -d "$server_dir" && -f "$server_dir/package.json" ]]; then
            log "Installing dependencies for $(basename "$server_dir")..."
            (cd "$server_dir" && npm install --production)
        fi
    done
    
    log "✓ CME business intelligence servers deployed"
}

# Main function
main() {
    local phase="${1:-all}"
    
    log "Starting Claude AI System deployment (phase: $phase)"
    
    # Load credentials and verify auth
    load_r2_credentials
    verify_cf_auth
    
    case "$phase" in
        "agents"|"1")
            deploy_agents
            ;;
        "mcp"|"2")
            deploy_mcp_servers
            ;;
        "all")
            deploy_agents
            deploy_mcp_servers
            ;;
        *)
            echo "Usage: $0 [agents|mcp|all]"
            echo "  agents  - Deploy agent library"
            echo "  mcp     - Deploy MCP servers"
            echo "  all     - Deploy complete system (default)"
            exit 1
            ;;
    esac
    
    log "✓ Deployment complete!"
}

# Execute main function
main "$@"