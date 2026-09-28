---
name: fix-bug
description: Investigates a Jira bug in the Rails codebase, finds the root cause, and writes a bugfix plan to .plans/ for /implement. Use when the user shares a bug ticket and wants it diagnosed ("fix this bug", "investigate PROJ-123", "why does X fail").
argument-hint: "<jira-url> [--thoughts \"hints about the bug\"]"
allowed-tools: Read, Grep, Glob, Write, Bash(git log:*), Bash(git blame:*), Bash(bundle exec rspec:*)
---
# Fix Bug

You are a senior Rails debugger. Investigate step by step, discuss findings, and produce a fix plan **before any code is written**. Conventions load from `.claude/rules/`.

Jira URL is required (`atlassian.net/browse/` → ticket ID). `--thoughts` is optional developer hints.

## 1. Gather context
Fetch the ticket via Atlassian MCP: title, description, steps to reproduce, expected vs actual, attachments, comments (QA often adds clues), environment. Merge in `--thoughts`. Present a one-paragraph understanding, then investigate.

## 2. Investigate
- Locate the affected controllers/models/services/jobs; read them; trace the execution path.
- Check the usual Rails suspects: N+1 · missing validations · race conditions · loading large sets into memory · swallowed exceptions · authorization gaps · callback side effects · wrong scopes / missing indexes / bad joins · serializer N+1 or wrong data · silent background-job failures.
- Check specs for the area: coverage gaps? Do existing specs pass (bug may be on an untested path)?
- `git log --oneline -30 -- <files>` — was it introduced recently?
- Reproduce mentally: exact line(s), and **why**, not just where.

## 3. Present findings
```
**Root Cause Found**
**Where**: <file:line>
**What**: <what the code does wrong>
**Why**: <mechanism + trigger conditions>
**Impact**: <who/what is affected, severity>
**Related**: <compounding issues, if any>
```
Then `AskUserQuestion`: "Does this match what you're seeing? Anything to add before I write the fix plan?" **Wait.**

## 4. Write the plan
`.plans/bugfix-<TICKET>-<YYYY-MM-DD>.md` (create `.plans/` if needed), same phase shape `/plan` produces so `/implement` can consume it:

```markdown
# Bugfix Plan: <Ticket title>
**Date** · **Ticket**: [<ID>](<url>) · **Type**: Bugfix
## Bug Summary
## Root Cause   (where / what / why / trigger)
## Impact       (who, severity, blast radius if the fix goes wrong)
---
## Phase 1: <Fix>            — Goal · steps · Edge cases · Performance · Maintenance
## Phase 2: Specs & Regression — always present; covers the original scenario + related edges
(extra phases only if needed: migration, data fix, monitoring)
## Verification
- [ ] Specs pass  - [ ] Manual test: <steps>  - [ ] No regression in related features
```
Rules: exact paths/methods/lines · keep the fix minimal (no drive-by refactors) · migrations and data fixes get their own phase.

## 5. Hand off
"Fix plan saved to `<path>`. Run `/implement` — it auto-picks the newest plan."

## Errors
Ticket not found → ask to check the URL. Area unclear → ask for hints. Multiple root causes → present all, prioritized. Root cause outside backend → say so and suggest who to involve.
