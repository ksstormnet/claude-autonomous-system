# Claude AI System - Autonomous Multi-Domain Intelligence

Reproducible deployment system for autonomous multi-domain AI with safety constraints and business intelligence integration.

## Architecture Overview - DEPLOYED & OPERATIONAL

- ✅ **64 Specialized Agents** deployed and operational for autonomous expertise routing
- ✅ **8 CME Business Intelligence Servers** deployed with contextual decision-making capabilities
- ✅ **Claude-Flow Orchestration** with 87 advanced tools and swarm coordination
- ✅ **Native Cloudflare Integration** with Wrangler R2 operations and MCP server
- ✅ **Challenge Mode Framework** with procedural overrides for safety and skepticism
- ✅ **Git + R2 Storage** with verified cross-machine reproducibility (AWS CLI eliminated)
- ✅ **OAuth Authentication** via Wrangler (more secure than static credentials)
- 📖 **Comprehensive Documentation** with agent reference, MCP integration guide, and extension framework

## Quick Start

```bash
# Clone repository
git clone <repository-url>
cd claude-context

# Deploy complete system
./deploy.sh

# Or deploy specific phases
./deploy.sh agents        # Agent library only
./deploy.sh mcp           # MCP servers only  
./deploy.sh orchestration # Claude-flow + Cloudflare MCP
./deploy.sh validate      # Validate deployment
```

## Prerequisites

### Required Software  
- **Claude Code CLI** (latest version)
- **Node.js & npm** (for MCP servers) ✅ Verified working
- **Wrangler CLI** (for native Cloudflare R2 operations) ✅ OAuth authenticated
- **jq** (for JSON processing) ✅ Required for manifest parsing

### Optional (Recommended)
- **1Password CLI** (`op`) for secure credential management
- **Git** for version control and updates

### R2 Storage Setup

1. Create Cloudflare R2 bucket: `claude-system-private`
2. Generate R2 API tokens with read/write access
3. Store credentials in 1Password:
   ```
   Vault: vault
   Item: R2-Claude-System
   Fields:
     - access-key: <your-r2-access-key>
     - secret-key: <your-r2-secret-key>  
     - endpoint: https://<account-id>.r2.cloudflarestorage.com
   ```

## Asset Management

### Initial Asset Upload

```bash
# Set R2 credentials
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_ENDPOINT_URL="your-r2-endpoint"

# Upload assets (requires backup source at /mnt/installer)
./scripts/upload-assets.sh
```

### Asset Structure in R2

```
claude-system-private/
├── agents/
│   └── agents-v1.0.tar.gz          # 65 specialized agents
├── mcp-servers/  
│   └── cme-servers-v1.0.tar.gz     # 8 CME business servers
└── system-configs/
    └── claude-enhanced-v1.0.tar.gz # Enhanced templates
```

## Deployment Process

### Phase 1: Agent Library ✅ COMPLETED
- ✅ Downloaded and deployed 64 specialized agents to `~/agents/`
- ✅ Autonomous expertise routing enabled via Task tool
- ✅ Agent validation passed (64 agents operational)
- ✅ Challenge Mode framework integrated for agent selection

### Phase 2: MCP Business Intelligence ✅ COMPLETED  
- ✅ Downloaded and deployed 8 CME business servers to `~/mcp-servers/`
- ✅ Node.js dependencies installed for all servers
- ✅ CME servers ready for Claude MCP registration
- ✅ Contextual business intelligence capabilities operational

### Phase 3: Advanced Orchestration ✅ COMPLETED
- ✅ Installed claude-flow via NPX with 87 specialized tools
- ✅ Registered claude-flow MCP server for swarm coordination
- ✅ Installed and registered Cloudflare MCP server (OAuth authenticated)
- ✅ Advanced orchestration, memory management, and SPARC workflows
- ✅ Cloudflare R2, DNS, Workers, and security management capabilities

## Safety & Security

### Mandatory Safety Constraints
- **Challenge Mode Framework**: Default skeptical analysis of all solutions
- **85-90% certainty threshold** before agent selection (enhanced with challenges)
- **Multi-agent consensus** for high-impact decisions
- **Blast radius review** for critical operations
- **Human approval gates** for dangerous actions
- **Procedural Mode Override**: Disable challenges for approved execution

### Credential Security
- R2 credentials retrieved from 1Password (preferred)
- Environment variable fallback support
- Never persisted to disk during deployment
- Cleared from memory after use

### Rollback Capabilities
```bash
# Remove agents
rm -rf ~/agents/

# Remove MCP servers
claude mcp remove cme-base
claude mcp remove cme-marketing
# ... (repeat for each server)
rm -rf ~/mcp-servers/

# Remove orchestration components
claude mcp remove claude-flow
claude mcp remove cloudflare
```

## Validation

### System Health Check
```bash
./deploy.sh validate
```

### Manual Verification
- **Agents**: `ls ~/agents/*.md | wc -l` (should show 64) ✅ Verified
- **MCP Servers**: `ls ~/mcp-servers/` (should show 8 CME directories) ✅ Verified  
- **CF Authentication**: `npx wrangler whoami` (should show admin@ksstorm.info) ✅ Verified
- **Task Tool**: Test specialized routing with `Task("Python optimization", "task details", "python-pro")`

## File System Integration

### Symlink Strategy
Key files are symlinked from repository to expected locations:
- `~/CLAUDE.md` → `/repo/z_Other/claude-context/generated/CLAUDE.md`
- `~/agents/` → `/repo/z_Other/claude-context/deployed/agents/`
- `~/mcp-servers/` → `/repo/z_Other/claude-context/deployed/mcp-servers/`

### Configuration Templates
- `config-templates/CLAUDE.md.template` - Enhanced behavioral framework
- Template variables replaced during deployment ({{DEPLOY_ROOT}}, etc.)

## Troubleshooting

### Common Issues

**1Password CLI not working:**
```bash
# Check 1Password CLI status
op account get

# Sign in if needed
eval $(op signin)
```

**R2 connectivity issues:**
```bash
# Test R2 access
aws s3 ls s3://claude-system-private/ --endpoint-url="$AWS_ENDPOINT_URL"
```

**Agent count mismatch:**
- Verify source directory: `/mnt/installer/system-rebuild/configs/agents/`
- Check for missing or corrupted files in R2 archive

**MCP server registration fails:**
- Ensure Claude Code CLI is latest version
- Check server directory has valid `package.json` and dependencies installed
- Verify server script permissions and Node.js compatibility

## Version Management

### Asset Versioning
- Assets tagged with version numbers (e.g., `agents-v1.0.tar.gz`)
- Manifest tracks current versions and checksums
- Deployment script supports version pinning

### System Updates
```bash
# Update repository
git pull

# Re-deploy with latest assets
./deploy.sh

# Or update specific components
./deploy.sh agents    # Update agents only
```

## Development

### Adding New Agents
1. Create new agent `.md` file in source location
2. Re-run `./scripts/upload-assets.sh` to update R2
3. Deploy updated agents with `./deploy.sh agents`

### Modifying Business Intelligence
1. Update MCP server source files
2. Re-upload with `./scripts/upload-assets.sh`
3. Re-deploy MCP servers with `./deploy.sh mcp`

## Support

For issues or questions:
1. Check deployment logs for specific error messages
2. Validate all prerequisites are installed and configured
3. Verify R2 credentials and bucket accessibility
4. Test individual components with phase-specific deployment

---

## Current Deployment Status

### ✅ COMPLETE SYSTEM: FULLY OPERATIONAL
- **Foundation**: Native Cloudflare architecture with Wrangler OAuth authentication
- **64 Specialized Agents**: Deployed and accessible via autonomous routing
- **8 CME Business Intelligence Servers**: Contextual decision-making capabilities
- **Advanced Orchestration**: Claude-Flow with 87 tools + swarm coordination
- **Native Cloudflare Integration**: R2 operations, DNS, Workers, security management
- **Challenge Mode Framework**: Safety rails with procedural overrides
- **Comprehensive Documentation**: Agent reference, MCP guide, extension framework

## Documentation Reference

### Core System Documentation
- **[Agent Reference](./docs/AGENT-REFERENCE.md)**: Complete inventory of all 64 deployed agents with usage patterns
- **[MCP Server Reference](./docs/MCP-REFERENCE.md)**: Documentation of orchestration and business intelligence servers  
- **[Integration Guide](./docs/INTEGRATION-GUIDE.md)**: Framework for adding new domain knowledge beyond CME

### 🎯 System Goal
"Don't manage the tool" - Autonomous multi-domain AI that handles complexity while maintaining user focus on outcomes.