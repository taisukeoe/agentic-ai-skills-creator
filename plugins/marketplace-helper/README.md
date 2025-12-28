# marketplace-helper

Skills for reviewing and validating Claude Code plugin marketplace configurations.

## Installation

```bash
/plugin install marketplace-helper@agentic-skills-creator
```

## Skills

### reviewing-plugin-marketplace

Review Claude Code plugin marketplace configurations against official best practices.

**Features:**
- marketplace.json structure validation
- Skills paths verification
- Git remote URL consistency checks
- README.md repository reference validation
- Common error detection (plugin.json presence, path mismatches)
- Automated verification script

**Use when:**
- Creating a new plugin marketplace
- Verifying marketplace configuration
- Debugging plugin installation issues
- Ensuring compliance with Anthropic format

### setting-up-devcontainers

Generate devcontainer configurations for Claude Code plugin marketplaces.

**Features:**
- .devcontainer/ directory generation
- Dockerfile with Claude Code and Codex CLI pre-installed
- Post-create and post-start scripts
- Volume mounts for persistent configuration
- Marketplace auto-registration on container start

**Use when:**
- Setting up development containers for a marketplace
- Creating isolated Claude Code environments
- Configuring pre-registered plugins and skills
- Enabling consistent development across machines
