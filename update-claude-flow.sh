#!/bin/bash
# Daily claude-flow update script for active alpha development
set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

log "Starting daily claude-flow update..."

# Clear npx cache to force fresh download of latest alpha
log "Clearing npx cache for claude-flow@alpha..."
npx clear-npx-cache claude-flow@alpha 2>/dev/null || rm -rf ~/.npm/_npx/*/node_modules/claude-flow 2>/dev/null || true

# Update claude-flow to latest alpha version by clearing cache and re-running
log "Fetching latest claude-flow@alpha version..."
if npx --yes claude-flow@alpha --version >/dev/null 2>&1; then
    new_version=$(npx claude-flow@alpha --version | head -1)
    log "✓ claude-flow updated to: $new_version"
    
    # Restart the MCP server to ensure it uses the latest version
    log "Restarting claude-flow MCP server..."
    if claude mcp restart claude-flow 2>/dev/null; then
        log "✓ claude-flow MCP server restarted with latest version"
    else
        log "⚠ MCP server restart failed (server may auto-update on next use)"
    fi
    
else
    log "⚠ Failed to fetch latest claude-flow@alpha"
    exit 1
fi

log "✓ Daily claude-flow update complete"