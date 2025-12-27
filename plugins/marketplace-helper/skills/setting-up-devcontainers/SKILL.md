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
    "source=claude-config-${MARKETPLACE_NAME},target=/home/vscode/.claude,type=volume",
    "source=claude-data-${MARKETPLACE_NAME},target=/home/vscode/.local/share/claude,type=volume"
  ],
  "remoteUser": "vscode",
  "postCreateCommand": "bash .devcontainer/post-create.sh",
  "postStartCommand": "bash .devcontainer/reinstall-marketplace.sh"
}
```

**Key design decisions**:
- Two named volumes for persistence:
  - `claude-config-${MARKETPLACE_NAME}` → `~/.claude` (config, credentials, settings)
  - `claude-data-${MARKETPLACE_NAME}` → `~/.local/share/claude` (binary)
- `~/.claude.json` (setup state) is symlinked to `~/.claude/.home-claude.json` in post-create.sh
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

# Claude Code: binary at ~/.local/bin, config at ~/.claude (both defaults)
ENV PATH="/home/vscode/.local/bin:$PATH"

USER $USERNAME
WORKDIR /workspaces
```

**Key design decisions**:
- `zsh` as default shell for better UX
- Handle existing UID/GID 1000 in ubuntu base image
- Passwordless sudo for volume permission fixes
- PATH includes `~/.local/bin` where Claude binary is installed

### Step 5: Generate post-create.sh

Create `.devcontainer/post-create.sh`:

```bash
#!/bin/bash
set -e

CONFIG_DIR="$HOME/.claude"
WORKSPACE="/workspaces/${PROJECT_DIR}"

# Ensure Claude Code is in PATH
export PATH="$HOME/.local/bin:$PATH"

echo "Setting up Claude Code devcontainer..."

# Ensure required directories have correct ownership (volumes may be owned by root initially)
for dir in "$CONFIG_DIR" "$HOME/.local/share/claude" "$HOME/.local/state" "$HOME/.local/bin"; do
    if [ -d "$dir" ]; then
        sudo chown -R $(id -u):$(id -g) "$dir"
    else
        sudo mkdir -p "$dir"
        sudo chown -R $(id -u):$(id -g) "$dir"
    fi
done

# Symlink ~/.claude.json to persist setup state inside the volume
# (Claude Code stores initial setup completion state in this file)
CLAUDE_JSON_IN_VOLUME="$CONFIG_DIR/.home-claude.json"
if [ -d "$HOME/.claude.json" ]; then
    # Remove if it's a directory (from failed volume mount)
    rm -rf "$HOME/.claude.json"
fi
if [ ! -L "$HOME/.claude.json" ]; then
    # Create valid empty JSON if not exists
    [ ! -f "$CLAUDE_JSON_IN_VOLUME" ] && echo '{}' > "$CLAUDE_JSON_IN_VOLUME"
    ln -sf "$CLAUDE_JSON_IN_VOLUME" "$HOME/.claude.json"
fi

# Install Claude Code if not present
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo "Claude Code already installed."
fi

# Generate settings.json with enabled plugins and permissions (only if not exists)
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_DIR/settings.json" ]; then
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
  echo "Settings configured."
else
  echo "Settings already exist, skipping."
fi

# Register marketplace and install plugins (only if Claude is already set up)
# Skip if not set up yet - user needs to run 'claude' first to complete setup
if [ -s "$CLAUDE_JSON_IN_VOLUME" ] && [ "$(cat "$CLAUDE_JSON_IN_VOLUME")" != "{}" ]; then
    echo "Registering marketplace..."
    claude plugin marketplace add "$WORKSPACE" || true

    echo "Installing plugins..."
${PLUGIN_INSTALL_COMMANDS}
else
    echo "Claude not yet set up. Run 'claude' to complete setup, then run:"
    echo "  bash .devcontainer/reinstall-marketplace.sh"
fi

echo ""
echo "======================================"
echo "Claude Code devcontainer ready!"
echo ""
echo "Run 'claude' to complete initial setup (first time only)."
echo "Your credentials will persist across container rebuilds."
echo "======================================"
```

**Key implementation details**:
- Export PATH with `~/.local/bin` for non-login shell scripts
- Fix ownership of all required directories (volumes may be root-owned initially)
- Symlink `~/.claude.json` → `~/.claude/.home-claude.json` to persist setup state
- Create valid empty JSON `{}` (not empty file) to avoid parse errors
- Only write `settings.json` if not exists (preserve user modifications)
- Only run plugin commands if Claude setup is complete (check `~/.claude.json` content)
- Use `|| true` to continue if commands fail

**Dynamic content to substitute**:
- `${PROJECT_DIR}` - Project directory name
- `${ENABLED_PLUGINS_JSON}` - Object entries like `"plugin@market": true`
- `${ALLOWED_SKILLS_JSON}` - Array entries like `"Skill(name)"`
- `${PLUGIN_INSTALL_COMMANDS}` - Plugin install commands (with `|| true`)

### Step 6: Generate reinstall-marketplace.sh

Create `.devcontainer/reinstall-marketplace.sh`:

```bash
#!/bin/bash
# Reinstall marketplace and plugins for local development
# Run manually or via postStartCommand
# Usage: bash reinstall-marketplace.sh [--quiet]

# Ensure Claude Code is in PATH
export PATH="$HOME/.local/bin:$PATH"

QUIET="${1:-}"
SRC="/workspaces/${PROJECT_DIR}"
CONFIG_DIR="$HOME/.claude"

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

Uses two named Docker volumes plus a symlink for complete persistence:

```
Volume 1: claude-config-${MARKETPLACE_NAME} → ~/.claude/
├── .home-claude.json        # Setup state (symlink target)
├── .credentials.json        # Auth tokens
├── settings.json            # User settings
└── plugins/                 # Plugin data

Volume 2: claude-data-${MARKETPLACE_NAME} → ~/.local/share/claude/
└── versions/
    └── X.X.X                # Claude Code binary

Symlink (created by post-create.sh):
~/.claude.json → ~/.claude/.home-claude.json
```

**Why three persistence mechanisms?**

| Location | Purpose | Persistence Method |
|----------|---------|-------------------|
| `~/.claude/` | Config, credentials, settings | Volume mount |
| `~/.local/share/claude/` | Binary (216MB) | Volume mount |
| `~/.claude.json` | Initial setup state | Symlink to volume |

**Important**: `~/.claude.json` cannot be directly mounted as a volume (Docker creates a directory instead of a file). The symlink approach allows the file to persist inside the `~/.claude/` volume.

Benefits:
- All Claude state persists across container rebuilds
- No re-login or re-setup required after rebuild
- Binary cached in volume (faster rebuilds)
- Configuration isolated from host

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
| EISDIR on ~/.claude.json | Volume mounted as directory | Remove directory, use symlink instead |
| JSON Parse error: Unexpected EOF | Empty ~/.claude.json file | Initialize with `{}` not empty file |
| Raw mode not supported | Plugin commands in non-interactive shell | Only run plugin commands if setup complete |
| Login required after rebuild | ~/.claude.json not persisted | Symlink to file inside volume |

## References

- [Devcontainer Specification](references/devcontainer-spec.md)
- [Claude Code Installation](references/claude-code-installation.md)
