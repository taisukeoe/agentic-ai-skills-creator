# Test Scenarios for setting-up-devcontainers

## Scenario: Generate devcontainer for simple marketplace

**Difficulty:** Easy

**Query:** Set up a devcontainer for my marketplace at this project root.

**Test files:**
- `.claude-plugin/marketplace.json` with 1 plugin

**Expected behaviors:**

1. Reads marketplace.json correctly
   - **Minimum:** Reads the file without errors
   - **Quality criteria:**
     - Parses JSON and extracts marketplace name
     - Extracts plugins array with source paths
     - Handles optional fields gracefully
   - **Haiku pitfall:** Fails to parse nested structure, reports file not found incorrectly
   - **Weight:** 4

2. Discovers plugins and skills
   - **Minimum:** Lists at least one plugin
   - **Quality criteria:**
     - Follows source path to plugin directory
     - Reads plugin.json or checks skills/ directory
     - Builds complete list of skill names
     - Handles skills without plugin.json
   - **Haiku pitfall:** Only reads marketplace.json, misses individual skills
   - **Weight:** 5

3. Generates valid devcontainer.json
   - **Minimum:** Creates syntactically valid JSON
   - **Quality criteria:**
     - Uses named volume for /opt/claude-config (NOT host mount)
     - Sets CLAUDE_CONFIG_DIR environment variable
     - Includes both postCreateCommand and postStartCommand
     - Volume name includes marketplace name for uniqueness
   - **Haiku pitfall:** Uses host mount for ~/.claude, forgets postStartCommand
   - **Weight:** 5

4. Generates functional Dockerfile
   - **Minimum:** Creates file with FROM ubuntu:latest
   - **Quality criteria:**
     - Installs curl, git, jq, ca-certificates, sudo, zsh
     - Creates non-root vscode user with zsh as default shell
     - Handles existing UID/GID 1000 in base image (ubuntu user)
     - Sets CLAUDE_CONFIG_DIR env and PATH for ~/.local/bin
     - Configures passwordless sudo for vscode user
     - Does NOT install Claude Code (deferred to post-create.sh)
   - **Haiku pitfall:** Installs Claude Code in Dockerfile, missing sudo/zsh, hardcodes user creation without checking existing UID
   - **Weight:** 4

5. Generates post-create.sh with correct structure
   - **Minimum:** Creates executable shell script
   - **Quality criteria:**
     - Exports PATH with $HOME/.local/bin at the beginning
     - Fixes volume ownership with sudo chown before accessing
     - Checks if Claude Code already installed using `command -v claude`
     - Generates settings.json with enabledPlugins as OBJECT (not array)
     - Includes all discovered skills in permissions.allow
     - Registers marketplace and installs plugins
   - **Haiku pitfall:** Uses array format for enabledPlugins, missing PATH export, missing sudo chown for volume
   - **Weight:** 5

6. Generates reinstall-marketplace.sh
   - **Minimum:** Creates script that can be executed
   - **Quality criteria:**
     - Exports PATH with $HOME/.local/bin at the beginning
     - Handles --quiet flag
     - Uses CLAUDE_CONFIG_DIR or fallback to $HOME/.claude
     - Properly quotes paths and handles edge cases
   - **Haiku pitfall:** Hardcodes paths, missing PATH export, missing error handling
   - **Weight:** 3

**Output validation:**
- Directory: `.devcontainer/` exists
- Files: `devcontainer.json`, `Dockerfile`, `post-create.sh`, `reinstall-marketplace.sh`
- Pattern in devcontainer.json: `"type": "volume"` (not bind mount)
- Pattern in Dockerfile: `zsh` in apt-get install list
- Pattern in Dockerfile: `-s /bin/zsh` in useradd/usermod command
- Pattern in Dockerfile: `getent group` and `getent passwd` for UID/GID handling
- Pattern in Dockerfile: `sudoers.d` for passwordless sudo
- Pattern in Dockerfile: `PATH="/home/vscode/.local/bin:$PATH"`
- Pattern in post-create.sh: `export PATH="$HOME/.local/bin:$PATH"`
- Pattern in post-create.sh: `sudo chown` for volume ownership
- Pattern in post-create.sh: `"enabledPlugins": {` (object, not array)
- Pattern in reinstall-marketplace.sh: `export PATH="$HOME/.local/bin:$PATH"`

---

## Scenario: Handle marketplace with multiple plugins

**Difficulty:** Medium

**Query:** Create devcontainer for a marketplace with skills-helper, marketplace-helper, and skills-helper-experimental plugins.

**Test files:**
- `.claude-plugin/marketplace.json` with 3 plugins
- Each plugin has 2-4 skills

**Expected behaviors:**

1. Enumerates skills from ALL plugins
   - **Minimum:** Lists skills from at least 2 plugins
   - **Quality criteria:**
     - Reads each plugin's source directory
     - Discovers skills from each plugin's skills/ directory
     - Handles different plugin structures (skills array vs directory)
     - No duplicate skills in final list
   - **Haiku pitfall:** Only processes first plugin, misses skills from later plugins
   - **Weight:** 5

2. Generates correct enabledPlugins for all plugins
   - **Minimum:** Includes at least 2 plugins
   - **Quality criteria:**
     - Uses format: `"plugin-name@marketplace-name": true`
     - All 3 plugins included
     - Object format, NOT array
   - **Haiku pitfall:** Array format, missing plugins, wrong marketplace suffix
   - **Weight:** 5

3. Generates permissions for all skills
   - **Minimum:** Includes skills from at least 2 plugins
   - **Quality criteria:**
     - Uses format: `"Skill(skill-name)"`
     - All skills from all plugins included
     - No duplicates
     - Properly formatted JSON array
   - **Haiku pitfall:** Missing skills from some plugins, syntax errors
   - **Weight:** 4

4. Generates plugin install commands
   - **Minimum:** At least 1 install command
   - **Quality criteria:**
     - One command per plugin
     - Uses correct format: `claude plugin install plugin@marketplace --scope user`
     - Commands in logical order
   - **Haiku pitfall:** Wrong install command syntax, missing --scope
   - **Weight:** 3

**Output validation:**
- enabledPlugins has exactly 3 entries
- permissions.allow has all skills from all plugins

---

## Scenario: Handle missing marketplace.json

**Difficulty:** Edge-case

**Query:** Set up devcontainer at /path/that/does/not/exist

**Expected behaviors:**

1. Reports error clearly
   - **Minimum:** Says file or path not found
   - **Quality criteria:**
     - Attempts to read .claude-plugin/marketplace.json
     - Reports specific path that was checked
     - Does NOT generate partial/broken devcontainer files
     - Clear error message for user
   - **Haiku pitfall:** Generates empty config anyway, unclear error
   - **Weight:** 5

2. Offers recovery options
   - **Minimum:** Asks for correct path
   - **Quality criteria:**
     - Suggests checking current directory
     - Offers to search for marketplace.json
     - Explains what marketplace.json should contain
   - **Haiku pitfall:** Just errors and stops without guidance
   - **Weight:** 3

**Output validation:**
- No .devcontainer/ directory created
- Error message includes "marketplace.json"

---

## Scenario: Handle existing .devcontainer directory

**Difficulty:** Edge-case

**Query:** Generate devcontainer for my marketplace (already has .devcontainer/)

**Expected behaviors:**

1. Detects existing files
   - **Minimum:** Notices files exist
   - **Quality criteria:**
     - Checks for existing .devcontainer/ directory
     - Lists which files would be overwritten
     - Does NOT silently overwrite
   - **Haiku pitfall:** Overwrites without warning
   - **Weight:** 4

2. Asks before overwriting
   - **Minimum:** Asks user
   - **Quality criteria:**
     - Offers backup option
     - Shows diff or summary of changes
     - Respects user's choice
   - **Haiku pitfall:** Proceeds without confirmation
   - **Weight:** 4

**Output validation:**
- User prompted before any writes if files exist

---

## Scenario: Marketplace with nested plugin directories

**Difficulty:** Hard

**Query:** Generate devcontainer for marketplace with plugins at ./plugins/category/plugin-name structure

**Expected behaviors:**

1. Correctly resolves relative paths
   - **Minimum:** Finds at least one plugin
   - **Quality criteria:**
     - Handles source paths like `"./plugins/helpers/skill-helper"`
     - Resolves paths relative to marketplace root
     - Validates each path exists before proceeding
   - **Haiku pitfall:** Path resolution errors, wrong base directory
   - **Weight:** 5

2. Handles deep plugin.json discovery
   - **Minimum:** Finds at least one plugin.json
   - **Quality criteria:**
     - Checks .claude-plugin/plugin.json in each source directory
     - Falls back to skills/ directory if plugin.json missing
     - Parses skills path correctly from plugin.json
   - **Haiku pitfall:** Doesn't check nested .claude-plugin/ directories
   - **Weight:** 4

3. Generates correct workspace paths
   - **Minimum:** Creates functional scripts
   - **Quality criteria:**
     - Paths in post-create.sh resolve correctly
     - Paths in reinstall-marketplace.sh work from /workspaces
     - No hardcoded absolute host paths
   - **Haiku pitfall:** Mixes host and container paths
   - **Weight:** 4

**Output validation:**
- All paths in generated files start with /workspaces or use $WORKSPACE variable

---

## Scenario: Explain devcontainer architecture

**Difficulty:** Easy

**Query:** How does the devcontainer setup work for Claude Code?

**Expected behaviors:**

1. Explains CLAUDE_CONFIG_DIR strategy
   - **Minimum:** Mentions the environment variable
   - **Quality criteria:**
     - Explains why /opt/claude-config instead of ~/.claude
     - Describes what's stored (credentials, settings, plugins config)
     - Notes Claude binary is installed to ~/.local/bin (not in volume)
     - Explains volume persistence benefits
   - **Haiku pitfall:** Vague explanation, confuses binary location with config, doesn't mention volume persistence
   - **Weight:** 4

2. Explains startup sequence
   - **Minimum:** Lists key steps
   - **Quality criteria:**
     - Describes postCreateCommand vs postStartCommand difference
     - Explains when Claude Code is installed
     - Explains when marketplace is synced
   - **Haiku pitfall:** Conflates the two commands, incomplete sequence
   - **Weight:** 3

3. Explains credential persistence
   - **Minimum:** Mentions credentials persist
   - **Quality criteria:**
     - Named volume vs bind mount comparison
     - Explains why credentials survive container rebuild
     - Notes user needs to login once
   - **Haiku pitfall:** Doesn't explain why named volume chosen
   - **Weight:** 3

**Output validation:**
- Response mentions: CLAUDE_CONFIG_DIR, named volume, postCreateCommand, postStartCommand
