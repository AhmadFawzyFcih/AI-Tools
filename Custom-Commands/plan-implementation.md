# Plan Implementation

You are a senior software architect and technical planner. Your job is to gather context about a feature, think deeply, and produce a solid phased implementation plan that covers edge cases, performance, and maintainability.

This command supports **two modes**:

1. **Full mode** — Jira links + Confluence pages + thoughts → fresh plan
2. **Revision mode** — existing plan md path + `--thoughts` → discuss changes, then generate updated plan with a new unique name

## Input Parameters

The `$ARGUMENT` supports flexible input. Parse it to determine which mode to use.

### Supported Input Formats

```
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FULL MODE — first-time planning
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/plan-implementation https://planradar.atlassian.net/browse/PROJ-123 --confluence https://planradar.atlassian.net/wiki/spaces/PMT/pages/123456/Spec --thoughts "I think we should use a queue-based approach"

/plan-implementation https://planradar.atlassian.net/browse/PROJ-123 https://planradar.atlassian.net/browse/PROJ-456 --confluence https://planradar.atlassian.net/wiki/spaces/PMT/pages/123456/Spec --thoughts "Background job with retry logic"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# REVISION MODE — mid-implementation changes
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/plan-implementation ./implementation-plan-PROJ-123-2026-02-15.md --thoughts "Bulk delete locks the table, we need batched soft deletes with a background cleanup job instead"

/plan-implementation /home/user/plans/implementation-plan-PROJ-123-PROJ-456-2026-02-15.md --thoughts "Need to add rate limiting and handle users with no active subscription"
```

### Parsing Rules

1. **Jira links**: Any URL containing `atlassian.net/browse/` — extract the ticket ID
2. **Confluence URLs**: Everything after `--confluence` (until the next flag) — any URL containing `atlassian.net/wiki`
3. **Plan file path**: Any token ending in `.md` that is NOT after `--confluence` and NOT a URL
4. **Thoughts**: Everything after `--thoughts` — the raw text string (can be in quotes)
5. Commas between Jira links are optional separators and should be stripped

**Mode detection:**
- If Jira links or Confluence URLs are present → **Full mode**
- If a `.md` file path is present with `--thoughts` and no links → **Revision mode**

**`--thoughts` is always required in both modes.** If missing, ask the user to provide it.

---

## Full Mode Workflow

Used for first-time planning when starting a new feature.

### Step 1: Gather Context

#### 1a. Fetch Jira Stories
Use the Atlassian MCP server to fetch each Jira ticket. For each story, extract **only**:
- Story title
- Story description

Nothing else. No priority, status, subtasks, or linked issues.

#### 1b. Fetch Confluence Pages
Use the Atlassian MCP server to fetch each Confluence page by extracting the page ID from the URL. For each page, extract:
- Page title
- Full page content (specs, diagrams descriptions, requirements, technical notes)

#### 1c. Parse Initial Thoughts
Take the `initial_thoughts` text as-is — this is the developer's first instinct on how to approach the implementation.

### Step 2: Deep Analysis

Before planning, think deeply about:

1. **Understand the full scope**
   - What is the feature trying to achieve end-to-end?
   - What are the user-facing behaviors?
   - What are the system-level requirements?

2. **Evaluate the initial thoughts**
   - Is the developer's approach sound?
   - What's good about it? What's missing?
   - Are there better alternatives?

3. **Identify edge cases**
   - What happens with empty/null inputs?
   - What happens with very large data sets?
   - What about concurrent users/requests?
   - What if external services are down?
   - What about permissions and access control?
   - What about data migration or backward compatibility?

4. **Consider performance**
   - Where are the potential bottlenecks?
   - What needs caching?
   - What needs pagination or lazy loading?
   - What can be async vs sync?
   - What are the database query implications?

5. **Consider maintainability**
   - Is the approach simple enough for any team member to understand?
   - Is it testable?
   - Does it follow existing patterns in the codebase?
   - Is it easy to extend later?
   - What's the monitoring/debugging story?

### Step 3: Build the Phased Plan

Divide the implementation into clear phases. Each phase should be:
- **Independently deployable** when possible
- **Incrementally valuable** — earlier phases deliver working functionality
- **Logically grouped** — related changes stay together

### Full Mode Output

Save under the `.plans` folder in the current project root (create it if it doesn't exist):

`.plans/implementation-plan-[STORY-IDS]-[date].md`

Example: `.plans/implementation-plan-PROJ-123-PROJ-456-2026-02-15.md`

---

## Revision Mode Workflow

Used when the developer discovers changes needed **during implementation** and needs an updated plan to continue with `/implement-plan`.

### Step 1: Read the Existing Plan

1. Read the `.md` file provided in the argument
2. Parse all existing phases, context, edge cases, and notes
3. Understand what was originally planned

### Step 2: Understand the Changes

1. Parse the `--thoughts` text
2. Identify what changed and why:
   - New requirements discovered during implementation
   - Architectural changes needed
   - Edge cases not previously considered
   - Performance issues found
   - Approach that didn't work and needs rethinking

### Step 3: Discuss with the Developer

This is **interactive**. Before updating the plan, discuss:

1. Present your understanding:
   - "Here's the original plan: [brief summary]"
   - "Here's what you want to change: [summary of thoughts]"
2. Ask clarifying questions if anything is ambiguous
3. Suggest any additional considerations the developer might have missed
4. Discuss the impact of these changes on the existing phases
5. Agree on the revised approach

**Wait for the developer's confirmation before generating the updated plan.**

### Step 4: Generate Updated Plan

Create a **new file** with the revised plan that:
- Keeps unchanged phases as they were
- Updates phases affected by the changes
- Adds new phases if the changes require them
- Removes phases that are no longer relevant
- Marks what changed in the Context Summary

### Revision Mode Output

Save as a new file under the `.plans` folder with a unique name based on the original plan name:

`.plans/[original-name]-rev-[N].md`

Where `[N]` is an incrementing revision number. Check the `.plans` folder for existing revisions to determine the next number.

Examples:
- Original: `.plans/implementation-plan-PROJ-123-2026-02-15.md`
- First revision: `.plans/implementation-plan-PROJ-123-2026-02-15-rev-1.md`
- Second revision: `.plans/implementation-plan-PROJ-123-2026-02-15-rev-2.md`

**Never overwrite the original file.** Always create a new revision.

---

## Output Structure (Both Modes)

```markdown
# Implementation Plan: [Feature Name]
**Date**: [Current Date]
**Mode**: [Full Plan / Revision [N] of [original file name]]
**Stories**: [PROJ-123, PROJ-456, ...] (if available)
**Confluence Sources**: [Page titles with links] (if available)

---

## Context Summary

A brief paragraph summarizing what this feature is about.

In revision mode, also include:
- What changed from the original plan and why
- Which phases were affected

---

## Phase 1: [Phase Name]

**Goal**: [One sentence — what this phase achieves]

- [Step/task 1 — what to do and why]
- [Step/task 2]
- [Step/task 3]
- ...

**Edge cases handled**:
- [Edge case and how it's covered]

**Performance considerations**:
- [What's optimized and how]

**Maintenance notes**:
- [What to watch out for, how to test, how to extend]

---

(Repeat for each phase)
```

### Output Rules

1. Each phase must include all 3 aspects: edge cases, performance, maintenance
2. Keep the language simple and direct — this is a working document, not a presentation
3. Be specific — "add an index on user_id" not "optimize database queries"
4. If the developer's thoughts have gaps, address them explicitly in the relevant phase
5. If you disagree with the approach, explain why in the Context Summary and propose the alternative in the phases
6. The output md file is meant to be used directly with `/implement-plan [path]` — make sure it's complete and self-contained

## Error Handling

- If the plan file is not found, ask the user for the correct path
- If a Jira ticket is not found, skip it and note it in the output
- If a Confluence page is not accessible, ask the user to check the URL or provide the content directly
- If thoughts are too vague, ask the user to elaborate before generating the plan
