---
name: running-skill-edd-cycle
description: Guides evaluation-driven development (EDD) process for agent skills. Use when setting up skill testing workflows, creating skill evaluation scenarios, or establishing Claude A/B feedback loops for skill validation. Provides development methodology, not content guidance.
license: Apache-2.0
allowed-tools: "Skill(creating-effective-skills) Skill(improving-skills)"
metadata:
  author: Softgraphy GK
  version: "0.1.0"
---

# Running Skill EDD Cycle

Run evaluation-driven development cycle for agent skills.

## Workflow

### Step 1: Build Evaluations First

Create evaluations BEFORE writing documentation. This ensures skills solve real problems.

1. Run Claude on representative tasks WITHOUT the skill
2. Document specific failures or missing context
3. Create 3+ evaluation scenarios that test these gaps

**Evaluation structure:** See [references/evaluation-structure.md](references/evaluation-structure.md)

```json
{
  "skills": ["skill-name"],
  "query": "User request that triggers this skill",
  "files": ["test-files/sample.ext"],
  "expected_behavior": ["Observable action 1", "Observable action 2"]
}
```

### Step 2: Establish Baseline

Measure Claude's performance WITHOUT the skill:

1. Run each evaluation scenario
2. Record: success/failure, missing context, wrong approaches
3. This becomes comparison baseline

### Step 3: Write Minimal Instructions

Create just enough content to address the gaps:

- Start with core workflow only
- Add detail only when tests fail
- Avoid over-explaining

Use **creating-effective-skills** for content guidance (naming, description, structure).

### Step 4: Test with Multiple Models

| Model | Focus |
|-------|-------|
| **Haiku** | Enough guidance? |
| **Sonnet** | Clear and efficient? |
| **Opus** | Avoid over-explaining? |

### Step 5: Iterate with Claude A/B Pattern

- **Claude A**: Designs and refines the skill
- **Claude B**: Tests skill in real tasks (fresh instance with skill loaded)

**Observation checklist:**

- [ ] Skill activates when expected?
- [ ] Instructions clear?
- [ ] Unexpected exploration paths?
- [ ] Missed references?
- [ ] Overreliance on sections?
- [ ] Ignored content?

Bring observations back to Claude A for improvements.

Use **improving-skills** when observations reveal specific issues to fix.

## Quick Reference

### Cycle

```
Identify gaps -> Create evaluations -> Baseline -> Write minimal -> Iterate
```

### What Observations Indicate

| Observation | Indicates |
|-------------|-----------|
| Unexpected file reading order | Structure not intuitive |
| Missed references | Links need to be explicit |
| Repeated reads of same file | Move content to SKILL.md |
| Never accessed file | Unnecessary or poorly signaled |
