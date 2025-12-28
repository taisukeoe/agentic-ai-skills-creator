# Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Development Setup

### Project Structure

```
agentic-ai-skills-creator/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace manifest
├── .claude/
│   └── settings.json             # Local development settings
├── .devcontainer/                # Development container configuration
│   ├── Dockerfile
│   ├── devcontainer.json
│   ├── post-create.sh
│   ├── reinstall-marketplace.sh
│   └── sync-codex-skills.sh
├── plugins/
│   ├── skills-helper/            # Plugin for skill development
│   ├── marketplace-helper/       # Plugin for marketplace validation
│   └── skills-helper-experimental/  # Experimental skills
├── LICENSE
└── README.md
```

### Local Development Settings

Configure permissions in `.claude/settings.json` for local development:

```json
{
  "permissions": {
    "allow": [
      "Skill(creating-effective-skills)",
      "Skill(evaluating-skills-with-models)",
      "Skill(improving-skills)",
      "Skill(reviewing-skills)",
      "Skill(reviewing-plugin-marketplace)",
      "Skill(setting-up-devcontainers)",
      "Skill(running-skills-edd-cycle)"
    ]
  }
}
```

For users installing the plugin, skills are automatically available after plugin installation.

### Development with Devcontainer

This repository includes a devcontainer configuration for consistent development environments:

```bash
# Open in VS Code with Dev Containers extension
code .
# Select "Reopen in Container" when prompted
```

The devcontainer provides:
- Pre-installed Claude Code and Codex CLI
- Automatic marketplace registration on container start
- Persistent configuration via Docker volumes
- Skill synchronization between Claude Code and Codex CLI

### Codex CLI Support

Skills are automatically synced to Codex CLI format:
- Claude Code skills are converted and placed in `~/.codex/instructions/`
- Run `.devcontainer/sync-codex-skills.sh` to manually sync after skill changes

## Guidelines

- Follow existing code style and patterns
- Test skills before submitting PRs
- Keep SKILL.md files under 500 lines
- Use gerund form for skill names (e.g., `processing-pdfs`)
