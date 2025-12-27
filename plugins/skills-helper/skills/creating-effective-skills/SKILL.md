---
name: creating-effective-skills
description: Creating high-quality agent skills following Claude's official best practices. Use when designing, implementing, or improving agent skills, including naming conventions, progressive disclosure patterns, description writing, and appropriate freedom levels. Helps ensure skills are concise, well-structured, and optimized for context efficiency.
license: Apache-2.0
metadata:
  author: Softgraphy GK
  version: "0.2.0"
---

# Creating Effective Skills

Guide for creating agent skills that follow Claude's official best practices.

## Core Principles

**Concise is Key**: The context window is shared. Only add what Claude doesn't already know. Default assumption: Claude is already very smart.

**Progressive Disclosure**: Skills load in three levels:
1. Metadata (~100 tokens) - always loaded
2. SKILL.md body (<5k tokens) - when triggered
3. Bundled resources - as needed

**Keep SKILL.md small**: Target ~200 lines, maximum 500 lines. Move detailed content to reference files aggressively.

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
├── tests/
│   └── scenarios.md (required - self-evaluation scenarios)
├── scripts/ (optional)
└── assets/ (optional)
```

**README.md vs SKILL.md**:
- **SKILL.md**: Instructions for Claude (workflows, patterns, technical details)
- **README.md**: Instructions for humans (installation, permissions, overview)

**README.md must include**:
- Overview of what the skill does
- File structure explanation (especially `tests/scenarios.md` purpose)
- Installation instructions and required permissions

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

Use imperative form. Keep small (target ~200 lines, max 500). Include only:
- Quick start / basic usage
- Core workflows
- References to additional files

For complex multi-step processes, see [references/workflows-and-validation.md](references/workflows-and-validation.md).

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
    └── domain_b.md
```

Avoid: deeply nested references, duplicate information, generic file names.

### Step 7: Create Test Scenarios

Create `tests/scenarios.md` for self-evaluation with `/evaluating-skills-with-models`:

```markdown
## Scenario: [Name]

**Difficulty:** Easy | Medium | Hard | Edge-case

**Query:** User request that triggers this skill

**Expected behaviors:**

1. [Action description]
   - **Minimum:** What counts as "did it"
   - **Quality criteria:** What "did it well" looks like
   - **Haiku pitfall:** Common failure mode for smaller models
   - **Weight:** 1-5 (importance)

**Output validation:** (optional)
- Pattern: `regex`
- Line count: `< N`
```

**Why this format**: Binary pass/fail doesn't differentiate models. Quality-based scoring reveals capability differences.

### Step 8: Define allowed-tools

After completing SKILL.md and references, identify which tools the skill uses:

1. Review SKILL.md and reference files for tool usage
2. List tools that need pre-approval (e.g., `Bash(git status:*)`, `WebSearch`, `Skill(other-skill)`)
3. Add `allowed-tools` field to frontmatter if needed

```yaml
---
name: skill-name
description: ...
allowed-tools: "Bash(git status:*) Bash(git diff:*) WebSearch"
---
```

This field is experimental but helps agents pre-approve tool access.

**Important considerations**:
- `Read`, `Glob` are already allowed by default - do not include
- `Edit`, `Write` are destructive - do not pre-approve
- Be as specific as possible with Bash subcommands
  - Good: `Bash(git status:*) Bash(git diff:*) Bash(git log:*)`
  - Avoid: `Bash(git:*)` (too broad, includes destructive operations like `git push --force`)

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

**Workflows and Validation**: [references/workflows-and-validation.md](references/workflows-and-validation.md) - Creating workflows with validation and feedback loops
