---
name: setting-up-devcontainers
description: Generate devcontainer configurations for Claude Code plugin marketplaces. Use when setting up development containers, creating .devcontainer/ for a marketplace, or configuring isolated Claude Code environments with pre-registered plugins and skills.
license: Apache-2.0
metadata:
  author: Softgraphy GK
  version: "0.1.0"
---

# Setting Up Devcontainers for Claude Code Marketplaces

Generate complete `.devcontainer/` configurations for Claude Code plugin marketplaces with:
- Pre-installed Claude Code CLI
- Auto-enabled plugins and skills
- Persistent credentials via Docker volumes
- Automatic marketplace synchronization

## Quick Start

```
User: Set up a devcontainer for my marketplace
Agent: I'll analyze your marketplace.json and generate the devcontainer configuration.
```

## Workflow

### Step 1: Locate Marketplace Configuration

Find and validate `.claude-plugin/marketplace.json`:

```bash
# Check for marketplace.json
ls .claude-plugin/marketplace.json
```

If missing, ask user for correct path or offer to help create one.

**Required fields to extract**:
- `name` - Marketplace name (used for volume naming)
- `plugins` - Array of plugin definitions

### Step 2: Discover Plugins and Skills

For each plugin in `marketplace.json`:

1. Read `source` path (e.g., `"./plugins/plugin-name"`)
2. Check for `.claude-plugin/plugin.json` in source directory
3. Find `skills` path from plugin.json or use `./skills/` default
4. List all SKILL.md files in skills directory
5. Extract skill names from directory names

**Build two lists**:
- `enabledPlugins`: `{"plugin-name@marketplace-name": true, ...}`
- `allowedSkills`: `["Skill(skill-1)", "Skill(skill-2)", ...]`

### Step 3: Generate devcontainer.json

Create `.devcontainer/devcontainer.json`:

```json
{
  "name": "${MARKETPLACE_NAME}-devcontainer",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "mounts": [
    "source=claude-config-${MARKETPLACE_NAME},target=/opt/claude-config,type=volume"
  ],
  "containerEnv": {
    "CLAUDE_CONFIG_DIR": "/opt/claude-config"
  },
  "remoteUser": "vscode",
  "postCreateCommand": "bash .devcontainer/post-create.sh",
  "postStartCommand": "bash .devcontainer/reinstall-marketplace.sh"
}
```

**Key design decisions**:
- Named volume `claude-config-${MARKETPLACE_NAME}` for credential persistence
- `CLAUDE_CONFIG_DIR=/opt/claude-config` to separate binary from host config
- `postStartCommand` ensures marketplace sync on every container start

### Step 4: Generate Dockerfile

Create `.devcontainer/Dockerfile`:

```dockerfile
FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    ca-certificates \
    sudo \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user (handle case where GID/UID 1000 already exists in base image)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN if getent group $USER_GID > /dev/null 2>&1; then \
        groupmod -n $USERNAME $(getent group $USER_GID | cut -d: -f1); \
    else \
        groupadd --gid $USER_GID $USERNAME; \
    fi \
    && if getent passwd $USER_UID > /dev/null 2>&1; then \
        usermod -l $USERNAME -d /home/$USERNAME -m -s /bin/zsh $(getent passwd $USER_UID | cut -d: -f1); \
    else \
        useradd --uid $USER_UID --gid $USER_GID -m -s /bin/zsh $USERNAME; \
    fi \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Claude Code configuration directory (binary installed to ~/.local/bin)
ENV CLAUDE_CONFIG_DIR=/opt/claude-config
ENV PATH="/home/vscode/.local/bin:$PATH"

USER $USERNAME
WORKDIR /workspaces
```

**Key design decisions**:
- `zsh` as default shell for better UX
- Handle existing UID/GID 1000 in ubuntu base image
- Passwordless sudo for volume permission fixes
- PATH includes `~/.local/bin` where Claude binary installs

### Step 5: Generate post-create.sh

Create `.devcontainer/post-create.sh`:

```bash
#!/bin/bash
set -e

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-/opt/claude-config}"
WORKSPACE="/workspaces/${PROJECT_DIR}"

# Ensure Claude Code is in PATH (installed to ~/.local/bin by default)
export PATH="$HOME/.local/bin:$PATH"

echo "Setting up Claude Code devcontainer..."

# Ensure config directory has correct ownership (volume may be owned by root initially)
if [ -d "$CONFIG_DIR" ]; then
    sudo chown -R $(id -u):$(id -g) "$CONFIG_DIR"
else
    sudo mkdir -p "$CONFIG_DIR"
    sudo chown -R $(id -u):$(id -g) "$CONFIG_DIR"
fi

# Install Claude Code if not present
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo "Claude Code already installed."
fi

# Generate settings.json with enabled plugins and permissions
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_DIR/settings.json" << 'SETTINGS_EOF'
{
  "enabledPlugins": {
${ENABLED_PLUGINS_JSON}
  },
  "permissions": {
    "allow": [
${ALLOWED_SKILLS_JSON}
    ]
  }
}
SETTINGS_EOF

# Register marketplace and install plugins
claude plugin marketplace add "$WORKSPACE" || true
${PLUGIN_INSTALL_COMMANDS}

echo ""
echo "======================================"
echo "Claude Code devcontainer ready!"
echo ""
echo "Run 'claude login' to authenticate."
echo "Your credentials will persist across container rebuilds."
echo "======================================"
```

**Key implementation details**:
- Export PATH with `~/.local/bin` for non-login shell scripts
- Fix volume ownership with `sudo chown` before accessing
- Use `command -v claude` to check installation (not file path)
- Use `|| true` to continue if marketplace already registered

**Dynamic content to substitute**:
- `${PROJECT_DIR}` - Project directory name
- `${ENABLED_PLUGINS_JSON}` - Object entries like `"plugin@market": true`
- `${ALLOWED_SKILLS_JSON}` - Array entries like `"Skill(name)"`
- `${PLUGIN_INSTALL_COMMANDS}` - Plugin install commands

### Step 6: Generate reinstall-marketplace.sh

Create `.devcontainer/reinstall-marketplace.sh`:

```bash
#!/bin/bash
# Reinstall marketplace and plugins for local development
# Run manually or via postStartCommand
# Usage: bash reinstall-marketplace.sh [--quiet]

# Ensure Claude Code is in PATH (installed to ~/.local/bin by default)
export PATH="$HOME/.local/bin:$PATH"

QUIET="${1:-}"
SRC="/workspaces/${PROJECT_DIR}"
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

reinstall_marketplace() {
  local src="$1"
  local repo=$(echo "$src" | sed -E 's#^https?://github\.com/##; s#^git@github\.com:##; s#\.git$##')

  # Find marketplace name from known_marketplaces.json
  local market=""
  if [ -f "$CONFIG_DIR/plugins/known_marketplaces.json" ]; then
    market=$(jq -r --arg repo "$repo" --arg src "$src" \
      'to_entries[] | select(.value.source.repo == $repo or .value.source.path == $src or .value.source.url == $src) | .key' \
      "$CONFIG_DIR/plugins/known_marketplaces.json" 2>/dev/null)
  fi

  # Get enabled plugins for this marketplace
  local plugins_list=""
  if [ -f "$CONFIG_DIR/settings.json" ]; then
    plugins_list=$(jq -r --arg market "$market" --arg repo "$repo" \
      '.enabledPlugins // {} | keys[] | select(endswith("@" + $market) or endswith("@" + $repo))' \
      "$CONFIG_DIR/settings.json" 2>/dev/null)
  fi

  # Remove and re-add marketplace
  [[ -n "$market" ]] && claude plugin marketplace remove "$market" 2>/dev/null || true
  claude plugin marketplace add "$src"

  # Reinstall plugins
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    claude plugin uninstall "$p" 2>/dev/null || true
    claude plugin install "$p" --scope user
  done <<< "$plugins_list"
}

[[ "$QUIET" != "--quiet" ]] && echo "Reinstalling marketplace from $SRC..."
reinstall_marketplace "$SRC"
[[ "$QUIET" != "--quiet" ]] && echo "Done."
```

### Step 7: Write Files and Provide Instructions

1. Create `.devcontainer/` directory if not exists
2. Write all generated files:
   - `devcontainer.json`
   - `Dockerfile`
   - `post-create.sh`
   - `reinstall-marketplace.sh`
3. Make shell scripts executable: `chmod +x .devcontainer/*.sh`

**Provide usage instructions**:

```
Devcontainer files created in .devcontainer/

To use:
1. Open project in VS Code
2. Click "Reopen in Container" when prompted
   (or use Command Palette: "Dev Containers: Reopen in Container")
3. Run 'claude login' on first use

Your credentials persist in the Docker volume 'claude-config-${MARKETPLACE_NAME}'.

To manually sync marketplace changes:
  bash .devcontainer/reinstall-marketplace.sh
```

## Generated File Locations

```
.devcontainer/
├── devcontainer.json      # Container configuration
├── Dockerfile             # Ubuntu + dependencies
├── post-create.sh         # Initial setup (Claude install, config)
└── reinstall-marketplace.sh  # Marketplace sync script
```

## Key Configuration Details

### Volume Strategy

Uses `CLAUDE_CONFIG_DIR=/opt/claude-config` with named Docker volume:

```
~/.local/bin/
└── claude                   # Claude Code binary (NOT in volume)

/opt/claude-config/          # Named volume (persistent)
├── settings.json            # User settings
├── credentials.json         # Auth tokens
└── plugins/                 # Plugin data
```

**Important**: The Claude binary is always installed to `~/.local/bin/claude`, not the config directory. `CLAUDE_CONFIG_DIR` only controls where configuration files are stored.

Benefits:
- Credentials persist across container rebuilds
- Configuration isolated from host
- No host directory conflicts

### Plugin Format

**enabledPlugins** must be object format (not array):

```json
{
  "enabledPlugins": {
    "plugin-a@marketplace": true,
    "plugin-b@marketplace": true
  }
}
```

### Marketplace Sync

`reinstall-marketplace.sh` handles:
- Local filesystem changes to skills
- Plugin updates
- Marketplace configuration changes

Runs automatically on container start via `postStartCommand`.

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| marketplace.json not found | Wrong path | Ask user for correct marketplace path |
| No plugins found | Empty plugins array | Warn user, generate minimal config |
| Source path invalid | Plugin source doesn't exist | Report error, skip invalid plugins |
| Existing .devcontainer/ | Files already present | Ask before overwriting |
| GID/UID 1000 already exists | Ubuntu base image has existing user | Use `getent` to detect and rename existing user |
| Permission denied on config | Volume owned by root | Use `sudo chown` in post-create.sh |
| claude: command not found | PATH not set | Export `PATH="$HOME/.local/bin:$PATH"` in scripts |

## References

- [Devcontainer Specification](references/devcontainer-spec.md)
- [Claude Code Installation](references/claude-code-installation.md)
