# Claude Code Installation Reference

Guide for installing Claude Code CLI in devcontainers.

## Contents

- [Binary Installation](#binary-installation) - installer script usage
- [CLAUDE_CONFIG_DIR](#claude_config_dir) - custom config path
- [PATH Configuration](#path-configuration) - environment setup
- [Authentication](#authentication) - login and persistence
- [Plugin Commands](#plugin-commands) - marketplace and plugin management
- [Troubleshooting](#troubleshooting) - common issues

## Binary Installation

Recommended method using official installer:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**IMPORTANT**: Binary is always installed to `~/.local/bin/claude` regardless of `CLAUDE_CONFIG_DIR`.

**Version options**:
```bash
# Stable (default)
curl -fsSL https://claude.ai/install.sh | bash

# Latest
curl -fsSL https://claude.ai/install.sh | bash -s latest

# Specific version
curl -fsSL https://claude.ai/install.sh | bash -s 1.0.58
```

## CLAUDE_CONFIG_DIR

Environment variable to customize **configuration files** location (NOT binary):

```bash
export CLAUDE_CONFIG_DIR=/opt/claude-config
```

**Directory structure**:
```
~/.local/bin/
└── claude               # Binary (always here)

/opt/claude-config/      # When CLAUDE_CONFIG_DIR=/opt/claude-config
├── settings.json        # User settings
├── credentials.json     # Auth tokens (after login)
└── plugins/             # Plugin data
```

## PATH Configuration

Add binary to PATH (always `~/.local/bin`):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

In Dockerfile:
```dockerfile
ENV CLAUDE_CONFIG_DIR=/opt/claude-config
ENV PATH="/home/vscode/.local/bin:$PATH"
```

In shell scripts (for non-login shells):
```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Authentication

After installation, user must authenticate:

```bash
claude login
```

This creates `credentials.json` in the config directory.

**Persistence**: When using named Docker volumes for `$CLAUDE_CONFIG_DIR`, credentials persist across container rebuilds.

## Verification

Check installation:

```bash
claude --version
claude doctor
```

## Plugin Commands

```bash
# Add marketplace
claude plugin marketplace add /path/to/marketplace

# Install plugin
claude plugin install plugin-name@marketplace

# List installed
claude plugin list
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `claude: command not found` | Check PATH includes `~/.local/bin` (binary location) |
| Permission denied on config | Run `sudo chown -R $(id -u):$(id -g) $CLAUDE_CONFIG_DIR` |
| Install fails in container | Ensure curl and ca-certificates installed |
| Login fails | Check internet access, try `claude doctor` |
| UID/GID 1000 conflict | Use `getent` to check existing users before creating |

## References

- [Claude Code Setup](https://code.claude.com/docs/en/setup)
- [GitHub Issue #2986 - CLAUDE_CONFIG_DIR](https://github.com/anthropics/claude-code/issues/2986)
