#!/bin/bash
# Asset Upload Script for Claude AI System
# Uploads assets from local backup to R2 storage with versioning
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
MANIFEST_FILE="${REPO_ROOT}/manifest.json"

# Source directory (backup location)
SOURCE_ROOT="/mnt/installer/system-rebuild"
AGENTS_SOURCE="${SOURCE_ROOT}/configs/agents"
MCP_SOURCE="${SOURCE_ROOT}/archive-outdated/mcp-servers"
CONFIG_SOURCE="${SOURCE_ROOT}/configs/current-system"

# Logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    log "ERROR: $*"
    exit 1
}

# Check if source directories exist
check_sources() {
    if [[ ! -d "$AGENTS_SOURCE" ]]; then
        error "Agents source not found: $AGENTS_SOURCE"
    fi
    
    if [[ ! -d "$MCP_SOURCE" ]]; then
        error "MCP servers source not found: $MCP_SOURCE"
    fi
    
    if [[ ! -d "$CONFIG_SOURCE" ]]; then
        error "System configs source not found: $CONFIG_SOURCE"
    fi
    
    log "All source directories found"
}

# Create and upload asset archive
upload_asset() {
    local asset_name="$1"
    local source_dir="$2" 
    local s3_key="$3"
    local version="${4:-1.0}"
    
    log "Creating archive for $asset_name..."
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    local archive_name="${asset_name}-v${version}.tar.gz"
    local archive_path="${temp_dir}/${archive_name}"
    
    # Create archive
    if ! tar -czf "$archive_path" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"; then
        rm -rf "$temp_dir"
        error "Failed to create archive for $asset_name"
    fi
    
    # Calculate checksum
    local sha256
    sha256=$(sha256sum "$archive_path" | cut -d' ' -f1)
    log "Archive created: $archive_name (SHA256: $sha256)"
    
    # Upload to R2
    local s3_url="s3://claude-system/${s3_key}"
    if ! aws s3 cp "$archive_path" "$s3_url" --endpoint-url="$AWS_ENDPOINT_URL"; then
        rm -rf "$temp_dir"
        error "Failed to upload $asset_name to R2"
    fi
    
    log "Uploaded $asset_name to $s3_url"
    
    # Clean up
    rm -rf "$temp_dir"
    
    # Return values for manifest update
    echo "$sha256|$s3_url"
}

# Update manifest with actual checksums and URLs
update_manifest() {
    local agents_info="$1"
    local mcp_info="$2"
    local configs_info="$3"
    
    # Parse info strings
    local agents_sha256 agents_url
    IFS='|' read -r agents_sha256 agents_url <<< "$agents_info"
    
    local mcp_sha256 mcp_url
    IFS='|' read -r mcp_sha256 mcp_url <<< "$mcp_info"
    
    local configs_sha256 configs_url
    IFS='|' read -r configs_sha256 configs_url <<< "$configs_info"
    
    # Update manifest
    local temp_manifest
    temp_manifest=$(mktemp)
    
    jq \
        --arg agents_sha256 "$agents_sha256" \
        --arg agents_url "$agents_url" \
        --arg mcp_sha256 "$mcp_sha256" \
        --arg mcp_url "$mcp_url" \
        --arg configs_sha256 "$configs_sha256" \
        --arg configs_url "$configs_url" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '
        .created = $timestamp |
        .assets.agents.sha256 = $agents_sha256 |
        .assets.agents.url = $agents_url |
        .assets.mcp_servers.sha256 = $mcp_sha256 |
        .assets.mcp_servers.url = $mcp_url |
        .assets.system_configs.sha256 = $configs_sha256 |
        .assets.system_configs.url = $configs_url
        ' "$MANIFEST_FILE" > "$temp_manifest"
    
    mv "$temp_manifest" "$MANIFEST_FILE"
    log "Manifest updated with actual checksums and URLs"
}

# Main upload function
main() {
    log "Starting asset upload to R2..."
    
    # Check prerequisites
    if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" || -z "${AWS_ENDPOINT_URL:-}" ]]; then
        error "R2 credentials not set. Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_ENDPOINT_URL"
    fi
    
    if ! command -v aws &> /dev/null; then
        error "AWS CLI not found. Please install awscli"
    fi
    
    if ! command -v jq &> /dev/null; then
        error "jq not found. Please install jq"
    fi
    
    # Check source directories
    check_sources
    
    # Upload assets
    log "Uploading agents..."
    agents_info=$(upload_asset "agents" "$AGENTS_SOURCE" "agents/agents-v1.0.tar.gz")
    
    log "Uploading MCP servers..."
    mcp_info=$(upload_asset "mcp-servers" "$MCP_SOURCE" "mcp-servers/cme-servers-v1.0.tar.gz")
    
    log "Uploading system configs..."
    configs_info=$(upload_asset "system-configs" "$CONFIG_SOURCE" "system-configs/claude-enhanced-v1.0.tar.gz")
    
    # Update manifest
    update_manifest "$agents_info" "$mcp_info" "$configs_info"
    
    log "Asset upload complete!"
    log "Manifest updated: $MANIFEST_FILE"
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi