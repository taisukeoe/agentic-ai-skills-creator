# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Confidentiality Policy

**This project must NOT contain any confidential information from specific companies or projects.**

- Use generic placeholder names (e.g., `example-plugin`, `my-marketplace`) in all documentation and examples
- Do not reference real internal projects, tools, or organizational structures
- All skills and examples must be publicly shareable

## Project Overview

Claude Code plugin marketplace providing skills for creating and reviewing AI agent skills following Claude's official best practices.

**Three skills included:**
- `creating-effective-skills` - Guide for creating skills with 8-step workflow
- `reviewing-skills` - Review skills against best practices with compliance checks
- `reviewing-plugin-marketplace` - Review marketplace configurations, detect common errors

## Architecture

**Directory structure:**
```
plugins/skills-helper/     # Plugin root
  skills/                  # Skills directory
    creating-effective-skills/
    reviewing-skills/
    reviewing-plugin-marketplace/
.claude/skills/            # Symlink → plugins/skills-helper/skills/
.claude-plugin/marketplace.json
```

**Dual-purpose structure via symlink:**
- `.claude/skills/` → symlink to `plugins/skills-helper/skills/`
- Local dev: Skills auto-discovered from `.claude/skills/`
- Distribution: Skills packaged from `plugins/skills-helper/` via marketplace.json

**Plugin marketplace pattern (Anthropic format):**
- `.claude-plugin/marketplace.json` defines the plugin
- `source: "./plugins/skills-helper"` points to plugin directory (must start with `./`)
- Skills auto-discovered from `skills/` subdirectory (no explicit `skills` array needed)
- `strict: false` allows marketplace.json to serve as complete manifest
- No separate plugin.json needed at root

## Key Commands

**Review a marketplace configuration:**
```bash
bash plugins/skills-helper/skills/reviewing-plugin-marketplace/scripts/verify-marketplace.sh [marketplace-dir]
```

## Critical Knowledge

**enabledPlugins format in settings.json:**
- WRONG (array): `"enabledPlugins": ["plugin@marketplace"]`
- CORRECT (object): `"enabledPlugins": {"plugin@marketplace": true}`

**Skill naming:** Use gerund form (e.g., `processing-pdfs`, `reviewing-skills`)

**Skill description:** Third person, include WHAT it does and WHEN to use it

**SKILL.md size:** Keep under 500 lines, move details to references/

**Reference depth:** One level deep from SKILL.md only

**Settings.json permissions format:**
- Skills: `"Skill(skill-name)"`
- Bash commands: `"Bash(command:*)"` for wildcards

## When Editing Skills

Each SKILL.md must include at the end:
- "Settings.json Permissions" section with copy-paste snippet for users
