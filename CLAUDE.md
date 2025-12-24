# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Confidentiality Policy

**This project must NOT contain any confidential information from specific companies or projects.**

- Use generic placeholder names (e.g., `example-plugin`, `my-marketplace`) in all documentation and examples
- Do not reference real internal projects, tools, or organizational structures
- All skills and examples must be publicly shareable

## Project Overview

Claude Code plugin marketplace providing skills for creating and reviewing AI agent skills following Claude's official best practices.

**Two plugins included:**

1. **skills-helper** - Skills for AI agent skill development
   - `creating-effective-skills` - Guide for creating skills with 7-step workflow
   - `improving-skills` - Improve existing skills based on user feedback
   - `reviewing-skills` - Review skills against best practices with compliance checks

2. **marketplace-helper** - Skills for marketplace configuration
   - `reviewing-plugin-marketplace` - Review marketplace configurations, detect common errors

## Architecture

**Directory structure:**
```
plugins/
  skills-helper/           # Plugin for skill development
    skills/
      creating-effective-skills/
      improving-skills/
      reviewing-skills/
  marketplace-helper/      # Plugin for marketplace validation
    skills/
      reviewing-plugin-marketplace/
.claude-plugin/marketplace.json
```

**Plugin marketplace pattern (Anthropic format):**
- `.claude-plugin/marketplace.json` defines the plugins
- `source: "./plugins/<plugin-name>"` points to plugin directory (must start with `./`)
- Each plugin has its own `.claude-plugin/plugin.json` with `skills` path
- `strict: false` allows marketplace.json to serve as complete manifest

## Key Commands

**Review a marketplace configuration:**
```bash
bash plugins/marketplace-helper/skills/reviewing-plugin-marketplace/scripts/verify-marketplace.sh [marketplace-dir]
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
