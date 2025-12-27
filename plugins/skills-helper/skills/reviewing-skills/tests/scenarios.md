# Test Scenarios for reviewing-skills

## Scenario: Review well-structured skill

**Query:** Review the skill at plugins/skills-helper/skills/improving-skills/

**Expected behavior:**
- Reads SKILL.md and directory structure
- Checks naming (gerund form)
- Checks description (third person, what + when)
- Checks size (<500 lines)
- Reports compliance score with checkmarks
- Provides organized feedback by priority

## Scenario: Review skill with multiple issues

**Query:** Review my skill that has a 600-line SKILL.md and is named "helper-utils"

**Expected behavior:**
- Identifies Critical: Name violates conventions (not gerund, uses "helper"/"utils")
- Identifies Critical: Size exceeds 500 lines
- Suggests specific fixes for each issue
- Provides actionable feedback with examples

## Scenario: Review skill with missing tests

**Query:** Check if my skill follows best practices

**Expected behavior:**
- Asks for skill path
- Reads SKILL.md and checks structure
- Identifies missing tests/scenarios.md as Important Issue
- Checks for references/evaluations.md
- Reports structure compliance with specific missing items

**Test files:**
- Sample skill directory without tests/scenarios.md
