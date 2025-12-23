---
name: creating-effective-skills
description: Creating high-quality agent skills following Claude's official best practices. Use when designing, implementing, or improving agent skills, including naming conventions, progressive disclosure patterns, description writing, and appropriate freedom levels. Helps ensure skills are concise, well-structured, and optimized for context efficiency.
license: Apache-2.0
metadata:
  author: Softgraphy GK
  version: "0.1.0"
---

# Creating Effective Skills

Guide for creating agent skills that follow Claude's official best practices.

## Core Principles

**Concise is Key**: The context window is shared. Only add what Claude doesn't already know. Default assumption: Claude is already very smart.

**Progressive Disclosure**: Skills load in three levels:
1. Metadata (~100 tokens) - always loaded
2. SKILL.md body (<5k tokens) - when triggered
3. Bundled resources - as needed

Keep SKILL.md under 500 lines. Move detailed content to reference files.

**Single Responsibility**: Each skill does one thing well.

## Workflow

### Step 1: Understand the Skill Need

Ask the user:
- "What functionality should this skill support?"
- "Can you give examples of how this skill would be used?"
- "What would trigger this skill?"

Get clear sense of: purpose, usage examples, triggers.

### Step 2: Determine Freedom Level

Based on the skill's nature, determine appropriate degree of freedom:

**High freedom** (text instructions): Multiple approaches valid, context-dependent decisions
**Medium freedom** (templates + parameters): Preferred pattern exists, some variation acceptable
**Low freedom** (exact scripts): Fragile operations, consistency critical

If uncertain, ask the user. See [references/degrees-of-freedom.md](references/degrees-of-freedom.md) for guidance.

### Step 3: Plan Reusable Contents

Identify what to include:

**Scripts** (`scripts/`): Executable code for deterministic operations
**References** (`references/`): Documentation loaded as needed
**Assets** (`assets/`): Files used in output (templates, images, fonts)

### Step 4: Create Structure

```
skill-name/
├── SKILL.md (required - AI agent instructions)
├── README.md (optional - human-facing installation and usage guide)
├── references/ (optional)
├── scripts/ (optional)
└── assets/ (optional)
```

**README.md vs SKILL.md**:
- **SKILL.md**: Instructions for Claude (workflows, patterns, technical details)
- **README.md**: Instructions for humans (installation, permissions, overview)

**Avoid creating**: INSTALLATION_GUIDE.md, CHANGELOG.md, or other redundant docs. Use README.md for human-facing documentation.

### Step 5: Write SKILL.md

#### Frontmatter

```yaml
---
name: skill-name
description: What the skill does and when to use it
---
```

**Naming** (use gerund form):
- Good: `processing-pdfs`, `analyzing-spreadsheets`, `managing-databases`
- Avoid: `helper`, `utils`, `tools`, `anthropic-*`, `claude-*`

**Description** (third person, include WHAT and WHEN):
- Good: "Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."
- Avoid: "Helps with documents", "Processes data"

Be specific and include key terms. Description is the primary triggering mechanism.

#### Body

Use imperative form. Keep under 500 lines. Include:
- Quick start / basic usage
- Core workflows (for complex multi-step processes, see [references/workflows-and-validation.md](references/workflows-and-validation.md))
- References to additional files

Example pattern:
```markdown
## Quick start
[Basic usage]

## Advanced features
**Feature A**: See [references/feature-a.md](references/feature-a.md)
**Feature B**: See [references/feature-b.md](references/feature-b.md)
```

Keep references one level deep. See [references/progressive-disclosure.md](references/progressive-disclosure.md) for patterns.

### Step 6: Create Reference Files

For files >100 lines, include table of contents at top.

Organize by domain when appropriate:
```
skill/
├── SKILL.md
└── references/
    ├── domain_a.md
    ├── domain_b.md
    └── domain_c.md
```

Avoid: deeply nested references, duplicate information, generic file names.

### Step 7: Configure Permissions in Settings

Skills in `.claude/skills/` are automatically discovered. Configure permissions in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Skill(skill-name)"
    ]
  }
}
```

If the file already exists, add to the array:

```json
{
  "permissions": {
    "allow": [
      "Skill(existing-skill)",
      "Skill(skill-name)"
    ]
  }
}
```

**Include tool permissions for commands used by the skill**:

If skill uses **specific scripts**:
```json
{
  "permissions": {
    "allow": [
      "Skill(skill-name)",
      "Bash(scripts/verify-marketplace.sh)",
      "Bash(python scripts/validate.py)",
      "Bash(node scripts/process_data.js)"
    ]
  }
}
```

If skill uses **web data or other tools**:
```json
{
  "permissions": {
    "allow": [
      "Skill(skill-name)",
      "WebFetch(domain:api.example.com)",
      "Read(data/**)",
      "Edit(output/**)"
    ]
  }
}
```

**Guidelines**:
- Skills are auto-discovered from `.claude/skills/`
- Only list scripts explicitly referenced in SKILL.md or references
- Use exact commands (e.g., `python scripts/validate.py`), not wildcards like `scripts/*`
- Specify exact domains for WebFetch
- Use path patterns for Read/Edit (e.g., `data/**`, `*.json`)

**Document permissions in README.md**:

Create a README.md with installation instructions for users:

```markdown
## Installation

### Required Permissions

To enable this skill, add to `.claude/settings.json`:

\`\`\`json
{
  "permissions": {
    "allow": [
      "Skill(skill-name)",
      "Bash(scripts/validate.py)"
    ]
  }
}
\`\`\`
```

README.md is for human users; SKILL.md is for Claude.

### Step 8: Test and Iterate

1. Use skill on real tasks
2. Notice where Claude struggles/succeeds
3. Identify improvements
4. Update SKILL.md or resources
5. Test again

## Anti-Patterns

❌ Windows-style paths (`scripts\file.py`)
❌ Too many options without a default
❌ Time-sensitive information
❌ Inconsistent terminology
❌ Deeply nested references
❌ Vague instructions

## References

**Progressive Disclosure**: [references/progressive-disclosure.md](references/progressive-disclosure.md) - Detailed patterns and examples

**Degrees of Freedom**: [references/degrees-of-freedom.md](references/degrees-of-freedom.md) - Guidance on appropriate freedom levels

**Workflows and Validation**: [references/workflows-and-validation.md](references/workflows-and-validation.md) - Creating workflows with validation, feedback loops, and verifiable intermediate outputs
