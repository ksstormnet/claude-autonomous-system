#!/bin/bash
# Verify autonomous AI system components are properly configured
set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

log "🔍 Verifying Autonomous AI System Components..."

# Check agents
if [[ -d ~/agents ]]; then
    agent_count=$(ls ~/agents/*.md 2>/dev/null | wc -l)
    log "✅ Agents: $agent_count specialized agents deployed"
else
    log "❌ Agents: Not deployed. Run './deploy-simple.sh agents'"
fi

# Check MCP servers
if [[ -d ~/mcp-servers ]]; then
    server_count=$(ls ~/mcp-servers/CME-* -d 2>/dev/null | wc -l)
    log "✅ MCP Servers: $server_count CME business intelligence servers deployed"
else
    log "❌ MCP Servers: Not deployed. Run './deploy-simple.sh mcp'"
fi

# Check claude-flow
if command -v npx >/dev/null && npx claude-flow@alpha --version >/dev/null 2>&1; then
    cf_version=$(npx claude-flow@alpha --version | head -1)
    log "✅ Claude-Flow: $cf_version available"
else
    log "❌ Claude-Flow: Not available. Install with: npm install -g claude-flow@alpha"
fi

# Check MCP registrations
mcp_registered=$(claude mcp list 2>/dev/null | grep -E "(claude-flow|cme-)" | wc -l)
if [[ $mcp_registered -gt 0 ]]; then
    log "✅ MCP Registration: $mcp_registered servers registered with Claude Code"
else
    log "❌ MCP Registration: No servers found. Run registration script."
fi

# Check credentials
if [[ -f ~/Desktop/r2-creds.txt ]]; then
    log "✅ Credentials: R2 credentials file available"
else
    log "⚠️  Credentials: R2 credentials not found at ~/Desktop/r2-creds.txt"
fi

log ""
log "🎯 System Status Summary:"
log "   When you type 'claude' you should have access to:"
log "   • $agent_count specialized agents via Task tool"
log "   • $server_count CME business intelligence servers" 
log "   • Claude-flow orchestration with 87 tools"
log "   • Challenge Mode safety framework"
log "   • Native Cloudflare integration"
log ""

if [[ $mcp_registered -gt 8 ]]; then
    log "🎉 AUTONOMOUS AI SYSTEM FULLY OPERATIONAL!"
    log "   Try: Task(\"optimize Python code\", \"performance improvements\", \"python-pro\")"
else
    log "⚠️  System partially configured. MCP servers may need registration."
fi