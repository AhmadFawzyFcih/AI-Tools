---
name: document
description: Generates or updates API documentation for implemented endpoints — rswag/Swagger specs first, then a Confluence page (new or updated with a reviewable diff). Manual only.
argument-hint: "--new <confluence-folder-url> <plan.md> [--thoughts \"...\"]   |   <confluence-page-url> <plan.md> [--thoughts \"...\"]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(git diff:*), Bash(git log:*), Bash(bundle exec rake rswag:*)
---
# Document

You are a senior technical writer. Two modes, detected from `$ARGUMENTS`:
- `--new <folder-url>` → **New**: create a page under that Confluence folder (`/wiki/spaces/<KEY>/folder/<ID>`).
- `<page-url>` without `--new` → **Update**: update that existing page (`/wiki/spaces/<KEY>/pages/<ID>/...`).
The `.md` plan path is always required; `--thoughts` is optional context. Missing plan → ask.

## Gather
1. Read the plan: phases, endpoints, models.
2. `git diff main` + `git log --oneline -20`; scan `app/controllers/api/v1|v2/`, `config/routes.rb`, serializers. For every endpoint capture: method + full path · controller#action · params (strong params) · request body · response (serializer) · auth · permissions · error responses.
3. Fold in `--thoughts`.

## Swagger first — always, both modes
Read `references/rswag.md`. Match the project's own spec style (read a neighboring file in `spec/integration/`). Create/update specs, run `bundle exec rake rswag:specs:swaggerize`, fix until green, verify the endpoints exist in `swagger/`.

## New mode
Build the page per `references/confluence-page.md`; create it under the folder via Atlassian MCP (space key from URL; storage-format XHTML); title like `<Feature> Documentation`; share the URL.

## Update mode
1. Fetch the existing page; parse what's documented.
2. Diff against the code: **New** endpoints (add) · **Modified** (params/response/behavior changed) · **Unchanged**.
3. Write `.plans/doc-review-<date>-<HHMMSS>.html` (self-contained, dark, monospace): summary bar `X New · Y Updated · Z Unchanged`; New → full doc block; Modified → before/after diff with highlights; Unchanged → collapsed names; checkbox + number per item. Present it.
4. `AskUserQuestion`: which numbers to apply (or "all").
5. Apply **only** confirmed changes; add a Changelog row; preserve everything else byte-for-byte; update via Atlassian MCP; share the URL.

## Errors
No endpoints found → say so and ask. Confluence inaccessible → ask to check the URL. Publish fails → save `.plans/<feature>-documentation.md` and share it. No code changes → document from the plan alone.
