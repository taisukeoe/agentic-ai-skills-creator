# Repository Guidelines

## Project Structure & Module Organization

This repo is a Claude Code plugin marketplace with three plugins under `plugins/`. Each plugin contains skills in `plugins/<plugin>/skills/<skill-name>/` with a `SKILL.md`, optional `references/`, and `tests/` scenarios. Marketplace metadata lives in `.claude-plugin/marketplace.json`. Devcontainer assets are in `.devcontainer/` for consistent local setup. Repository-level docs live in `README.md`, `CONTRIBUTING.md`, and `CLAUDE.md`.

## Build, Test, and Development Commands

- `code .` then “Reopen in Container” to use the devcontainer environment.
- `bash plugins/marketplace-helper/skills/reviewing-plugin-marketplace/scripts/verify-marketplace.sh [marketplace-dir]` validates marketplace.json and plugin.json structure.
- `.devcontainer/sync-codex-skills.sh` syncs Claude Code skills to Codex CLI (`~/.codex/instructions/`) after changes.

## Coding Style & Naming Conventions

- Use ASCII content and keep docs concise and instructional.
- Skill directories and IDs use kebab-case gerunds (e.g., `processing-pdfs`).
- `SKILL.md` descriptions are third person and state WHAT and WHEN.
- Keep `SKILL.md` under 500 lines; move details to `references/` and keep reference depth to one hop.
- Follow existing formatting in each file (e.g., JSON indentation and Markdown heading levels).

## Testing Guidelines

There is no single test runner. Skills include manual evaluation scenarios in `plugins/*/skills/*/tests/scenarios.md`. When you change a skill, update or add scenarios and run the marketplace verification script if metadata changes.

## Commit & Pull Request Guidelines

Recent commits use concise, sentence-case, imperative messages (e.g., “Refactor …”, “Update …”). PRs should include a short description, linked issues if applicable, and any testing performed (e.g., “Ran verify-marketplace.sh”). Ensure all examples remain generic and non-confidential per `CLAUDE.md`.

## Security & Content Safety

Do not include confidential or company-specific data in skills or docs. Use placeholder names like `example-plugin` and keep all examples publicly shareable.
