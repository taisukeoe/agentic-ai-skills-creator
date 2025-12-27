---
name: evaluating-skills-with-models
description: Evaluate skills by executing them across sonnet, opus, and haiku models using sub-agents. Use when testing if a skill works correctly, comparing model performance, or finding the cheapest compatible model. Returns numeric scores (0-100) to differentiate model capabilities.
license: Apache-2.0
metadata:
  author: Softgraphy GK
  version: "0.2.0"
---

# Evaluating Skills with Models

Evaluate skills across multiple Claude models using sub-agents with quality-based scoring.

> **Requirement:** Claude Code CLI only. Not available in Claude.ai.

## Why Quality-Based Scoring

Binary pass/fail ("did it do X?") fails to differentiate models - all models can "do the steps." The difference is **how well** they do them. This skill uses weighted scoring to reveal capability differences.

## Workflow

### Step 1: Load Test Scenarios

Check for `tests/scenarios.md` in the target skill directory.

**Required scenario format:**

```markdown
## Scenario: [Name]

**Difficulty:** Easy | Medium | Hard | Edge-case

**Query:** User request that triggers this skill

**Expected behaviors:**

1. [Action description]
   - **Minimum:** What counts as "did it"
   - **Quality criteria:** What "did it well" looks like
   - **Haiku pitfall:** Common failure mode
   - **Weight:** 1-5

**Output validation:** (optional)
- Pattern: `regex`
- Line count: `< N`
```

**If scenarios.md missing or uses old format:** Ask user to update following [references/evaluation-structure.md](references/evaluation-structure.md).

### Step 2: Execute with Sub-Agents (Phase 1)

Spawn Task sub-agents for each model in parallel.

**Prompt template:**

```
Execute the skill at {skill_path} with this query:
{evaluation_query}

IMPORTANT:
- Actually execute the skill, don't just describe what you would do.
- Create output directory under Claude Code's working directory ($PWD):
  $PWD/.ai_text/{yyyyMMdd}/tmp/{skill_name}-{model}-{hhmmss}/
  (Example: If $PWD=/path/to/project, create /path/to/project/.ai_text/20250101/tmp/formatting-tables-haiku-143052/)
- Create all output files under that directory.
- If the skill asks questions, record the exact questions, then assume reasonable answers and proceed.

Return ONLY (keep it brief to minimize tokens):
- Questions skill asked: [list exact questions the skill asked you, or "none"]
- Assumed answers: [your assumed answers to those questions, or "n/a"]
- Key decisions: [1-2 sentences on freedom level, structure choices]
- Files created: [paths only, no content]
- Errors: [any errors, or "none"]

Do NOT include file contents or detailed explanations.
```

Use Task tool with `model` parameter: `haiku`, `sonnet`, `opus`

**After sub-agents complete:** Read created files directly using Glob + Read to evaluate file quality (naming, structure, content). The minimal report provides process info (questions, decisions) that can't be inferred from files.

### Step 3: Score Each Behavior

For each expected behavior, score 0-100:

| Score | Meaning |
|-------|---------|
| 0 | Not attempted or completely wrong |
| 25 | Attempted but below minimum |
| 50 | Meets minimum criteria |
| 75 | Meets most quality criteria |
| 100 | Meets all quality criteria |

**Scoring checklist per behavior:**

1. Did it meet the **Minimum**? (No → score ≤ 25)
2. How many **Quality criteria** met? (Calculate proportion)
3. Did it hit the **Haiku pitfall**? (Deduct points)
4. Apply **Weight** to final calculation

### Step 4: Calculate Weighted Scores

```
Behavior Score = base_score × (weight / max_weight)
Total = Σ(behavior_scores) / Σ(weights) × 100
```

**Rating thresholds:**

| Score | Rating | Meaning |
|-------|--------|---------|
| 90-100 | ✅ Excellent | Production ready |
| 75-89 | ✅ Good | Acceptable |
| 50-74 | ⚠️ Partial | Quality issues |
| 25-49 | ⚠️ Marginal | Significant problems |
| 0-24 | ❌ Fail | Does not work |

### Step 5: Determine Recommended Model

**5a. Quality threshold check:**
Select models with score ≥ 75.

**5b. Calculate total cost efficiency:**

Token pricing (per MTok) from [Claude Pricing](https://platform.claude.com/docs/en/about-claude/pricing):

| Model | Input | Output | Cost Ratio (vs Haiku) |
|-------|-------|--------|----------------------|
| Haiku 4.5 | $1 | $5 | 1x |
| Sonnet 4.5 | $3 | $15 | 3x |
| Opus 4.5 | $5 | $25 | 5x |

```
Execution Cost = tokens × cost_ratio
Iteration Multiplier = 1 + (90 - quality_score) / 100
  # Score 90 → 1.0x, Score 75 → 1.15x, Score 50 → 1.4x
Total Cost = Execution Cost × Iteration Multiplier
```

**5c. Recommend based on Total Cost:**
Among models with score ≥ 75, recommend the one with **lowest Total Cost**.

Note: If Total Costs are within 20% of each other, prefer the higher-quality model.

### Step 6: Output Summary

```markdown
## Model Evaluation Results

**Skill:** {skill_path}
**Scenario:** {scenario_name} ({difficulty})

### Scores by Behavior

| Behavior | Weight | Haiku | Sonnet | Opus |
|----------|--------|-------|--------|------|
| Asks clarifying questions | 4 | 25 | 75 | 100 |
| Determines freedom level | 3 | 50 | 75 | 100 |
| Creates proper SKILL.md | 5 | 50 | 100 | 100 |

### Total Scores

| Model | Score | Rating |
|-------|-------|--------|
| haiku | 42 | ⚠️ Marginal |
| sonnet | 85 | ✅ Good |
| opus | 100 | ✅ Excellent |

### Cost Analysis

| Model | Tokens | Tool Uses | Exec Cost | Iter. Multi | Total Cost |
|-------|--------|-----------|-----------|-------------|------------|
| haiku | 35k | 17 | 35k | 1.48x | 52k |
| sonnet | 57k | 21 | 171k | 1.05x | 180k |
| opus | 38k | 9 | 190k | 1.00x | 190k |

**Recommended model:** sonnet (lowest total cost among score ≥ 75)

### Observations
- Haiku: Skipped justification for freedom level (pitfall)
- Haiku: Asked only 1 generic question vs 3 specific
- Sonnet: Met all quality criteria except verbose output
```

## Common Pitfalls by Model

| Model | Pitfall | Detection |
|-------|---------|-----------|
| haiku | Shallow questions | Count specificity |
| haiku | Skip justification | Check reasoning present |
| haiku | Miss references | Check files read |
| sonnet | Over-engineering | Check scope creep |
| sonnet | Verbose reporting | High token count vs output |
| opus | Over-verbose output | Token count |

> **Note:** Token usage includes both skill execution AND reporting overhead. Sonnet tends to produce detailed reports, which inflates token count. Compare tool uses for execution efficiency.

## Quick Reference

```
Load scenarios → Execute (parallel) → Score behaviors → Calculate totals → Cost analysis → Recommend model
```

For detailed scoring guidelines, see [references/evaluation-structure.md](references/evaluation-structure.md).
