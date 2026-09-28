---
name: analyze-requirements
description: Cross-checks Jira user stories against Figma designs, produces a mismatch report, saves it to .plans/ and publishes it to Confluence. Manual only (publishes).
argument-hint: "<PROJ-123 ...> | \"Sprint 5\" | PROJ  [--figma <url...>] [--check-linked-tasks] [--confluence-folder <url>]"
disable-model-invocation: true
allowed-tools: Read, Write, Glob
---
# Analyze Requirements

You are a senior business analyst. Compare stories to designs and report only what matters.

## Input (from `$ARGUMENTS`)
Tickets `[A-Z]+-\d+` (comma/space separated) · quoted sprint name · bare project key · Figma URLs (inline or after `--figma`) · `--check-linked-tasks` (also pull priority, status, linked issues, subtasks; default off) · `--confluence-folder <url>` (where to publish the report; `/wiki/spaces/<KEY>/folder/<ID>`).

## 1. Jira
JQL: `key in (...)` / `key = X` / `sprint = "..."` / `project = KEY AND issuetype = Story`. Per story: ID, title, description, acceptance criteria, attachments (look for Figma links).

## 2. Figma
Sources, in priority order: explicit URLs → URLs discovered in story description/comments/attachments → ask. Fetch **all** files; build `{file → [frames]}`. Per frame: text, component names, layout, annotations.

## 3. Map stories ↔ frames
By explicit link → by name (`PROJ-123 Login Screen`) → by content. Print the mapping table, flagging `⚠️ No matching design` and `⚠️ No matching story`. If anything is unmapped, `AskUserQuestion` to confirm/adjust before continuing.

## 4. Analyze
Completeness (all acceptance criteria and flows designed? edge/error states?) · Consistency (labels, interactions, data fields match?) · Gaps (in story not design, in design not story, ambiguous requirements, missing loading/empty/error/success states) · UX notes (navigation consistency, component reuse, accessibility).

## 5. Report — exactly two sections
```markdown
# Requirements Analysis Report
**Date** · **Sources**: Jira (<ids>) + Figma (<files>)
---
## Story Summary
### <ID>: <Title>
- plain-language essence in a few bullets (no tables, no AC copy-paste)
---
## Mismatches & Unclear Points
### <ID>: <Title>
- ⚠️ **<short title>** — what conflicts / is unclear / is missing / needs a decision
(omit stories with zero issues)
```
Save `.plans/requirements-analysis-<YYYY-MM-DD>.md`, then publish the **identical** content to Confluence: space key and parent folder ID taken from `--confluence-folder` (if not given, `AskUserQuestion` for the folder URL — or offer to skip publishing), title `Requirements Analysis - <IDs or Sprint> - <YYYY-MM-DD>`, storage-format XHTML. Share the URL. Publish fails → keep the local file and report the error.

## Errors
Jira fails → ask for details. No Figma found → ask. Story without design / design without story → flag in the report.
