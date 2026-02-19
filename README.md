# Custom Commands for Claude Code

A collection of slash commands that automate the full development lifecycle — from analyzing requirements to shipping documented, reviewed code.

## Prerequisites

These commands rely on the following MCP servers being configured in Claude Code:

- **Atlassian MCP** — for Jira stories and Confluence pages
- **Figma MCP** — for design file analysis (used by `/analyze-requirements`)

## Commands Overview

| Command | Purpose |
|---------|---------|
| `/analyze-requirements` | Analyze Jira stories + Figma designs, detect mismatches |
| `/plan-implementation` | Create a phased implementation plan from Jira + Confluence + your ideas |
| `/implement-plan` | Execute an implementation plan phase by phase with architecture discussion |
| `/implement-plan-nicely` | Same as `/implement-plan` but with a live HTML progress dashboard |
| `/review` | Review code changes (local or remote MR) and generate an interactive HTML report |
| `/documentation` | Create or update Confluence API documentation from code + plan |
| `/full-cycle` | Run the entire dev lifecycle (analyze → plan → implement → review → document) with a live dashboard |

---

## `/analyze-requirements`

Analyzes Jira user stories and Figma designs, maps them together, detects mismatches, and produces a requirements report published to Confluence.

### Usage

```bash
# Single ticket
/analyze-requirements PROJ-123

# Multiple tickets
/analyze-requirements PROJ-123 PROJ-456 PROJ-789

# Sprint
/analyze-requirements "Sprint 5"

# Tickets + Figma designs
/analyze-requirements PROJ-123 PROJ-456 --figma https://www.figma.com/design/abc/File1

# Include linked issues and subtasks
/analyze-requirements PROJ-123 PROJ-456 --check-linked-tasks

# Full example
/analyze-requirements PROJ-123 PROJ-456 --check-linked-tasks --figma https://www.figma.com/design/abc/File1
```

### Flags

| Flag | Description |
|------|-------------|
| `--figma <urls>` | One or more Figma file URLs to analyze |
| `--check-linked-tasks` | Also fetch linked issues, subtasks, priority, and status |

### Output

- Local file: `.plans/requirements-analysis-[date].md`
- Confluence page created automatically under the configured folder

---

## `/plan-implementation`

Creates a phased implementation plan by combining Jira stories, Confluence specs, and your initial thoughts. Supports two modes: **full planning** and **revision**.

### Full Mode (first-time planning)

```bash
/plan-implementation https://planradar.atlassian.net/browse/PROJ-123 \
  --confluence https://planradar.atlassian.net/wiki/spaces/PMT/pages/123/Spec \
  --thoughts "Queue-based approach with Redis"
```

**Output:** `.plans/implementation-plan-PROJ-123-2026-02-15.md`

### Revision Mode (mid-implementation changes)

Pass an existing plan file instead of a Jira URL to enter revision mode:

```bash
/plan-implementation ./.plans/implementation-plan-PROJ-123-2026-02-15.md \
  --thoughts "Bulk delete locks the table, need batched soft deletes instead"
```

**Output:** `.plans/implementation-plan-PROJ-123-2026-02-15-rev-1.md`

Key behaviors in revision mode:
- Discusses the proposed changes with you before writing
- **Never overwrites** the original plan — always creates a new `-rev-N` file
- The revision file works directly with `/implement-plan` to continue development

### Flags

| Flag | Description |
|------|-------------|
| `--confluence <urls>` | One or more Confluence page URLs with specs (optional in full mode) |
| `--thoughts <text>` | Your implementation ideas or constraints (**required** in both modes) |

---

## `/implement-plan`

Takes an implementation plan and executes it phase by phase. This is an **interactive command** — it discusses architecture with you, implements one phase at a time, and waits for your confirmation before advancing.

### Usage

```bash
# With explicit path
/implement-plan ./.plans/implementation-plan-PROJ-123-2026-02-15.md

# Auto-detect latest plan
/implement-plan
```

If no file path is provided, it auto-detects the latest plan from the `.plans/` folder.

### What It Does

1. **Reads the plan** and summarizes it back to you
2. **Architecture discussion** — walks through SOLID principles, MVC structure, service boundaries, design patterns, and file organization
3. **Phase-by-phase implementation** — for each phase:
   - Announces the phase and its goal
   - Writes the implementation code + RSpec tests
   - Checks API permissions and V2 coverage
   - Presents a summary and waits for your approval
4. **Final summary** — lists all files created/modified and architecture decisions

---

## `/implement-plan-nicely`

Identical to `/implement-plan` but with one key addition: it generates and continuously updates a **visual HTML dashboard** that tracks the full progress of the implementation — phases, architecture decisions, file counts, spec results, and issues.

### Usage

```bash
# With explicit path
/implement-plan-nicely ./.plans/implementation-plan-PROJ-123-2026-02-15.md

# Auto-detect latest plan
/implement-plan-nicely
```

If no file path is provided, it auto-detects the latest plan from the `.plans/` folder.

### What It Does

Everything `/implement-plan` does, plus:

1. **Generates an HTML dashboard** before the architecture discussion starts
2. **Updates the dashboard after every significant step** — each architecture sub-discussion, each file created, each spec run, each phase completion
3. **Tracks status visually** with icons: ✅ Complete, 🔄 In Progress, ⏳ Pending, ❌ Failed, ⚠️ Needs Attention
4. **Shows a summary section** with total files created/modified, spec results, architecture decisions, and V2 API coverage
5. **Maintains an issues & notes log** at the bottom for spec failures, decisions, and tech debt

### Output

- Dashboard file: `implementation-progress-[date]-[HHMMSS].html`

---

## `/review`

Reviews code changes and generates an interactive HTML report with categorized findings. Supports local changes and remote merge requests.

### Local Mode — review before commit

```bash
# Review all uncommitted changes
/review

# Review with plan reference (checks if plan needs updating)
/review --plan ./.plans/implementation-plan-PROJ-123-2026-02-15.md
```

### Remote Mode — review a Merge Request

```bash
# GitLab
/review https://gitlab.com/planradar/project/-/merge_requests/123

# GitHub
/review https://github.com/planradar/project/pull/456
```

### Flags

| Flag | Description |
|------|-------------|
| `--plan <path>` | Path to the implementation plan (local mode only). Enables plan revision check after fixes |

### Review Checklist

Every review checks for: N+1 queries, performance issues, security vulnerabilities, SOLID violations, code structure problems, syntax/style issues, spec coverage gaps, backward compatibility breaks, error handling, and Rails best practices.

### Output

- **Local mode:** `review-[date]-[HHMMSS].html` — interactive HTML with checkboxes to select fixes
- **Remote mode:** `review-mr-[MR-ID]-[date].html` — interactive HTML with checkboxes to select comments to post

---

## `/documentation`

Creates or updates Confluence API documentation by analyzing the codebase and the implementation plan. In both New and Update modes, it **updates Swagger docs (via rswag) before generating the Confluence documentation**.

### New Mode — create a new documentation page

```bash
/documentation --new https://planradar.atlassian.net/wiki/spaces/PMT/folder/4040359987 \
  ./.plans/implementation-plan-PROJ-123-2026-02-15.md \
  --thoughts "Checklist field feature, covers CRUD and bulk operations"
```

### Update Mode — update an existing page

```bash
/documentation https://planradar.atlassian.net/wiki/spaces/PMT/pages/4031676438/CheckList+Field+Documentation \
  ./.plans/implementation-plan-PROJ-123-2026-02-15.md \
  --thoughts "Added bulk delete endpoint, updated the update endpoint for partial updates"
```

### Flags

| Flag | Description |
|------|-------------|
| `--new <folder-url>` | Create a new page under this Confluence folder |
| `--thoughts <text>` | Optional context about what was implemented or changed |

### Update Mode Behavior

When updating, it generates an interactive HTML review page (`doc-review-[date]-[HHMMSS].html`) showing a before/after diff of each endpoint. You select which changes to apply before it updates Confluence.

---

## `/full-cycle`

Orchestrates the entire development lifecycle — from requirements analysis through implementation, review, and documentation — in a single automated pipeline with a live HTML dashboard. It chains all 5 stages together, auto-continuing where safe and pausing only at critical decisions.

### Usage

```bash
# Single ticket
/full-cycle PROJ-123

# Multiple tickets
/full-cycle PROJ-123 PROJ-456 PROJ-789

# With Figma designs
/full-cycle PROJ-123 PROJ-456 --figma https://www.figma.com/design/abc/File1

# With linked tasks
/full-cycle PROJ-123 --check-linked-tasks

# Full combo
/full-cycle PROJ-123 PROJ-456 --check-linked-tasks --figma https://www.figma.com/design/abc/File1

# Sprint
/full-cycle "Sprint 5"
```

### Flags

| Flag | Description |
|------|-------------|
| `--figma <urls>` | One or more Figma file URLs to analyze |
| `--check-linked-tasks` | Also fetch linked issues, subtasks, priority, and status |

### Pipeline Stages

1. **Requirements Analysis** — fetches Jira stories + Figma designs, maps them, detects mismatches, publishes to Confluence
2. **Implementation Planning** — generates a phased plan from Jira + Confluence + analysis context
3. **Implementation** — executes the plan phase by phase with architecture discussion (uses `/implement-plan-nicely` workflow)
4. **Code Review** — reviews all changes and generates an interactive HTML report
5. **Documentation** — creates or updates Confluence API documentation

### Pause Points

The pipeline pauses only at critical moments: unmapped stories/designs, before plan generation, architecture decisions, after each implementation phase, review results, and documentation target selection. Everything else auto-continues.

### Output

- Master dashboard: `full-cycle-[date]-[HHMMSS].html` — tracks all 5 stages, decisions, and artifacts in one view
- Plus all artifacts from each stage (requirements md, plan md, review HTML, Confluence pages)

---

## Typical Workflow

```
1. /analyze-requirements       →  Understand what to build
2. /plan-implementation        →  Plan how to build it
3. /implement-plan             →  Build it phase by phase
   /implement-plan-nicely      →  Build it with a live progress dashboard
4. /review                     →  Review the code
5. /documentation              →  Document the APIs

Or run everything at once:

   /full-cycle                 →  All 5 stages in one automated pipeline
```

Each step feeds into the next — the requirements analysis informs the plan, the plan drives implementation, the review catches issues, and the documentation captures what was built. Use `/full-cycle` to run the entire pipeline automatically with a single command.
