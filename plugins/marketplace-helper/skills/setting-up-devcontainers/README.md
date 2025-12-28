# setting-up-devcontainers

Generate devcontainer configurations for Claude Code plugin marketplaces.

## Installation

This skill is part of the `marketplace-helper` plugin. To use it:

1. Add the marketplace to Claude Code:
   ```bash
   claude plugin marketplace add <marketplace-url>
   ```

2. Install the plugin:
   ```bash
   claude plugin install marketplace-helper@<marketplace-name>
   ```

3. Enable the skill in your settings (or approve when prompted).

## Usage

Ask Claude to set up a devcontainer for your marketplace:

```
Set up a devcontainer for my marketplace
```

The skill will:
1. Read your `.claude-plugin/marketplace.json`
2. Discover all plugins and skills
3. Ask about auto-sync preferences
4. Generate `.devcontainer/` files

## File Structure

```
setting-up-devcontainers/
├── SKILL.md              # Main skill instructions
├── README.md             # This file (human documentation)
├── templates/            # File templates for generation
│   ├── devcontainer.json.template
│   ├── Dockerfile.template
│   ├── post-create.sh.template
│   ├── reinstall-marketplace.sh.template
│   └── sync-codex-skills.sh.template
├── references/           # Reference documentation
│   ├── devcontainer-spec.md
│   ├── claude-code-installation.md
│   └── codex-cli-installation.md
└── tests/
    └── scenarios.md      # Self-evaluation test scenarios
```

## Templates

The `templates/` directory contains template files with placeholders.

See SKILL.md for the complete placeholder reference (12+ placeholders including `{{CODEX_*}}` for optional Codex CLI support).

## Testing

The `tests/scenarios.md` file contains self-evaluation scenarios for testing this skill across different models (Sonnet, Opus, Haiku).

To run model evaluation:
```
/evaluating-skills-with-models setting-up-devcontainers
```

## License

Apache-2.0
