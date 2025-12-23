# Agentic AI Skills Creator

A Claude Code plugin providing skills for creating and reviewing effective AI agent skills following Claude's official best practices.

## Confidentiality Notice

**This project must NOT contain any confidential information from specific companies or projects.**

All examples, documentation, and code samples in this repository use generic, fictional names and scenarios. Any resemblance to actual company names, project names, or proprietary information is unintentional and should be reported immediately.

**Guidelines:**
- Use generic placeholder names (e.g., `example-plugin`, `my-marketplace`) in all documentation
- Do not reference real internal projects, tools, or organizational structures
- All skills and examples must be publicly shareable
- Report any accidental inclusion of confidential information by opening an issue

## Skills Included

### 1. creating-effective-skills

Guide for creating high-quality agent skills that follow Claude's official best practices.

**Features:**
- Naming conventions (gerund form)
- Progressive disclosure patterns
- Description writing guidelines
- Degrees of freedom determination
- File organization best practices
- 8-step workflow for skill creation

**Use when:**
- Designing new agent skills
- Implementing skill architecture
- Improving existing skills
- Learning skill development best practices

### 2. reviewing-skills

Comprehensive review of agent skills against Claude's official best practices.

**Features:**
- Compliance checks (naming, description, size, structure)
- Progressive disclosure verification
- Content quality assessment
- Anti-pattern detection
- Detailed feedback with priorities
- Actionable improvement suggestions

**Use when:**
- Analyzing existing skills
- Verifying compliance with best practices
- Getting feedback before publishing
- Quality assurance for skill development

### 3. reviewing-plugin-marketplace

Review Claude Code plugin marketplace configurations against official best practices.

**Features:**
- marketplace.json structure validation
- Skills paths verification
- Git remote URL consistency checks
- README.md repository reference validation
- Common error detection (plugin.json presence, path mismatches)
- Automated verification script

**Use when:**
- Creating a new plugin marketplace
- Verifying marketplace configuration
- Debugging plugin installation issues
- Ensuring compliance with Anthropic format

## Installation

### From GitHub (Recommended)

```bash
/plugin marketplace add taisukeoe/agentic-ai-skills-creator
/plugin install skills-helper@agentic-ai-skills-creator
/plugin install marketplace-helper@agentic-ai-skills-creator
```

### From Local Path (Development)

```bash
/plugin marketplace add /path/to/agentic-ai-skills-creator
/plugin install skills-helper@local
/plugin install marketplace-helper@local
```

After installation, restart Claude Code to activate the skills.

## Usage

### Creating a New Skill

Simply ask Claude to create a skill, and the `creating-effective-skills` skill will automatically guide the process:

```
Create a skill for processing PDF files
```

Claude will:
1. Ask about functionality and triggers
2. Determine appropriate freedom level
3. Create proper file structure
4. Write SKILL.md following best practices
5. Create reference files as needed
6. Update settings.json

### Reviewing an Existing Skill

Ask Claude to review a skill:

```
Review the skill at .claude/skills/my-skill/
```

Claude will:
1. Analyze SKILL.md and references
2. Check compliance with best practices
3. Provide detailed feedback with priorities
4. Suggest specific improvements

## Development

### Project Structure

```
agentic-ai-skills-creator/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace manifest
├── .claude/
│   └── settings.json         # Local development settings
├── plugins/
│   ├── skills-helper/        # Plugin for skill development
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   │       ├── creating-effective-skills/
│   │       │   ├── SKILL.md
│   │       │   └── references/
│   │       └── reviewing-skills/
│   │           ├── SKILL.md
│   │           └── references/
│   └── marketplace-helper/   # Plugin for marketplace validation
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
│           └── reviewing-plugin-marketplace/
│               ├── SKILL.md
│               ├── scripts/
│               └── references/
├── LICENSE                   # Apache 2.0
└── README.md
```

### Local Development Settings

Configure permissions in `.claude/settings.json` for local development:

```json
{
  "permissions": {
    "allow": [
      "Skill(creating-effective-skills)",
      "Skill(reviewing-skills)",
      "Skill(reviewing-plugin-marketplace)"
    ]
  }
}
```

For users installing the plugin, skills are automatically available after plugin installation.

## Best Practices Covered

- **Naming**: Gerund form (e.g., `processing-pdfs`)
- **Progressive Disclosure**: 3-level loading (metadata, SKILL.md, references)
- **Size**: SKILL.md under 500 lines
- **Descriptions**: Third person, includes WHAT and WHEN
- **References**: One level deep, with TOC for files >100 lines
- **Degrees of Freedom**: High/Medium/Low based on task characteristics

## License

Copyright 2025 Softgraphy GK

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Links

- [Claude Code Documentation](https://code.claude.com/docs)
- [Agent Skills Guide](https://code.claude.com/docs/en/skills.md)
- [Plugin Development](https://code.claude.com/docs/en/plugins.md)
