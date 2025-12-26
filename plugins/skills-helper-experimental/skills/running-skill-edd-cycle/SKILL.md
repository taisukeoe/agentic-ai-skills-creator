---
name: running-skill-edd-cycle
description: Guides evaluation-driven development (EDD) process for agent skills. Use when setting up skill testing workflows, creating skill evaluation scenarios, or establishing Claude A/B feedback loops for skill validation. Provides development methodology, not content guidance.
license: Apache-2.0
allowed-tools: "Skill(creating-effective-skills) Skill(improving-skills) Skill(reviewing-skills)"
metadata:
  author: Softgraphy GK
  version: "0.2.0"
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

**REQUIRED:** Run `/creating-effective-skills` before writing any skill content. This ensures proper naming, description format, and structure from the start.

### Step 4: Evaluate with Multiple Models

> **Note:** This step requires Claude Code CLI. Skip this step if using Claude.ai (model selection not available).

Run skill with each model, then evaluate results in parent session:

**Phase 1: Execute (per model)**

Spawn Task sub-agents for each model. Agent only **executes** and returns raw output:

```
Execute the skill at {skill_path} with this query:
{evaluation_query}

Return:
- Raw output/files generated
- Actions taken (tools used, files read/written)
- Any errors encountered

Do NOT evaluate pass/fail. Just report what happened.
```

**Phase 2: Evaluate (parent session)**

Collect all raw outputs and evaluate in parent session (consistent criteria):

1. Compare outputs against expected_behavior
2. Rate each model's compatibility
3. Note observations (activation timing, missed references, etc.)

**Compatibility ratings:**

| Rating | Meaning |
|--------|---------|
| ✅ Full | All evaluations pass |
| ⚠️ Partial | Some pass, or requires workarounds |
| ❌ None | Does not function correctly |

**After evaluation:**

1. Determine recommended model (lowest tier with ✅ Full)
2. Document in skill's description or metadata

**REQUIRED:** Run `/improving-skills` when observations reveal issues.

### Step 5: Final Review

Before considering the skill complete:

**REQUIRED:** Run `/reviewing-skills` to verify compliance with best practices.

1. Address all compliance issues identified
2. Re-run evaluations after fixes
3. Repeat until skill passes review

### Step 6: User Validation Guide

After all reviews pass, output instructions for user to validate in a fresh session:

```
## Test Your Skill

Run this command in a new terminal to test with a fresh Claude session:

claude --model {recommended_model} "{evaluation_query}"

After testing, paste the output file or result back to this session for final confirmation.
```

Replace:
- `{recommended_model}`: Model determined in Step 4 (e.g., `sonnet`)
- `{evaluation_query}`: A representative query from your evaluations

## Quick Reference

### Cycle

```
Identify gaps -> Create evaluations -> Baseline -> Write minimal -> Model eval (sub-agents) -> Review -> User validation
```

### What Observations Indicate

| Observation | Indicates |
|-------------|-----------|
| Unexpected file reading order | Structure not intuitive |
| Missed references | Links need to be explicit |
| Repeated reads of same file | Move content to SKILL.md |
| Never accessed file | Unnecessary or poorly signaled |
