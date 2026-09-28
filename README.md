# Claude Code Skills for the Rails Dev Lifecycle

A drop-in `.claude/` setup for [Claude Code](https://claude.com/claude-code) that automates the full backend development lifecycle on a Rails project — from analyzing requirements to shipping reviewed, documented code.

It ships as **skills** (slash commands), **subagents** (isolated workers for heavy stages), **rules** (conventions that auto-load by file path), and **hooks** (guardrails that run around tool calls). Everything is generic: point it at your own Jira, Confluence, Figma and Rails codebase.

## Repo layout

| Path | What it is |
|------|------------|
| `skills/` | The Claude Code setup — copy its contents into your project (see Installation) |
| `skills/.claude/` | Skills, agents, rules, hooks and `settings.json` |
| `skills/CLAUDE.md` | Project-level instructions that tie the pipeline together |
| `skills/Claude_Code_New_Structure_Guide.pdf` | Background on the skills/agents/rules/hooks structure |
| `claude-course/`, `copilot-course/` | Personal course notes and screenshots (not part of the setup) |
| `k9s-field-guide.html` | Unrelated k9s cheat sheet |

## Installation

1. Copy the setup into the root of your Rails project:

   ```bash
   cp -R skills/.claude  /path/to/your-rails-app/
   cp    skills/CLAUDE.md /path/to/your-rails-app/
   chmod +x /path/to/your-rails-app/.claude/hooks/*.sh
   ```

   If your project already has a `CLAUDE.md`, merge the "Backend workflow" section into it instead of overwriting.

2. Make sure these MCP servers are configured in Claude Code:

   - **Atlassian MCP** — Jira stories/bugs and Confluence pages
   - **Figma MCP** — design file analysis (used by `/analyze-requirements` and `/full-cycle`)

3. Project prerequisites: Ruby/Rails, RSpec, FactoryBot, and [rswag](https://github.com/rswag/rswag) for Swagger generation (`bundle exec rake rswag:specs:swaggerize`).

4. Adjust project-specific paths. The API rules and the API-change hook assume endpoint permissions live in `config/initializers/init_dr_permissions.rb`. Change that path in `.claude/rules/api-endpoints.md` and `.claude/hooks/api-change-reminder.sh` to match your project, or drop the step if you don't have one.

## What's inside

### Skills (slash commands)

| Skill | Purpose | Invocation |
|-------|---------|------------|
| `/analyze-requirements` | Cross-check Jira stories against Figma designs, produce a mismatch report, publish to Confluence | Manual only |
| `/plan` | Create a phased implementation plan from Jira + Confluence + your thoughts, or revise an existing plan | Manual or auto |
| `/fix-bug` | Investigate a Jira bug, find the root cause, write a bugfix plan | Manual or auto |
| `/implement` | Execute a plan phase by phase with an architecture discussion first; optional live HTML dashboard | Manual only |
| `/review` | Review local changes or a remote MR/PR against a Rails checklist; interactive HTML report | Manual or auto |
| `/document` | Update rswag/Swagger specs, then create or update a Confluence API page | Manual only |
| `/full-cycle` | Orchestrate all five stages for a set of stories, delegating heavy stages to subagents | Manual only |

"Manual only" skills carry `disable-model-invocation: true` — Claude will never trigger them on its own because they publish or write a lot of code. The others can also be picked up automatically when you describe the task in plain words ("investigate PROJ-123", "review my changes").

### Subagents

Used by `/full-cycle` to keep the main conversation thin. Each one reads the corresponding skill, runs it in a fresh context, and reports back a short structured summary.

| Agent | Runs | Used in |
|-------|------|---------|
| `requirements-analyst` | `/analyze-requirements` | Stage 1 — keeps the heavy Jira/Figma payloads out of the main context |
| `code-reviewer` | `/review` (local mode, report only, never edits) | Stage 4 |
| `doc-writer` | `/document` | Stage 5 |

### Rules (auto-loaded conventions)

Rules load only when Claude touches a file matching their `paths:` glob, so skills never restate them.

| Rule | Loads for | Covers |
|------|-----------|--------|
| `rails-conventions.md` | `app/**/*.rb`, `lib/**/*.rb` | Thin controllers, service objects, N+1 prevention, style, security |
| `rspec.md` | `spec/**/*.rb` | Spec structure, FactoryBot, edge-case coverage, running affected specs |
| `api-endpoints.md` | `config/routes.rb`, `app/controllers/api/**`, `app/serializers/**`, `spec/integration/**` | Permissions file, V2 coverage, rswag spec + swaggerize, backward compatibility |

### Hooks

Configured in `.claude/settings.json`.

| Hook | Event | What it does |
|------|-------|--------------|
| `block-debug-statements.sh` | `PreToolUse` on `Bash` | Blocks `git commit` if staged Ruby contains `binding.pry`, `byebug`, `debugger`, stray `puts`/`p`/`pp` |
| `api-change-reminder.sh` | `PostToolUse` on `Edit`/`Write`/`MultiEdit` | When routes or API controllers change, reminds Claude to update permissions, rswag specs, Swagger and V2 |

## Output files

Everything the skills produce lands in `.plans/` inside your project:

| File | Produced by |
|------|-------------|
| `requirements-analysis-<date>.md` | `/analyze-requirements` |
| `implementation-plan-<STORY-IDS>-<date>.md`, `…-rev-N.md` | `/plan` |
| `bugfix-<TICKET>-<date>.md` | `/fix-bug` |
| `implementation-progress-<date>-<time>.html` | `/implement --dashboard` |
| `review-<date>-<time>.html`, `review-mr-<ID>-<date>.html` | `/review` |
| `doc-review-<date>-<time>.html` | `/document` (update mode) |
| `full-cycle-<date>-<time>.md` | `/full-cycle` (state file) |

Consider adding `.plans/` to your project's `.gitignore`.

---

## `/analyze-requirements`

Fetches Jira stories and Figma designs, maps them together, flags mismatches and gaps, saves a report and publishes it to Confluence.

```bash
# Single or multiple tickets
/analyze-requirements PROJ-123
/analyze-requirements PROJ-123 PROJ-456 PROJ-789

# Sprint or whole project
/analyze-requirements "Sprint 5"
/analyze-requirements PROJ

# With Figma designs, linked tasks and a Confluence target folder
/analyze-requirements PROJ-123 PROJ-456 --check-linked-tasks \
  --figma https://www.figma.com/design/abc/File1 \
  --confluence-folder https://<your-site>.atlassian.net/wiki/spaces/<KEY>/folder/<ID>
```

| Flag | Description |
|------|-------------|
| `--figma <urls>` | One or more Figma file URLs (also discovered from story descriptions/attachments) |
| `--check-linked-tasks` | Also pull priority, status, linked issues and subtasks |
| `--confluence-folder <url>` | Folder to publish the report under; asked interactively if omitted |

Pauses with a question only if a story has no matching design or vice versa.

---

## `/plan`

Creates a phased implementation plan, or revises an existing one. Every phase lists edge cases, performance considerations and maintenance notes.

**Full mode** — start from Jira (+ optional Confluence specs):

```bash
/plan https://<your-site>.atlassian.net/browse/PROJ-123 \
  --confluence https://<your-site>.atlassian.net/wiki/spaces/<KEY>/pages/<ID>/Spec \
  --thoughts "Queue-based approach with Redis"
```

**Revision mode** — pass an existing plan instead of a Jira URL:

```bash
/plan ./.plans/implementation-plan-PROJ-123-2026-02-15.md \
  --thoughts "Bulk delete locks the table, need batched soft deletes instead"
```

| Flag | Description |
|------|-------------|
| `--confluence <urls>` | Confluence spec pages (full mode, optional) |
| `--thoughts <text>` | Your ideas or constraints (**required** in both modes) |

Revision mode discusses the change with you first and **never overwrites** the original — it writes `…-rev-N.md`, which `/implement` consumes directly.

---

## `/fix-bug`

Investigates a Jira bug step by step, presents the root cause (where / what / why / impact), waits for your confirmation, then writes a bugfix plan that `/implement` can run.

```bash
/fix-bug https://<your-site>.atlassian.net/browse/PROJ-123
/fix-bug https://<your-site>.atlassian.net/browse/PROJ-123 \
  --thoughts "Only happens with 50+ projects, probably an N+1 or timeout"
```

| Flag | Description |
|------|-------------|
| `--thoughts <text>` | Optional hints: suspected area, reproduction notes, observations |

The plan always includes a "Specs & Regression" phase and keeps the fix minimal — no drive-by refactors.

---

## `/implement`

Executes a plan one phase at a time. Interactive by design: it walks through six architecture topics (SOLID, MVC boundaries, service boundaries, design patterns, V2 API coverage, folder structure) and asks for confirmation on each, then implements a phase, runs its specs, and asks before moving on.

```bash
# Explicit plan
/implement ./.plans/implementation-plan-PROJ-123-2026-02-15.md

# Auto-detect the newest implementation-plan-*.md or bugfix-*.md in .plans/
/implement

# With a live progress dashboard
/implement --dashboard
```

| Flag | Description |
|------|-------------|
| `--dashboard` | Also maintain a self-contained HTML progress page (phases, decisions, spec results, issues) that is regenerated on every update — refresh the tab to see progress |

---

## `/review`

Reviews code against a ten-point Rails checklist (N+1, performance, security, SOLID, structure, style, specs, backward compatibility, error handling, Rails practice) and produces an interactive HTML report where you tick the findings to act on.

**Local mode** — uncommitted changes:

```bash
/review
/review --plan ./.plans/implementation-plan-PROJ-123-2026-02-15.md
```

**Remote mode** — a merge request or pull request (comment only, never edits code):

```bash
/review https://gitlab.com/<group>/<project>/-/merge_requests/123
/review https://github.com/<org>/<repo>/pull/456
```

| Flag | Description |
|------|-------------|
| `--plan <path>` | Local mode only. If the fixes changed the design, offers a `/plan` revision afterwards |

Findings are graded Critical / Warning / Suggestion. In local mode the selected fixes are applied and the affected specs re-run.

---

## `/document`

Updates rswag/Swagger specs **first** (both modes), then creates or updates a Confluence API page.

**New page** under a Confluence folder:

```bash
/document --new https://<your-site>.atlassian.net/wiki/spaces/<KEY>/folder/<ID> \
  ./.plans/implementation-plan-PROJ-123-2026-02-15.md \
  --thoughts "Checklist field feature, covers CRUD and bulk operations"
```

**Update** an existing page:

```bash
/document https://<your-site>.atlassian.net/wiki/spaces/<KEY>/pages/<ID>/Feature+Documentation \
  ./.plans/implementation-plan-PROJ-123-2026-02-15.md \
  --thoughts "Added bulk delete endpoint"
```

| Flag | Description |
|------|-------------|
| `--new <folder-url>` | Create a new page under this folder |
| `--thoughts <text>` | Optional context about what was implemented or changed |

Update mode generates a before/after diff review page and applies only the changes you confirm, preserving the rest of the page byte-for-byte.

---

## `/full-cycle`

Runs the whole pipeline for a set of stories with a state file as the single source of truth. Heavy read-only stages run in subagents; interactive stages run in the main conversation.

```bash
/full-cycle PROJ-123
/full-cycle PROJ-123 PROJ-456 --figma https://www.figma.com/design/abc/File1
/full-cycle PROJ-123 --check-linked-tasks \
  --confluence-folder https://<your-site>.atlassian.net/wiki/spaces/<KEY>/folder/<ID>
```

| Flag | Description |
|------|-------------|
| `--figma <urls>` | Figma files for the requirements stage |
| `--check-linked-tasks` | Also fetch linked issues, subtasks, priority and status |
| `--confluence-folder <url>` | Where to publish the requirements report (and default folder for documentation) |

**Stages:** requirements analysis → planning → implementation → review → documentation.

**Pause points (only these):** unmapped stories/designs · before planning · the six architecture topics · after each implementation phase · review selection · documentation target · doc diff confirmation. Everything else auto-continues.

---

## Typical workflow

```
1. /analyze-requirements   →  Understand what to build
2. /plan                   →  Plan how to build it
   /fix-bug                →  …or investigate a bug and create a fix plan
3. /implement              →  Build it phase by phase (add --dashboard for a live view)
4. /review                 →  Review the code
5. /document               →  Update Swagger + Confluence

Or run everything at once:

   /full-cycle             →  All 5 stages in one orchestrated pipeline
```

Each step feeds the next: the requirements analysis informs the plan, the plan drives implementation, the review catches issues, and the documentation captures what was built.

## Further reading

Conventions live once in `.claude/rules/` and load automatically by file path, so no skill has to repeat them. See `skills/Claude_Code_New_Structure_Guide.pdf` for the reasoning behind the skills / agents / rules / hooks structure.
