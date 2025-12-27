#!/bin/bash
# Reinstall marketplace and plugins for local development
# Generated for: agentic-skills-creator
#
# Run manually or via postStartCommand
# Usage: bash reinstall-marketplace.sh [--quiet]

# Ensure Claude Code is in PATH
export PATH="$HOME/.local/bin:$PATH"

QUIET="${1:-}"
SRC="/workspaces/agentic-ai-skills-creator"
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

reinstall_marketplace() {
  local src="$1"
  local repo
  repo=$(echo "$src" | sed -E 's#^https?://github\.com/##; s#^git@github\.com:##; s#\.git$##')

  # Find marketplace name from known_marketplaces.json
  local market=""
  if [ -f "$CONFIG_DIR/plugins/known_marketplaces.json" ]; then
    market=$(jq -r --arg repo "$repo" --arg src "$src" \
      'to_entries[] | select(.value.source.repo == $repo or .value.source.path == $src or .value.source.url == $src) | .key' \
      "$CONFIG_DIR/plugins/known_marketplaces.json" 2>/dev/null || echo "")
  fi

  # Get enabled plugins for this marketplace
  local plugins_list=""
  if [ -f "$CONFIG_DIR/settings.json" ]; then
    plugins_list=$(jq -r --arg market "$market" --arg repo "$repo" \
      '.enabledPlugins // {} | keys[] | select(endswith("@" + $market) or endswith("@" + $repo))' \
      "$CONFIG_DIR/settings.json" 2>/dev/null || echo "")
  fi

  # Remove and re-add marketplace
  if [[ -n "$market" ]]; then
    claude plugin marketplace remove "$market" 2>/dev/null || true
  fi
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
