# Agentic AI Skills Creator

A Claude Code plugin marketplace providing skills for creating and reviewing effective AI agent skills following Claude's official best practices.

## Confidentiality Notice

**This project must NOT contain any confidential information from specific companies or projects.**

All examples, documentation, and code samples in this repository use generic, fictional names and scenarios. Any resemblance to actual company names, project names, or proprietary information is unintentional and should be reported immediately.

## Plugins & Skills

### [skills-helper](plugins/skills-helper/)

Skills for AI agent skill development.

| Skill | Description |
|-------|-------------|
| `creating-effective-skills` | Guide for creating skills with 9-step workflow |
| `evaluating-skills-with-models` | Evaluate skills across sonnet, opus, haiku models |
| `improving-skills` | Improve existing skills based on user feedback |
| `reviewing-skills` | Review skills against best practices with compliance checks |

### [marketplace-helper](plugins/marketplace-helper/)

Skills for marketplace configuration.

| Skill | Description |
|-------|-------------|
| `reviewing-plugin-marketplace` | Review marketplace configurations, detect common errors |
| `setting-up-devcontainers` | Generate devcontainer configurations for marketplaces |

### [skills-helper-experimental](plugins/skills-helper-experimental/)

Experimental skills for skill development.

| Skill | Description |
|-------|-------------|
| `running-skills-edd-cycle` | Guide EDD (evaluation-driven development) process |

## Installation

### Via skills.sh

Works with Claude Code, Cursor, Cline, GitHub Copilot, and other AI agents.

```bash
# Install all skills
npx skills add taisukeoe/agentic-ai-skills-creator

# Install specific skill only
npx skills add taisukeoe/agentic-ai-skills-creator --skill creating-effective-skills
```

### Via Claude Code Plugin Marketplace

```bash
/plugin marketplace add taisukeoe/agentic-ai-skills-creator
/plugin install skills-helper@agentic-skills-creator
/plugin install marketplace-helper@agentic-skills-creator
/plugin install skills-helper-experimental@agentic-skills-creator  # Optional
```

### From Local Path (Development)

```bash
/plugin marketplace add /path/to/agentic-ai-skills-creator
/plugin install skills-helper@local
/plugin install marketplace-helper@local
```

After installation, restart Claude Code to activate the skills.

## Quick Start

### Creating a New Skill

```
Create a skill for processing PDF files
```

Claude will guide you through the 9-step workflow to create a properly structured skill.

### Reviewing an Existing Skill

```
Review the skill at .claude/skills/my-skill/
```

Claude will analyze the skill and provide feedback with priorities.

## Best Practices Covered

- **Naming**: Gerund form (e.g., `processing-pdfs`)
- **Progressive Disclosure**: 3-level loading (metadata, SKILL.md, references)
- **Size**: SKILL.md under 500 lines
- **Descriptions**: Third person, includes WHAT and WHEN
- **References**: One level deep, with TOC for files >100 lines
- **Degrees of Freedom**: High/Medium/Low based on task characteristics

## License

Copyright 2025 Softgraphy GK

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## Links

- [skills.sh](https://skills.sh/) - Agent Skills Directory
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
