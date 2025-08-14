# Agent Reference - Complete Inventory

## Overview

This document catalogs all 64 specialized agents deployed in the Claude AI autonomous system. These agents provide domain-specific expertise and can be invoked via the Task tool for autonomous routing.

## Usage Pattern

```bash
Task("Brief description", "Detailed requirements", "agent-name")
```

## Agent Categories & Inventory

### Core Business Agents (7 agents)
Strategic and operational business intelligence specialists.

| Agent | Purpose | Use Cases |
|-------|---------|-----------|
| `claude-consultant` | Strategic consulting, requirements gathering, solution design | Business strategy, process optimization, requirement analysis |
| `claude-marketing-consultant` | Marketing strategy, brand positioning, CME expertise | Campaign planning, market analysis, brand development |
| `claude-planner-analyst` | Implementation planning, analysis, roadmaps | Project planning, timeline creation, resource allocation |
| `claude-writer` | Content creation, documentation, communications | Technical writing, business communications, documentation |
| `claude-tester` | Quality assurance, testing strategies, bug identification | Test planning, QA processes, defect analysis |
| `claude-blog-writer` | Blog posts, marketing content, SEO optimization | Content marketing, SEO writing, blog strategy |
| `business-analyst` | Business process analysis, requirements documentation | Process mapping, stakeholder analysis, requirements gathering |

### Programming Language Specialists (12 agents)
Deep expertise in specific programming languages and their ecosystems.

| Agent | Language/Platform | Specialization |
|-------|-------------------|----------------|
| `python-pro` | Python | Data science, web development, automation, ML/AI |
| `javascript-pro` | JavaScript | Frontend, Node.js, modern JS frameworks |
| `typescript-pro` | TypeScript | Type-safe JavaScript, large-scale applications |
| `java-pro` | Java | Enterprise applications, Spring framework, JVM |
| `golang-pro` | Go | Microservices, concurrent programming, cloud native |
| `rust-pro` | Rust | Systems programming, performance-critical applications |
| `cpp-pro` | C++ | Performance optimization, game development, embedded |
| `c-pro` | C | Systems programming, embedded, low-level optimization |
| `csharp-pro` | C# | .NET applications, enterprise development, Azure |
| `php-pro` | PHP | Web development, WordPress, Laravel, legacy systems |
| `elixir-pro` | Elixir | Functional programming, Phoenix, concurrent systems |
| `sql-pro` | SQL | Database optimization, query performance, data modeling |

### Technical Architecture Specialists (15 agents)
System design, architecture, and technical infrastructure experts.

| Agent | Specialization | Focus Areas |
|-------|----------------|-------------|
| `cloud-architect` | Cloud infrastructure design | AWS, Azure, GCP, multi-cloud strategies |
| `backend-architect` | Backend system architecture | APIs, microservices, scalability patterns |
| `database-admin` | Database administration | Performance tuning, backup/recovery, scaling |
| `database-optimizer` | Database performance | Query optimization, indexing, schema design |
| `network-engineer` | Network infrastructure | Security, performance, topology design |
| `security-auditor` | Security assessment | Vulnerability analysis, compliance, threat modeling |
| `performance-engineer` | System performance | Profiling, optimization, load testing |
| `devops-troubleshooter` | DevOps and operations | CI/CD, deployment issues, infrastructure problems |
| `deployment-engineer` | Deployment strategies | Release management, rollback procedures |
| `terraform-specialist` | Infrastructure as Code | Terraform, cloud provisioning, state management |
| `graphql-architect` | GraphQL design | Schema design, federation, performance |
| `ai-engineer` | AI/ML engineering | Model deployment, MLOps, AI system design |
| `ml-engineer` | Machine Learning | Model training, feature engineering, ML pipelines |
| `mlops-engineer` | ML Operations | Model lifecycle, monitoring, deployment automation |
| `data-engineer` | Data infrastructure | ETL pipelines, data warehousing, streaming |

### Development & Quality Specialists (10 agents)
Code quality, testing, and development process experts.

| Agent | Specialization | Focus Areas |
|-------|----------------|-------------|
| `claude-coder` | General programming | Implementation, code generation, debugging |
| `code-reviewer` | Code quality assurance | Code review, best practices, security analysis |
| `architect-review` | Architecture assessment | Design patterns, scalability review, trade-offs |
| `test-automator` | Test automation | Test frameworks, automation strategies, CI integration |
| `debugger` | Debugging assistance | Error analysis, troubleshooting, root cause analysis |
| `error-detective` | Error investigation | Log analysis, error tracking, issue resolution |
| `legacy-modernizer` | Legacy system updates | Migration strategies, modernization planning |
| `tutorial-engineer` | Technical education | Documentation, tutorials, onboarding materials |
| `prompt-engineer` | AI prompt optimization | LLM interactions, prompt design, AI tool usage |
| `reference-builder` | Reference documentation | API docs, technical references, knowledge bases |

### Domain-Specific Specialists (12 agents)
Specialized knowledge in specific technical domains.

| Agent | Domain | Specialization |
|-------|---------|----------------|
| `frontend-developer` | Frontend development | React, Vue, Angular, modern CSS, UX implementation |
| `mobile-developer` | Mobile applications | Cross-platform development, native apps |
| `ios-developer` | iOS development | Swift, Objective-C, App Store optimization |
| `unity-developer` | Game development | Unity engine, C# scripting, 3D development |
| `ui-ux-designer` | Design systems | User interface design, user experience, prototyping |
| `payment-integration` | Payment systems | Payment gateways, PCI compliance, financial APIs |
| `search-specialist` | Search systems | Elasticsearch, search optimization, information retrieval |
| `data-scientist` | Data analysis | Statistical analysis, data visualization, insights |
| `quant-analyst` | Quantitative analysis | Financial modeling, risk analysis, algorithmic trading |
| `risk-manager` | Risk assessment | Security risks, business continuity, compliance |
| `legal-advisor` | Legal compliance | Software licensing, privacy regulations, contracts |
| `incident-responder` | Crisis management | Emergency response, disaster recovery, communication |

### Content & Communication Specialists (4 agents)
Content creation, documentation, and stakeholder communication.

| Agent | Specialization | Focus Areas |
|-------|----------------|-------------|
| `docs-architect` | Documentation systems | Information architecture, doc platforms, user guides |
| `content-marketer` | Marketing content | Content strategy, audience engagement, conversion |
| `sales-automator` | Sales process automation | CRM integration, lead nurturing, sales funnels |
| `customer-support` | Customer service | Support processes, knowledge bases, ticket resolution |

### Specialized Utilities (4 agents)
Niche expertise for specific technical challenges.

| Agent | Specialization | Use Cases |
|-------|----------------|-----------|
| `api-documenter` | API documentation | OpenAPI specs, endpoint documentation, SDK guides |
| `context-manager` | Context optimization | Information organization, knowledge management |
| `dx-optimizer` | Developer experience | Tool optimization, workflow improvement, productivity |
| `README` | Project documentation | README generation, project overview, getting started guides |

## Integration with Challenge Mode

All agents operate within the **Challenge Mode framework**:

- **Default behavior**: Question assumptions and probe for edge cases
- **Certainty threshold**: 85-90% confidence required before agent selection  
- **Multi-agent consensus**: Complex decisions require multiple agent review
- **Procedural override**: "execute as planned" disables challenges for approved tasks

## Agent Selection Protocol

### Automatic Routing
The system analyzes task requirements and automatically routes to appropriate agents based on:
- **Domain keywords** (e.g., "Python optimization" → `python-pro`)
- **Task complexity** (complex tasks may involve multiple agents)
- **Business context** (CME-related tasks integrate business intelligence)

### Manual Selection
Explicitly specify agents for precise control:
```bash
Task("Optimize database queries", "PostgreSQL performance issues", "database-optimizer")
Task("Review security implications", "Authentication system design", "security-auditor")  
Task("Plan deployment strategy", "Multi-region rollout", "deployment-engineer")
```

### Multi-Agent Coordination
High-impact decisions automatically involve multiple agents:
```bash
# System automatically engages multiple specialists
Task("Design payment system", "High-volume transaction processing", "payment-integration")
# May also engage: security-auditor, database-optimizer, performance-engineer
```

## Adding New Agents

See [INTEGRATION-GUIDE.md](./INTEGRATION-GUIDE.md) for detailed instructions on adding domain-specific agents for new knowledge areas beyond CME business intelligence.

---

*Last updated: System deployment validation confirmed 64 agents operational*