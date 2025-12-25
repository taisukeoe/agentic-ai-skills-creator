# Evaluation Structure Reference

## Full Evaluation Schema

```json
{
  "skills": ["skill-name-1", "skill-name-2"],
  "query": "The exact user request to test",
  "files": ["path/to/test-file.ext"],
  "expected_behavior": [
    "Specific observable action 1",
    "Specific observable action 2",
    "Specific observable action 3"
  ]
}
```

## Field Descriptions

### skills
Array of skill names that should be loaded for this test.

### query
The user request that should trigger the skill. Write it exactly as a user would.

### files
Optional array of test files needed for the evaluation. Place in `test-files/` directory.

### expected_behavior
Array of specific, observable behaviors to verify. Each item should be:
- Verifiable (can objectively determine pass/fail)
- Specific (not vague like "works correctly")
- Action-oriented (describes what Claude should do)

## Evaluation Directory Structure

```
skill-name/
├── SKILL.md
├── references/
│   └── ...
└── evaluations/
    ├── basic-usage.json
    ├── edge-case-handling.json
    ├── error-recovery.json
    └── test-files/
        └── sample.ext
```

## Good vs Bad Expected Behaviors

**Good (specific and verifiable):**
- "Reads the PDF file using pdfplumber library"
- "Extracts text from all 5 pages of the document"
- "Saves output to output.txt in UTF-8 encoding"
- "Handles FileNotFoundError gracefully with user message"

**Bad (vague or unverifiable):**
- "Works correctly"
- "Processes the file"
- "Does what the user wants"
- "Handles errors well"

## Minimum Recommended Evaluations

Create at least 3 evaluations covering:

1. **Happy path**: Standard use case that should work perfectly
2. **Edge case**: Boundary conditions or unusual inputs
3. **Error case**: How skill handles failures or invalid inputs

## Tracking Results

Use a simple pass/fail matrix:

```markdown
| Evaluation | Haiku | Sonnet | Opus |
|------------|-------|--------|------|
| basic-usage | PASS | PASS | PASS |
| edge-case | FAIL | PASS | PASS |
| error-recovery | FAIL | FAIL | PASS |
```

Iterate on failures before moving to the next evaluation.
