# MCP Server Reference - Complete Inventory

## Overview

This document catalogs all Model Context Protocol (MCP) servers deployed in the Claude AI system. MCP servers provide contextual intelligence and tool capabilities that enhance the autonomous decision-making process.

## Active MCP Servers

### Orchestration & Coordination (2 servers)

#### `claude-flow` ✅ Connected
**Command**: `npx claude-flow@alpha mcp start`
**Purpose**: Advanced orchestration with 87 specialized tools and swarm coordination

**Key Capabilities**:
- **Swarm Intelligence**: Multi-agent coordination and task delegation
- **Memory Management**: Cross-session persistence and context retention
- **SPARC Integration**: Structured development workflows
- **87 Specialized Tools**: Analysis, automation, coordination, monitoring
- **Hive-Mind**: Distributed problem-solving capabilities

**Tool Categories**:
- Analysis (3 tools): Code analysis, performance profiling, system diagnostics
- Automation (3 tools): Workflow automation, task scheduling, process optimization  
- Coordination (3 tools): Multi-agent orchestration, resource allocation
- GitHub Integration (5 tools): Repository management, PR automation, issue tracking
- Memory & Persistence (3 tools): Context storage, session management
- Monitoring (3 tools): System health, performance tracking, alerting
- Optimization (3 tools): Performance tuning, resource optimization
- Workflows (3 tools): Development lifecycle, deployment pipelines

#### `ruv-swarm` ✅ Connected
**Command**: `npx ruv-swarm mcp start`
**Purpose**: Enhanced swarm coordination and multi-agent communication

**Key Capabilities**:
- **Agent Communication**: Inter-agent messaging and coordination
- **Task Distribution**: Intelligent workload distribution
- **Consensus Building**: Multi-agent decision making
- **Load Balancing**: Resource optimization across agents

### Cloud & Infrastructure (1 server)

#### `cloudflare` ⚠️ Connection Issues
**Command**: `npx @cloudflare/mcp-server-cloudflare run 54919652c0ba9b83cb0ae04cb5ea90f3`
**Purpose**: Native Cloudflare service integration and management

**Key Capabilities**:
- **R2 Storage Management**: Direct bucket operations, file management
- **DNS & Domain Management**: Zone configuration, record management
- **Workers & Pages**: Serverless function deployment and management
- **Analytics & Performance**: Traffic analysis, optimization insights  
- **Security Configuration**: WAF rules, DDoS protection, SSL/TLS management

**Note**: Currently shows connection issues in health checks but underlying Wrangler integration is functional.

## Business Intelligence MCP Servers

### CME Business Knowledge Servers (8 servers)
**Location**: `~/mcp-servers/`
**Status**: Deployed with dependencies, ready for registration

These servers provide contextual business intelligence for Cruise Made Easy operations:

#### `CME-Assets`
**Purpose**: Brand asset management and usage guidelines
**Content Areas**:
- Logo assets and brand guidelines
- Canva templates and design resources
- Usage policies and brand standards
- Visual identity management

#### `CME-Base`  
**Purpose**: Core brand foundation and company principles
**Content Areas**:
- Brand voice and messaging framework
- Company mission and vision statements
- Core values and principles
- Brand differentiation strategies

#### `CME-Content`
**Purpose**: Content creation standards and practices  
**Content Areas**:
- Blog writing standards and SEO practices
- Social media content guidelines
- Content style and tone requirements
- Editorial calendars and planning

#### `CME-Marketing`
**Purpose**: Marketing strategy and campaign management
**Content Areas**:
- Marketing automation workflows
- Email campaign templates and sequences
- Lead generation funnels and conversion optimization
- Referral programs and advertising strategies

#### `CME-Operations`
**Purpose**: Operational workflows and customer management
**Content Areas**:
- Booking workflow processes
- Lead intake and qualification procedures
- Group booking management
- Customer service protocols

#### `CME-Personas`
**Purpose**: Customer segmentation and targeting
**Content Areas**:
- Easy Breezy customer segment profiles
- Luxe Seafarer persona characteristics
- Thrill Seeker audience targeting
- Personalization and nurture sequences

#### `CME-Tech`
**Purpose**: Technical infrastructure and integrations
**Content Areas**:
- Docker stack configuration and management
- Cloudflare R2 integration procedures
- ActivePieces workflow automation
- Technical system documentation

#### `CME-Website`
**Purpose**: Website optimization and user experience
**Content Areas**:
- Site structure and navigation design
- Booking flow optimization
- User experience best practices  
- SEO and conversion optimization

## MCP Server Integration

### Registration Process
CME business intelligence servers can be registered with Claude Code using:

```bash
# Register individual CME servers
claude mcp add cme-base "node ~/mcp-servers/CME-Base/mcp-server.js"
claude mcp add cme-marketing "node ~/mcp-servers/CME-Marketing/mcp-server.js"
# ... repeat for each CME server
```

### Contextual Integration
MCP servers provide contextual intelligence that enhances agent decision-making:

1. **Business Context**: CME servers provide domain knowledge for business decisions
2. **Technical Context**: Orchestration servers coordinate complex multi-agent tasks
3. **Infrastructure Context**: Cloudflare server manages deployment and scaling

### Challenge Mode Integration
MCP servers operate within the Challenge Mode framework:
- **Context Validation**: Servers provide verified business context to reduce assumptions
- **Multi-Source Consensus**: Decisions incorporate both agent expertise and MCP intelligence
- **Safety Rails**: Business intelligence helps identify potential negative impacts

## Server Health Monitoring

### Health Check Commands
```bash
# Check all MCP server status  
claude mcp list

# Test specific server connectivity
claude mcp test claude-flow

# Restart failed servers
claude mcp restart cloudflare
```

### Troubleshooting Common Issues

#### Connection Failures
- **Cloudflare MCP**: Often shows connection failures in health checks but remains functional
- **Resolution**: Verify Wrangler authentication: `npx wrangler whoami`

#### Memory Issues  
- **Claude-Flow**: SQLite binding issues require local installation for persistence
- **Resolution**: `npm install claude-flow@alpha` for persistent storage

#### Port Conflicts
- **Multiple MCP Servers**: May conflict on default ports
- **Resolution**: Configure custom ports in MCP server startup commands

## Extending MCP Infrastructure

### Adding New Domain Knowledge
To add MCP servers for domains beyond CME business intelligence:

1. **Create Server Structure**: Follow CME server patterns
2. **Implement Context Files**: Domain-specific knowledge chunks
3. **Configure Integration**: Register with Claude Code MCP system
4. **Test Integration**: Verify contextual intelligence enhancement

See [INTEGRATION-GUIDE.md](./INTEGRATION-GUIDE.md) for detailed procedures.

---

*Last updated: System validation confirmed 3 orchestration MCP servers operational, 8 CME servers deployed and ready for registration*