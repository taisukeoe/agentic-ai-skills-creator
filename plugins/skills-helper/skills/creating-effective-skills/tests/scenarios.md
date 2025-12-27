# Test Scenarios for creating-effective-skills

## Scenario: Create new skill from scratch

**Query:** I want to create a skill that helps with database migrations. Can you help me create it following best practices?

**Expected behavior:**
- Asks clarifying questions about skill functionality and triggers
- Determines appropriate freedom level (likely medium for migrations)
- Creates proper directory structure with SKILL.md
- Uses gerund naming (e.g., `managing-database-migrations`)
- Writes description in third person with what + when
- Keeps SKILL.md under 500 lines
- Creates tests/scenarios.md for the new skill

## Scenario: Guide through 7-step workflow

**Query:** Walk me through creating a skill for code review automation

**Expected behavior:**
- Follows Step 1: Asks about functionality, examples, triggers
- Follows Step 2: Discusses freedom level options
- Follows Step 3: Identifies reusable contents (scripts, references)
- Follows Step 4: Creates proper directory structure
- Follows Step 5: Writes SKILL.md with proper frontmatter
- Follows Step 6: Creates reference files if needed
- Follows Step 7: Creates test scenarios

## Scenario: Reference progressive disclosure

**Query:** My skill is getting too long. How should I split it up?

**Expected behavior:**
- Reads references/progressive-disclosure.md
- Explains three-level loading system
- Suggests moving detailed content to references/
- Provides concrete examples of splitting patterns
