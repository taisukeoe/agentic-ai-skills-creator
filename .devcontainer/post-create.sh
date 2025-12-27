#!/bin/bash
# Post-create script for Claude Code devcontainer
# Generated for: agentic-skills-creator
set -e

CONFIG_DIR="$HOME/.claude"
WORKSPACE="/workspaces/agentic-ai-skills-creator"

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

# Symlink ~/.claude.json to persist it inside the volume
# (Claude Code stores setup state in this file)
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
    "skills-helper@agentic-skills-creator": true,
    "marketplace-helper@agentic-skills-creator": true,
    "skills-helper-experimental@agentic-skills-creator": true
  },
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
    claude plugin install skills-helper@agentic-skills-creator --scope user || true
    claude plugin install marketplace-helper@agentic-skills-creator --scope user || true
    claude plugin install skills-helper-experimental@agentic-skills-creator --scope user || true
else
    echo "Claude not yet set up. Run 'claude' to complete setup, then run:"
    echo "  bash .devcontainer/reinstall-marketplace.sh"
fi

echo ""
echo "======================================"
echo "Claude Code devcontainer ready!"
echo ""
echo "Run 'claude login' to authenticate."
echo "Your credentials will persist across container rebuilds."
echo "======================================"
