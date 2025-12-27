#!/bin/bash
# Post-create script for Claude Code devcontainer
# Generated for: agentic-skills-creator
set -e

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-/opt/claude-config}"
WORKSPACE="/workspaces/agentic-ai-skills-creator"

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

# Register marketplace
echo "Registering marketplace..."
claude plugin marketplace add "$WORKSPACE" || true

# Install plugins
echo "Installing plugins..."
claude plugin install skills-helper@agentic-skills-creator --scope user
claude plugin install marketplace-helper@agentic-skills-creator --scope user
claude plugin install skills-helper-experimental@agentic-skills-creator --scope user

echo ""
echo "======================================"
echo "Claude Code devcontainer ready!"
echo ""
echo "Run 'claude login' to authenticate."
echo "Your credentials will persist across container rebuilds."
echo "======================================"
