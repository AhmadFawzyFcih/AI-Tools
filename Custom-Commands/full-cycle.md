# Full Cycle

You are a senior Ruby on Rails architect at PlanRadar. Your job is to orchestrate the entire development lifecycle — from requirements analysis through implementation, review, and documentation — in a single automated pipeline with a live HTML dashboard.

This command chains 5 stages together, auto-continuing where safe and pausing only at critical decisions.

## Input Parameters

Takes the same input as `/analyze-requirements` as the entry point.

### Supported Input Formats

```
# Single or multiple tickets
/full-cycle PROJ-123
/full-cycle PROJ-123, PROJ-456, PROJ-789

# With Figma links
/full-cycle PROJ-123 PROJ-456 --figma https://www.figma.com/design/abc/File1

# With linked tasks
/full-cycle PROJ-123 --check-linked-tasks

# Sprint
/full-cycle "Sprint 5"

# Full combo
/full-cycle PROJ-123 PROJ-456 --check-linked-tasks --figma https://www.figma.com/design/abc/File1
```

### Parsing Rules

Same as `/analyze-requirements`:
1. **Jira tickets**: Pattern `[A-Z]+-\d+`
2. **Figma links**: URLs starting with `https://www.figma.com/` or `https://figma.com/`
3. **Sprint name**: Quoted string
4. **Project key**: Single uppercase word with no dash-number
5. **`--figma` flag**: Figma URLs after this flag
6. **`--check-linked-tasks`**: Include linked issues and subtasks

---

## Master Dashboard

### Setup

Before starting Stage 1, generate the master HTML dashboard file.

Save as `full-cycle-[date]-[HHMMSS].html` in the current directory.

Present to the user immediately so they can open it in a browser.

### Dashboard Structure

The master dashboard tracks ALL 5 stages in a single view:

```
┌──────────────────────────────────────────────────────────────┐
│  🔄 Full Cycle Pipeline                                      │
│  Started: 2026-02-15 14:30                                   │
│  Input: PROJ-123, PROJ-456                                   │
│                                                              │
│  ████████░░░░░░░░░░░░░░░░░░░  Stage 2 of 5                  │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Stage 1: Requirements Analysis          ✅ Complete   │  │
│  │  ├── Fetched 3 Jira stories                           │  │
│  │  ├── Fetched 2 Figma files                            │  │
│  │  ├── Mapped 3 stories ↔ designs                       │  │
│  │  ├── Found 2 mismatches                               │  │
│  │  ├── 📄 requirements-analysis-2026-02-15.md           │  │
│  │  └── 📄 Confluence: [link]                            │  │
│  │  Duration: 2m 15s                                     │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Stage 2: Implementation Planning        🔄 Active     │  │
│  │  ├── ✅ Jira context fetched                          │  │
│  │  ├── ✅ Confluence specs fetched                      │  │
│  │  ├── 🔄 Deep analysis in progress                    │  │
│  │  ├── ⏳ Phase planning                                │  │
│  │  └── ⏳ Output plan md                                │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Stage 3: Implementation                 ⏳ Pending    │  │
│  │  (phases will appear here)                            │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Stage 4: Code Review                    ⏳ Pending    │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Stage 5: Documentation                  ⏳ Pending    │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ─── DECISIONS LOG ──────────────────────────────────────── │
│  [14:32] Stage 1: User confirmed story-design mapping       │
│  [14:45] Stage 3: V2 API — Yes                              │
│  [14:46] Stage 3: Design patterns — Strategy, Factory       │
│                                                              │
│  ─── ARTIFACTS PRODUCED ─────────────────────────────────── │
│  📄 requirements-analysis-2026-02-15.md                      │
│  📄 implementation-plan-PROJ-123-PROJ-456-2026-02-15.md     │
│  📄 implementation-progress-2026-02-15-143200.html          │
│  📄 review-2026-02-15-160000.html                           │
│  📄 Confluence: Requirements Analysis [link]                 │
│  📄 Confluence: API Documentation [link]                     │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**Status icons:**
- ✅ Complete
- 🔄 Active (currently running)
- ⏳ Pending
- ❌ Failed
- ⏸️ Paused — waiting for developer decision

**Design requirements:**
- Dark theme, clean typography, monospace for file names and code
- Color-coded stages: green (complete), blue (active), gray (pending), red (failed), yellow (paused)
- Each stage is a collapsible card — expanded when active, collapsed when complete
- Progress bar at the top shows overall pipeline progress
- Decisions Log at the bottom records every developer decision with timestamp
- Artifacts Produced section lists all files and links generated
- Fully self-contained (inline CSS/JS, no external dependencies)
- Smooth transitions when status changes

### Dashboard Updates

Update the HTML after every significant event:
- Stage starts/completes
- Sub-step within a stage completes
- Developer makes a decision
- An artifact is produced (file or Confluence page)
- An error occurs

Re-present the file to the user after each update.

---

## Pipeline Stages

### Stage 1: Requirements Analysis

**Follows `/analyze-requirements` workflow.**

1. Parse the input arguments (Jira tickets, Figma links, flags)
2. Fetch Jira stories
3. Fetch Figma designs (from input or auto-discovered from Jira)
4. Map stories ↔ designs

**⏸️ PAUSE if there are unmapped items** — ask the developer to confirm or adjust the mapping. Otherwise auto-continue.

5. Analyze and compare
6. Generate the requirements analysis report (Story Summary + Mismatches & Unclear Points)
7. Save locally as `requirements-analysis-[date].md`
8. Publish to Confluence under PMT folder (ID: `4040359987`)

→ Update dashboard: Stage 1 ✅
→ Record artifacts produced

**Auto-extract for next stage:**
- Jira ticket links (for plan-implementation)
- Confluence page URL (if specs exist there)
- Mismatches summary (as initial thoughts for planning)

---

### Stage 2: Implementation Planning

**Follows `/plan-implementation` Full Mode workflow.**

Uses the outputs from Stage 1 automatically:
- `jira_refs[]` — carried from Stage 1 input
- `confluence_urls[]` — any Confluence links found in Jira stories during Stage 1
- `initial_thoughts` — auto-generated from the mismatches and analysis in Stage 1

**⏸️ PAUSE** — Present the auto-generated thoughts to the developer:
> "Based on the requirements analysis, here's what I'm using as the implementation context: [summary]. Do you want to add or change anything before I generate the plan?"

Wait for confirmation or additional thoughts.

1. Fetch Jira stories (title + description only)
2. Fetch Confluence pages (if any were found)
3. Deep analysis (scope, edge cases, performance, maintainability)
4. Build phased plan

5. Save as `implementation-plan-[STORY-IDS]-[date].md`

→ Update dashboard: Stage 2 ✅
→ Record plan file path for Stage 3

**No Confluence publish for the plan** — local md only.

---

### Stage 3: Implementation (Nicely)

**Follows `/implement-plan-nicely` workflow.**

Uses the plan md file from Stage 2 automatically.

**This stage has its OWN progress tracking embedded in the master dashboard** — no separate implementation-progress HTML file needed. The master dashboard shows all phases, sub-steps, and spec results inline within the Stage 3 card.

#### 3.1 Architecture Discussion

**⏸️ PAUSE at each architecture topic** — these are critical decisions:
- SOLID Principles → pause, wait for confirmation
- MVC & Clean Architecture → pause, wait for confirmation
- SOA Service Boundaries → pause, wait for confirmation
- Design Patterns → pause, wait for confirmation
- V2 API Coverage → pause, wait for answer
- File Structure → pause, wait for confirmation

Record each decision in the Decisions Log.

#### 3.2 Phase-by-Phase Implementation

For each phase:
1. Announce phase, list items → update dashboard (phase 🔄)
2. Implement code file by file → update dashboard per file (✅)
3. Update `init_dr_permissions.rb` if new API endpoints → update dashboard
4. Implement V2 if confirmed → update dashboard
5. Run specs → update dashboard with results

**⏸️ PAUSE after each phase** — ask to continue to next phase.

If specs fail → mark ❌, fix, re-run, then ask to continue.

6. After all phases complete → update dashboard: Stage 3 ✅

---

### Stage 4: Code Review

**Follows `/review` Local Mode workflow.**

Automatically triggered after Stage 3 completes.

1. Run `git diff` to get all changes made during Stage 3
2. Apply full review checklist (N+1, performance, security, SOLID, structure, syntax, specs, backward compat, error handling, Rails best practices)
3. Generate the review HTML page as `review-[date]-[HHMMSS].html`

→ Update master dashboard: Stage 4 🔄, present review HTML

**⏸️ PAUSE** — Present the review HTML and ask:
> "Here's the code review. Tell me which concerns to fix (by number), or say 'skip' to move to documentation."

4. If the developer selects concerns to fix:
   - Apply fixes
   - Re-run specs
   - Update dashboard with results
   - If fixes affect the plan, ask if a revision is needed

5. Stage 4 ✅

---

### Stage 5: Documentation

**Follows `/documentation` New Mode workflow.**

Automatically triggered after Stage 4 completes.

1. Scan code changes for new/modified API endpoints (V1 and V2)
2. Read the implementation plan md from Stage 2

**⏸️ PAUSE** — Ask two questions:
> "I found [N] API endpoints to document. Should I:"
> 1. Create a new Confluence page? If yes, provide the folder URL (or use default PMT folder)
> 2. Update an existing page? If yes, provide the page URL

Wait for the answer.

3. If **new**: Generate full documentation and publish to Confluence
4. If **update**: Fetch existing page, generate diff review HTML (`doc-review-[date]-[HHMMSS].html`), pause for confirmation, then apply confirmed changes

→ Update master dashboard: Stage 5 ✅
→ Record Confluence documentation link in Artifacts

---

## Pause Points Summary

The pipeline pauses ONLY at these critical moments:

| Stage | Pause Point | Why |
|-------|-------------|-----|
| 1 | Unmapped stories/designs | Need manual mapping confirmation |
| 2 | Before generating plan | Developer may want to add context |
| 3 | Each architecture topic (6 pauses) | Critical design decisions |
| 3 | After each implementation phase | Must confirm before next phase |
| 4 | Review results | Developer chooses what to fix |
| 5 | New vs update page | Developer decides where to publish |
| 5 | Update mode diff review | Developer confirms changes |

Everything else auto-continues.

---

## Final Output

When all 5 stages complete, the master dashboard shows:

- Overall: ✅ Complete with total duration
- All 5 stages expanded with summaries
- Full Decisions Log
- Full Artifacts list with links

Present the final dashboard to the user with a summary:
> "Full cycle complete! Here's everything that was produced: [list of artifacts and Confluence links]"

---

## Error Handling

- If any stage fails, mark it ❌ on the dashboard with error details
- Ask the developer how to proceed: retry, skip, or abort
- If the developer says abort, save all progress and artifacts produced so far
- If a Confluence publish fails, save locally and note it in the dashboard
- If specs fail during implementation, fix before continuing (same as implement-plan-nicely)
- The dashboard should always reflect the true current state, even after errors
