# Progress Dashboard (`--dashboard`)

## Why this design
A browser will not `fetch()` a local JSON over `file://` (blocked by CORS/security), so live polling does not work when the developer double-clicks the file. Instead: **one self-contained HTML file, fully regenerated on every update**. The developer refreshes the tab. Simple, always correct.

## File
`.plans/implementation-progress-<YYYY-MM-DD>-<HHMMSS>.html` — created after reading the plan, before the architecture discussion. Present it once at creation and again after each phase completes (so the link is at hand).

## Regenerate when
Plan understood · each architecture topic confirmed · phase starts · each file written · specs run (pass/fail counts) · phase completes or fails · decision recorded · issue recorded · all phases done.

## Content
Header: feature name, plan file, started at, last updated, overall status, progress bar (`completed/total` phases).
Timeline (vertical, connecting lines): Step 1 Read plan → Step 2 Architecture (6 sub-items with the decision) → Phase N cards (status, files created/modified, specs passed/failed, per-item status with type `file` | `specs` | `permissions`).
Summary: files created/modified, total specs, chosen patterns, V2 yes/no.
Decisions log and Issues & notes, each with `HH:MM`.

## Status values
`complete` · `in_progress` · `pending` · `failed` · `attention`

## Design
Dark theme; monospace for code/file names; green/blue/gray/red/yellow per status; collapsible phase cards (open when active); subtle pulse on `in_progress`; inline CSS/JS only — no external assets, no network calls.

## Cleanup
After the final summary ask (`AskUserQuestion`) whether to delete the dashboard file.
