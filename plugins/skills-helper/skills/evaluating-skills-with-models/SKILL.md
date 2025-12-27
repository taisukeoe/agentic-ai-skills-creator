---
name: evaluating-skills-with-models
description: Evaluate agent skills across multiple Claude models (sonnet, opus, haiku) using sub-agents and compare results. Use when testing skill compatibility across models, determining recommended model for a skill, or comparing model performance on skill execution.
license: Apache-2.0
metadata:
  author: Softgraphy GK
  version: "0.2.0"
---

# Evaluating Skills with Models

Evaluate skills across multiple Claude models using sub-agents.

> **Requirement:** Claude Code CLI only. Not available in Claude.ai.

## Workflow

### Step 1: Load Test Scenarios

Check for `tests/scenarios.md` in the target skill directory:

**If exists:** Parse and use scenarios automatically.

**If not exists:** Ask user for:
- `evaluation_query`: User request that triggers the skill
- `expected_behavior`: List of observable actions to verify

**scenarios.md format:**

```markdown
## Scenario: [Name]

**Query:** User request that triggers this skill

**Expected behavior:**
- Observable action 1
- Observable action 2

**Test files:** (optional)
- path/to/test-file.ext
```

For detailed evaluation structure and best practices, see [references/evaluation-structure.md](references/evaluation-structure.md).

### Step 2: Execute with Sub-Agents (Phase 1)

Spawn Task sub-agents for each model in parallel. Each agent only **executes** and returns raw output.

**Prompt template for each sub-agent:**

```
Execute the skill at {skill_path} with this query:
{evaluation_query}

Return:
- Raw output/files generated
- Actions taken (tools used, files read/written)
- Any errors encountered

Do NOT evaluate pass/fail. Just report what happened.
```

**Model parameter options:** `sonnet`, `opus`, `haiku`

Use the Task tool with `model` parameter to specify each model.

### Step 3: Collect Results

Wait for all sub-agents to complete. Gather:

- Raw outputs from each model
- Actions taken
- Errors encountered

### Step 4: Evaluate in Parent Session (Phase 2)

Evaluate all results with consistent criteria:

1. Compare each output against `expected_behavior`
2. Rate compatibility for each model
3. Note observations

**Compatibility ratings:**

| Rating | Meaning |
|--------|---------|
| ✅ Full | All expected behaviors observed |
| ⚠️ Partial | Some behaviors observed, or requires workarounds |
| ❌ None | Does not function correctly |

### Step 5: Determine Recommended Model

Select the **least capable model** with ✅ Full compatibility:

1. If haiku passes: recommend `haiku` (fastest, lowest cost)
2. If only sonnet passes: recommend `sonnet` (balanced)
3. If only opus passes: recommend `opus` (most capable)

### Step 6: Output Summary

Provide evaluation report:

```markdown
## Model Evaluation Results

**Skill:** {skill_path}
**Query:** {evaluation_query}

| Model | Rating | Notes |
|-------|--------|-------|
| haiku | ⚠️ Partial | Missed reference file |
| sonnet | ✅ Full | All behaviors observed |
| opus | ✅ Full | All behaviors observed |

**Recommended model:** sonnet

### Observations
- [List specific behaviors per model]
```

## Observation Indicators

| Observation | Indicates |
|-------------|-----------|
| Model skips skill activation | Description not triggering |
| Unexpected file reading order | Structure not intuitive |
| Missed references | Links need to be explicit |
| Model-specific failures | May need simpler instructions |

## Quick Reference

```
Prepare query -> Execute (parallel sub-agents) -> Collect -> Evaluate -> Recommend model
```
