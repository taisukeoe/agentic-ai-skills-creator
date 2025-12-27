# Test Scenarios for improving-skills

## Scenario: Improve skill based on user feedback

**Query:** My pdf-processing skill isn't triggering when users mention "extract text from document". Can you improve it?

**Expected behavior:**
- Asks for skill path if not provided
- Reads current SKILL.md
- Asks follow-up question about trigger issues
- Identifies description needs improvement for triggering
- Presents improvement plan with user-requested and technical fixes
- Implements changes after user approval
- Verifies changes address the stated problem

## Scenario: Technical improvement without user feedback

**Query:** Review and improve my skill at ./skills/data-export/

**Expected behavior:**
- Reads SKILL.md and analyzes structure
- Asks essential question: "What problems or improvements do you want?"
- Waits for user feedback before proceeding
- Does NOT make changes based only on technical analysis

## Scenario: Multiple issues identified

**Query:** My skill is 800 lines and the description is vague. Fix it.

**Expected behavior:**
- Identifies size issue (>500 lines)
- Identifies description quality issue
- Asks for clarification on what content to move to references
- Presents prioritized improvement plan
- Implements changes in logical order (structure first, then content)
