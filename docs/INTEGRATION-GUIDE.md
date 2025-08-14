# Integration Guide - Adding New Domain Knowledge

## Overview

This guide explains how to extend the Claude AI autonomous system with new domain-specific knowledge beyond the current CME business intelligence. The system is designed for extensibility, allowing you to formalize any domain knowledge into contextual subagents and MCP servers.

## Architecture Principles

The system follows a **dual-layer knowledge architecture**:

1. **Agent Layer**: Domain-specific expertise and task execution
2. **MCP Layer**: Contextual intelligence and business logic

Both layers integrate with the **Challenge Mode framework** for enhanced safety and validation.

## Adding New Domain Knowledge

### Phase 1: Domain Analysis & Planning

#### 1.1 Domain Scoping
Before implementation, analyze the domain to determine the appropriate integration approach:

**Questions to Ask**:
- What specific expertise does this domain require?
- How does this domain interact with existing CME business intelligence?
- What contextual decisions need domain-specific knowledge?
- Are there regulatory or compliance requirements?

**Example Domains**:
- **Legal & Compliance**: Contract management, regulatory requirements
- **Financial Services**: Investment strategies, risk management
- **Healthcare**: Patient data management, medical protocols
- **E-commerce**: Inventory management, customer analytics

#### 1.2 Knowledge Categorization
Classify domain knowledge into two categories:

**Procedural Knowledge** → **Agents**
- Step-by-step processes
- Technical implementations
- Decision-making procedures
- Task automation workflows

**Contextual Knowledge** → **MCP Servers**
- Business rules and policies
- Historical data and patterns
- Stakeholder information
- Regulatory requirements

### Phase 2: Agent Development

#### 2.1 Agent Creation Pattern
Follow the established pattern used by CME business agents:

```bash
# Agent file naming convention
{domain}-{specialty}.md

# Examples:
legal-contract-specialist.md
financial-risk-analyst.md
healthcare-compliance-auditor.md
ecommerce-inventory-optimizer.md
```

#### 2.2 Agent Template Structure
Create new agents using this template:

```markdown
# {Domain} {Specialty}

## Role & Expertise
Brief description of the agent's specialized knowledge and capabilities.

## Primary Responsibilities
- Specific task area 1
- Specific task area 2  
- Domain-specific process management
- Integration with existing systems

## Challenge Mode Enhancements
- Domain-specific edge cases to probe
- Regulatory compliance checks
- Risk assessment procedures
- Business impact analysis

## Interaction Patterns
- How this agent coordinates with CME business intelligence
- Integration points with technical agents
- Escalation procedures for complex decisions

## Usage Examples
```bash
Task("Domain-specific task", "Detailed requirements", "{agent-name}")
```

## Integration with Existing Agents
- Coordination with `claude-consultant` for strategic decisions
- Collaboration with `legal-advisor` for compliance issues
- Technical implementation via specialized programming agents
```

#### 2.3 Agent Deployment Process

**Step 1: Create Agent Files**
```bash
# Create new domain agent directory
mkdir -p ~/agents/{domain-name}/

# Add agent definitions
cp agent-template.md ~/agents/{domain-name}/{agent-name}.md
```

**Step 2: Update Manifest**
```bash
# Add to deployment manifest for future reproducibility
# Update manifest.json agent count and validation rules
```

**Step 3: Test Agent Routing**
```bash
# Test agent accessibility
Task("Test domain expertise", "Verify agent routing", "{new-agent-name}")
```

### Phase 3: MCP Server Development

#### 3.1 MCP Server Structure
Follow the CME server pattern for consistency:

```
{Domain-Name}-{Component}/
├── package.json              # Node.js dependencies
├── mcp-server.js             # MCP server implementation  
├── context.json              # Server configuration
├── index.js                  # Entry point
└── chunks/                   # Knowledge base files
    ├── {topic-1}.md
    ├── {topic-2}.md
    ├── {topic-3}.md
    └── remit.md              # Server purpose and scope
```

#### 3.2 Knowledge Chunk Development

**Chunk File Template** (`chunks/{topic}.md`):
```markdown
# {Topic Name}

## Overview
Brief description of this knowledge area.

## Key Principles
- Principle 1: Explanation and implications
- Principle 2: Decision-making criteria
- Principle 3: Integration requirements

## Decision Framework
### When to Apply
- Specific trigger conditions
- Context requirements
- Stakeholder involvement

### Implementation Guidelines
- Step-by-step procedures
- Quality checkpoints
- Risk mitigation

## Integration Points
### CME Business Intelligence
- How this knowledge interacts with existing CME context
- Business impact considerations
- Customer experience implications

### Technical Systems
- API integrations required
- Data flow requirements
- Performance considerations

## Compliance & Risk
- Regulatory requirements
- Risk assessment criteria
- Approval processes

## Examples & Case Studies
Real-world applications and decision examples.
```

#### 3.3 MCP Server Implementation

**package.json Template**:
```json
{
  "name": "{domain-name}-mcp-server", 
  "version": "1.0.0",
  "description": "MCP server for {domain} contextual intelligence",
  "main": "index.js",
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.6.0",
    "dotenv": "^16.4.5"
  }
}
```

**mcp-server.js Template**:
```javascript
// Follow CME server patterns for consistency
// Implement context retrieval, chunk management, decision support
// Integrate with Challenge Mode framework
// Provide contextual intelligence for agent decisions
```

### Phase 4: System Integration

#### 4.1 Deployment Integration
Update deployment scripts to include new domain components:

**Manifest Updates** (`manifest.json`):
```json
{
  "assets": {
    "agents": {
      "count": "{updated-count}",
      // ... existing configuration
    },
    "{domain}_servers": {
      "description": "{Domain} contextual intelligence servers",
      "url": "s3://claude-system/{domain}-servers/{domain}-v1.0.tar.gz",
      "servers": ["Domain-Component1", "Domain-Component2"],
      "deploy_target": "~/mcp-servers/",
      "version": "1.0.0"
    }
  }
}
```

**Deployment Script Updates** (`deploy.sh`):
```bash
# Add new deployment phase for domain servers
deploy_{domain}_servers() {
    log "Deploying {domain} contextual intelligence servers..."
    
    # Parse manifest for domain servers
    local domain_url domain_sha256
    domain_url=$(jq -r '.assets.{domain}_servers.url' "$MANIFEST_FILE")
    domain_sha256=$(jq -r '.assets.{domain}_servers.sha256' "$MANIFEST_FILE")
    
    # Download and deploy using CF native toolchain
    local domain_target="${DEPLOY_ROOT}/mcp-servers"
    download_asset "{domain}-servers" "$(echo "$domain_url" | sed 's|s3://||')" "$domain_sha256" "$domain_target"
    
    # Install dependencies
    for server_dir in "$domain_target"/{Domain}-*; do
        if [[ -d "$server_dir" && -f "$server_dir/package.json" ]]; then
            log "Installing dependencies for $(basename "$server_dir")..."
            (cd "$server_dir" && npm install --production)
        fi
    done
    
    log "✓ {Domain} servers deployed and configured"
}
```

#### 4.2 Registration & Activation

**MCP Server Registration**:
```bash
# Register domain MCP servers with Claude Code
claude mcp add {domain-component} "node ~/mcp-servers/{Domain-Component}/mcp-server.js"

# Verify connectivity
claude mcp list
```

**Agent Integration Testing**:
```bash
# Test domain agent with contextual intelligence
Task("Complex domain decision", "Multi-factor analysis required", "{domain-agent}")

# Verify MCP context integration
# Should show domain-specific contextual intelligence in decision-making
```

### Phase 5: Challenge Mode Integration

#### 5.1 Domain-Specific Safety Rails
Enhance Challenge Mode with domain-specific considerations:

**Agent-Level Challenges**:
- Domain-specific edge cases and failure modes
- Regulatory compliance verification
- Stakeholder impact assessment
- Business continuity implications

**MCP-Level Context Validation**:
- Contextual intelligence accuracy verification
- Multi-source context cross-validation
- Historical precedent analysis
- Risk assessment integration

#### 5.2 Multi-Domain Coordination
Ensure new domain knowledge integrates with existing systems:

**Integration Points**:
- **CME Business Intelligence**: How domain decisions affect cruise operations
- **Technical Agents**: Implementation and deployment considerations
- **Orchestration Systems**: Multi-agent coordination for complex decisions

**Validation Framework**:
- Cross-domain impact analysis
- Stakeholder notification requirements
- Approval workflow integration
- Audit trail maintenance

## Example: Adding Legal Domain Knowledge

### Scenario
Formalizing legal and compliance knowledge for contract management and regulatory requirements.

### Implementation Steps

**1. Domain Analysis**
- **Agents Needed**: `legal-contract-specialist`, `legal-compliance-auditor`, `legal-risk-assessor`
- **MCP Servers**: `Legal-Contracts`, `Legal-Compliance`, `Legal-Risk`
- **Integration**: Contract decisions affect CME booking terms and customer agreements

**2. Agent Development**
```bash
# Create legal domain agents
~/agents/legal-contract-specialist.md     # Contract analysis and drafting
~/agents/legal-compliance-auditor.md      # Regulatory compliance verification  
~/agents/legal-risk-assessor.md          # Legal risk analysis and mitigation
```

**3. MCP Server Development**
```bash
~/mcp-servers/Legal-Contracts/            # Contract templates, terms analysis
~/mcp-servers/Legal-Compliance/           # Regulatory requirements, audit procedures
~/mcp-servers/Legal-Risk/                 # Risk assessment, liability analysis
```

**4. Challenge Mode Enhancement**
- Contract changes trigger CME business impact analysis
- Compliance decisions require multi-agent consensus
- Risk assessments integrate with existing CME risk management

**5. Deployment**
- Upload to R2 storage following established patterns
- Update deployment scripts with legal domain support
- Register MCP servers and test integration

## Maintenance & Evolution

### Knowledge Updates
- **Regular Review**: Domain knowledge requires periodic updates
- **Version Control**: Maintain versioned knowledge chunks
- **Impact Analysis**: Assess changes against existing business intelligence

### Performance Optimization
- **Usage Analytics**: Monitor agent utilization patterns
- **Response Time**: Optimize MCP server performance
- **Context Relevance**: Ensure contextual intelligence remains accurate

### Integration Health
- **Cross-Domain Testing**: Verify multi-domain decision-making
- **Challenge Mode Validation**: Ensure safety rails remain effective
- **Business Continuity**: Maintain operational stability during updates

---

*This guide provides the framework for extending the autonomous AI system with any domain knowledge while maintaining architectural consistency and safety standards.*