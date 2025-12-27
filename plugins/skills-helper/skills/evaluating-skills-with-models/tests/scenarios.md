# Test Scenarios for evaluating-skills-with-models

## Scenario: Evaluate skill with existing scenarios

**Query:** Evaluate the skill at ./skills/pdf-processing/ across all models

**Expected behavior:**
- Checks for tests/scenarios.md in target skill
- Parses scenarios if exists
- Spawns Task sub-agents for sonnet, opus, haiku in parallel
- Collects raw outputs from each model
- Evaluates results against expected behaviors
- Determines recommended model (least capable with full compatibility)
- Outputs comparison table with ratings

## Scenario: Evaluate skill without scenarios file

**Query:** Run model evaluation on my new skill at ./skills/new-feature/

**Expected behavior:**
- Checks for tests/scenarios.md (not found)
- Asks user for evaluation_query
- Asks user for expected_behavior list
- Proceeds with evaluation using provided inputs
- Returns model comparison results

## Scenario: Interpret evaluation observations

**Query:** The haiku model keeps missing my reference files. What does this mean?

**Expected behavior:**
- Identifies observation: "Missed references"
- Explains indication: "Links need to be explicit"
- Suggests making reference links more prominent in SKILL.md
- Recommends running /improving-skills to address
