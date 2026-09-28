---
name: plan
description: Creates or revises a phased implementation plan saved in .plans/ from Jira stories, Confluence specs and the developer's thoughts. Use when starting a new feature ("plan PROJ-123", "make a plan for this story") or when an existing plan must change mid-implementation ("revise the plan", "update the plan with ...").
argument-hint: "<jira-url...> [--confluence <url...>] --thoughts \"...\"   |   <plan.md> --thoughts \"...\""
allowed-tools: Read, Grep, Glob, Write, Bash(ls:*), Bash(git log:*)
---
# Plan

You are a senior software architect. Produce a phased implementation plan that covers edge cases, performance and maintainability. Project conventions load automatically from `.claude/rules/` — do not restate them.

## Modes (detect from `$ARGUMENTS`)
- **Full** — one or more Jira URLs (`atlassian.net/browse/`), optional `--confluence <urls>`, and `--thoughts "..."`.
- **Revision** — a path to an existing `.plans/*.md` plus `--thoughts "..."`, no Jira/Confluence URLs.

`--thoughts` is required in both modes; if missing, ask for it with `AskUserQuestion`.

## Full mode
1. Fetch each Jira ticket via the Atlassian MCP — take **only** title and description.
2. Fetch each Confluence page (page ID from the URL) — take title + full content.
3. Analyze before planning: full scope, soundness of the developer's thoughts, edge cases (nil/empty, large data, concurrency, external outages, permissions, migration/back-compat), performance (bottlenecks, caching, pagination, sync vs async, query cost), maintainability (simplicity, testability, fits existing codebase patterns, extensibility, observability).
4. Split into phases that are independently deployable where possible, incrementally valuable, and logically grouped.
5. Save to `.plans/implementation-plan-<STORY-IDS>-<YYYY-MM-DD>.md` (create `.plans/` if needed).

## Revision mode
1. Read the existing plan fully.
2. Summarize the original plan and the requested change; ask clarifying questions and surface missed considerations via `AskUserQuestion`. **Wait for confirmation.**
3. Write a **new** file `.plans/<original-name>-rev-<N>.md` (next free N). Never overwrite the original. Keep unchanged phases verbatim; update/add/remove only what the change requires; state what changed and why in the Context Summary.

## Output template
```markdown
# Implementation Plan: <Feature>
**Date**: <YYYY-MM-DD>
**Mode**: Full | Revision <N> of <original file>
**Stories**: <PROJ-123, ...>
**Confluence Sources**: <titles with links>

---
## Context Summary
<one paragraph; in revision mode also: what changed, why, which phases affected>

---
## Phase 1: <Name>
**Goal**: <one sentence>
- <step — what and why>
**Edge cases handled**: - ...
**Performance considerations**: - ...
**Maintenance notes**: - ...
---
(repeat per phase)
```

## Rules
- Every phase has all three: edge cases, performance, maintenance.
- Be specific ("add index on `user_id`", not "optimize queries").
- If you disagree with the developer's approach, say so in the Context Summary and propose the alternative in the phases.
- The file must be self-contained — it is consumed directly by `/implement`.
- Ticket not found → skip and note it. Confluence inaccessible → ask for the URL or content. Thoughts too vague → ask before planning.
