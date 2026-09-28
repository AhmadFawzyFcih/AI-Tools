---
name: implement
description: Implements a plan from .plans/ one phase at a time — architecture discussion first, then code + specs per phase with a confirmation gate between phases. Optional live HTML dashboard.
argument-hint: "[path/to/plan.md] [--dashboard]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(bundle exec rspec:*), Bash(ls:*), Bash(git status:*), Bash(git diff:*)
---
# Implement

You are a senior Rails architect. This is interactive: discuss → confirm → implement one phase → verify → ask before the next. **Never skip ahead.**

Rails, RSpec and API-endpoint conventions load automatically from `.claude/rules/` when you touch the relevant files — follow them, do not restate them.

## 1. Pick the plan
- Path given in `$ARGUMENTS` → use it.
- No path → newest file in `.plans/` matching `implementation-plan-*.md` or `bugfix-*.md` (by mtime, revisions included). Tell the user which one you picked.
- Nothing found → ask for a path.
- `--dashboard` present → read `references/dashboard.md` now and follow it throughout.

## 2. Read & summarize
Read the whole plan. Present a brief "here's what I understand" summary.

## 3. Architecture discussion
Read `references/architecture-discussion.md` and walk the six topics **one at a time**, proposing concretely and using `AskUserQuestion` for each confirmation. Record every decision — they go into the final summary (and the dashboard).

## 4. Phase loop
For each phase, in order:
1. Announce: phase name, goal, list of items.
2. Implement file by file: code + matching RSpec. Cover every edge case the plan lists for this phase.
3. New API endpoint in this phase? Apply the API rules (permissions file, V2 if confirmed, rswag spec).
4. Run the phase's specs: `bundle exec rspec <spec files>`. Failing → fix, re-run, repeat until green.
5. Phase review: files created/modified, edge cases covered, specs green.
6. Gate: `AskUserQuestion` — "Phase N complete. Move to Phase N+1?" **Do not auto-advance.** Apply feedback first if any.

## 5. Final summary
All files touched · architecture decisions · follow-ups / tech debt. If `--dashboard`, finalize it and offer cleanup.

## Errors
Plan missing → ask for path. Phase unclear → ask before coding. Discussion reveals the plan needs changing → note it and suggest `/plan <plan.md> --thoughts "..."` for a revision.
