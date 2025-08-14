#!/bin/bash
# Register all CME business intelligence MCP servers with Claude Code
set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Array of CME MCP servers
CME_SERVERS=(
    "cme-assets:CME-Assets"
    "cme-base:CME-Base" 
    "cme-content:CME-Content"
    "cme-marketing:CME-Marketing"
    "cme-operations:CME-Operations"
    "cme-personas:CME-Personas"
    "cme-tech:CME-Tech"
    "cme-website:CME-Website"
)

log "Registering CME business intelligence MCP servers..."

for server_config in "${CME_SERVERS[@]}"; do
    server_id="${server_config%:*}"
    server_dir="${server_config#*:}"
    
    log "Registering $server_id ($server_dir)..."
    
    # Check if server directory exists
    if [[ ! -d "$HOME/mcp-servers/$server_dir" ]]; then
        log "⚠ Server directory not found: $HOME/mcp-servers/$server_dir"
        log "Run './deploy-simple.sh mcp' first to deploy MCP servers"
        continue
    fi
    
    # Register with Claude Code
    if claude mcp add "$server_id" "node $HOME/mcp-servers/$server_dir/mcp-server.js"; then
        log "✓ Registered $server_id"
    else
        log "⚠ Failed to register $server_id (may already exist)"
    fi
done

log "Registration complete. Checking MCP server status..."
claude mcp list

log "🎯 Claude Code now has access to:"
log "   - 64+ specialized agents (via Task tool routing)"
log "   - 8 CME business intelligence servers"
log "   - 87 orchestration tools (claude-flow)"  
log "   - Challenge Mode safety framework"
log ""
log "✓ Type 'claude' to access the complete autonomous AI system!"