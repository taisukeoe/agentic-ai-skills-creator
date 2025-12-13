---
name: reviewing-skills
description: Review agent skills against Claude's official best practices. Use when analyzing existing skills for compliance with naming conventions, progressive disclosure, conciseness, description quality, and structural patterns. Provides detailed feedback and improvement suggestions.
---

# Reviewing Skills

Comprehensive review of agent skills against Claude's official best practices.

## Quick Start

To review a skill:

1. Ask user for skill path (e.g., `.claude/skills/skill-name/`)
2. Read SKILL.md and analyze structure
3. Check against best practices
4. Provide detailed feedback with priorities

**Example review output**:
```
## Compliance Score
- Naming: ✓ Excellent - `processing-pdfs` (gerund form)
- Description: ⚠ Needs work - Missing "when to use"
- Size: ✓ Good - 234 lines

## Important Issues
- Add "Use when..." to description for better triggering
```

## Review Process

### Step 1: Initial Analysis

Read and analyze:
- SKILL.md (frontmatter and body)
- Directory structure
- Reference files (if any)
- Scripts/assets (if any)

### Step 2: Core Compliance Checks

**Naming** (gerund form preferred):
- ✓ Good: `processing-pdfs`, `analyzing-data`, `managing-workflows`
- ✗ Avoid: `helper`, `utils`, `tools`, `anthropic-*`, `claude-*`
- Requirements: max 64 chars, lowercase/numbers/hyphens only, no XML tags

**Description** (third person, what + when):
- ✓ Specific with key terms
- ✓ Includes both what it does and when to use it
- ✗ Vague ("helps with documents")
- Requirements: non-empty, max 1024 chars, no XML tags, third person only

**SKILL.md Size**:
- Target: <500 lines (ideally 200-400)
- If >500 lines: suggest moving content to references

**Progressive Disclosure**:
- Level 1: Metadata (name + description) always loaded
- Level 2: SKILL.md body loaded when triggered
- Level 3: References loaded as needed
- Check: Are details properly split into reference files?

**Single Responsibility**:
- Does skill focus on one clear purpose?
- Or does it try to be a multi-purpose helper?

### Step 3: Detailed Structure Review

**File Organization**:
- Required: SKILL.md
- Optional but recommended: references/, scripts/, assets/
- Should NOT exist: README.md, CHANGELOG.md, INSTALLATION_GUIDE.md

**Reference Depth**:
- References should be one level deep from SKILL.md
- Avoid: SKILL.md → ref1.md → ref2.md (too nested)
- Good: SKILL.md → ref1.md, ref2.md, ref3.md

**Reference Files**:
- Files >100 lines should have table of contents
- **Check TOC presence**: If reference file >100 lines, verify table of contents exists at top
- Descriptive file names (not `doc1.md`, `misc.md`)
- Domain-specific organization when appropriate

**Content Quality**:
- Concise (only what Claude doesn't know)
- No time-sensitive information
- Consistent terminology
- Concrete examples
- Clear workflows

**Settings.json Permissions Section**:
- Should exist at end of SKILL.md
- Provides copy-paste snippet for `.claude/settings.json`
- Includes skill name: `"Skill(skill-name)"`
- Includes any Bash commands or scripts used
- Uses correct format: `"Bash(script-path:*)"` for scripts with args

### Step 4: Generate Feedback

Organize feedback by priority:

**Critical Issues** (must fix):
- Name violates requirements
- Description missing or invalid
- SKILL.md >500 lines without good reason

**Important Issues** (should fix):
- Poor naming (not gerund form, too vague)
- Weak description (missing "when to use", too vague)
- Duplicate information between SKILL.md and references
- Deeply nested references
- Missing progressive disclosure

**Suggestions** (nice to have):
- Could be more concise
- Could improve examples
- Could reorganize for clarity
- Could add reference files for long sections
- Missing Settings.json Permissions section (add copy-paste snippet)

### Step 5: Provide Actionable Feedback

For each issue:
1. Explain the problem
2. Show why it matters
3. Suggest specific fix
4. Provide example if helpful

Format:
```markdown
## Critical Issues
- **Issue**: [Problem description]
  - **Why it matters**: [Impact explanation]
  - **Fix**: [Specific action]
  - **Example**: [If applicable]

## Important Issues
[Same format]

## Suggestions
[Same format]
```

## Common Anti-Patterns to Flag

❌ **Windows-style paths**: `scripts\file.py` → should be `scripts/file.py`
❌ **Too many options**: Presenting 5+ alternatives without a default
❌ **Time-sensitive info**: "Before August 2025, use..." → use "Old patterns" section
❌ **Inconsistent terminology**: Mixing "API endpoint", "URL", "route", "path"
❌ **Deeply nested references**: More than one level from SKILL.md
❌ **Vague instructions**: "Process the data" → needs specific steps
❌ **Auxiliary docs**: README.md, CHANGELOG.md shouldn't exist

## Output Format

Structure review with these sections:
- **Summary**: Overall assessment, key strengths, areas for improvement
- **Compliance Score**: Naming, Description, Size, Progressive Disclosure, Structure (each with ✓/⚠/✗)
- **Critical Issues**: Must fix (with explanations and fixes)
- **Important Issues**: Should fix (with explanations and fixes)
- **Suggestions**: Nice to have (with improvements)
- **Next Steps**: Prioritized actions

See [references/checklist.md](references/checklist.md) for detailed criteria and full template example.

## Tips for Effective Reviews

**Be Constructive**: Always explain why something matters and how to fix it

**Prioritize**: Focus on critical issues first, then important, then nice-to-haves

**Be Specific**: "Description is vague" → "Description should include when to use the skill. Add: 'Use when...'"

**Provide Examples**: Show good and bad examples when explaining issues

**Consider Context**: Some "violations" may be justified for specific use cases

**Check References**: Don't just review SKILL.md - check if referenced files exist and are appropriate

## Reference

**Detailed Checklist**: See [references/checklist.md](references/checklist.md) for comprehensive review criteria

## Settings.json Permissions

To enable this skill, add to `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Skill(reviewing-skills)"
    ]
  }
}
```

This skill primarily uses Read and Glob tools which don't require additional Bash permissions.
