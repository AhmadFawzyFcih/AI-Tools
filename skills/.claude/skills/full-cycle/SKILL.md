---
name: full-cycle
description: Orchestrates requirements analysis → planning → implementation → review → documentation for a set of Jira stories, delegating the heavy read-only stages to subagents and pausing only at real decisions. Manual only.
argument-hint: "<PROJ-123 ...> [--figma <url...>] [--check-linked-tasks] [--confluence-folder <url>]"
disable-model-invocation: true
---
# Full Cycle

You are the orchestrator. **Keep this context thin.** Heavy, read-only stages run in subagents (fresh context) and return a short summary plus file paths. Interactive stages (planning thoughts, architecture, per-phase gates) run here because they need the developer.

## State file — single source of truth
Create `.plans/full-cycle-<YYYY-MM-DD>-<HHMMSS>.md` before Stage 1 and append to it after every event:
```
# Full Cycle — <input>
Started: <ts>
## Stages        | # | Stage | Status | Started | Finished | Summary |
## Decisions     - [HH:MM] <stage>: <decision>
## Artifacts     - <path or URL>
## Issues        - [HH:MM] <what happened / how resolved>
```
Never rely on your own memory for decisions — re-read this file when you need them. (Optional: also render a self-contained HTML dashboard from it; the `.md` stays authoritative.)

## Stages
**1. Requirements** — delegate to the `requirements-analyst` subagent with `$ARGUMENTS` (including `--confluence-folder` if given; otherwise `AskUserQuestion` for the target folder URL first). Expect back: report path, Confluence URL, mismatch summary, list of Jira IDs and any Confluence spec URLs found. Pause (`AskUserQuestion`) only if the subagent reports unmapped items.

**2. Plan** — inline. Build `initial_thoughts` from the mismatch summary; `AskUserQuestion`: "Here's the context I'll plan from — add or change anything?" Then run the `/plan` skill workflow in Full mode with the Jira IDs, Confluence URLs and confirmed thoughts. Record the plan path.

**3. Implement** — inline. Run the `/implement` skill workflow on the plan (with `--dashboard` if the developer wants it). Its own gates apply (six architecture confirmations, one per phase). Append every decision to the state file.

**4. Review** — delegate to the `code-reviewer` subagent (local mode, `--plan <plan path>`). Expect back: report path + counts. Present the report; `AskUserQuestion` for which concerns to fix. Apply fixes inline (they may touch code and specs), re-run specs, update state. If the design changed, offer a plan revision.

**5. Document** — `AskUserQuestion`: new page (folder URL — default to the `--confluence-folder` from Stage 1 if given) or update (page URL)? Then delegate to the `doc-writer` subagent with mode + plan path. Update mode returns a diff-review path → present, confirm numbers, subagent applies.

## Pause points (only these)
Unmapped stories/designs · before planning · six architecture topics · after each phase · review selection · document target · doc diff confirmation. Everything else auto-continues.

## Finish
Mark all stages done in the state file; present: artifacts, Confluence links, decisions, total duration.

## Errors
Stage fails → mark ❌ with details, `AskUserQuestion`: retry / skip / abort. Abort → state file already holds everything produced.
