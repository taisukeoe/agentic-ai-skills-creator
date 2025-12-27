# Test Scenarios for running-skills-edd-cycle

## Scenario: Start EDD cycle for new skill

**Query:** I want to create a skill for API testing. Guide me through the EDD process.

**Expected behavior:**
- Explains Step 1: Build evaluations first
- Asks user to run Claude on representative tasks WITHOUT skill
- Helps document specific failures
- Guides creation of 3+ evaluation scenarios
- Triggers /creating-effective-skills for skill creation

## Scenario: Run model evaluation step

**Query:** I've written my skill. Now test it across models.

**Expected behavior:**
- Confirms tests/scenarios.md exists
- Triggers /evaluating-skills-with-models
- Waits for sub-agent results
- Reports recommended model
- Suggests documenting model in metadata

## Scenario: Complete EDD cycle with issues

**Query:** Run the full EDD cycle on my skill at ./skills/data-export/

**Expected behavior:**
- Loads test scenarios from tests/scenarios.md
- Establishes baseline (Step 2)
- Runs /evaluating-skills-with-models (Step 4)
- If observations reveal issues, triggers /improving-skills
- Runs /reviewing-skills for final review (Step 5)
- Outputs user validation guide (Step 6) with recommended model
