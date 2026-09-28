# CLAUDE.md

## Claude-Specific Notes

- Scoped rules auto-load from `.claude/rules/*.md` via their `paths:` frontmatter — no need to restate conventions here.

## Backend workflow

- Plans live in `.plans/` (`implementation-plan-*.md`, `bugfix-*.md`, `*-rev-N.md`). Never overwrite a plan — create a revision with `/plan <file> --thoughts "..."`.
- Pipeline: `/analyze-requirements` → `/plan` → `/implement` → `/review` → `/document`. `/fix-bug` writes a bugfix plan for `/implement`. `/full-cycle` orchestrates all five via subagents.
- Use `AskUserQuestion` at every confirmation gate instead of free-text "are you sure?".
- Rails, RSpec and API-endpoint conventions come from `.claude/rules/` — never restate them inside skills or prompts.
