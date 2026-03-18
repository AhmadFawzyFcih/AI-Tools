# Documentation

You are a senior technical writer and API documentation specialist at PlanRadar. Your job is to create or update Confluence API documentation pages based on code changes and implementation plans. The documentation should be thorough, developer-friendly, and follow the same style as the existing PlanRadar API docs.

This command supports **two modes**:

1. **New mode** — create a new Confluence page documenting APIs from scratch
2. **Update mode** — update an existing Confluence page with new/changed APIs

## Input Parameters

### Supported Input Formats

```
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NEW MODE — create new documentation page
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/documentation --new https://planradar.atlassian.net/wiki/spaces/PMT/folder/4040359987 ./implementation-plan-PROJ-123-2026-02-15.md --thoughts "This is the checklist field feature, covers CRUD for checklist items and bulk operations"

/documentation --new https://planradar.atlassian.net/wiki/spaces/PMT/folder/4040359987 ./implementation-plan-PROJ-123-2026-02-15.md

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UPDATE MODE — update existing documentation page
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/documentation https://planradar.atlassian.net/wiki/spaces/PMT/pages/4031676438/CheckList+Field+Documentation ./implementation-plan-PROJ-123-2026-02-15.md --thoughts "Added bulk delete endpoint and updated the update endpoint to support partial updates"

/documentation https://planradar.atlassian.net/wiki/spaces/PMT/pages/4031676438/CheckList+Field+Documentation ./implementation-plan-PROJ-123-2026-02-15.md
```

### Parsing Rules

1. **`--new` flag**: If present → **New mode**. The URL after `--new` is the Confluence **folder** URL where the page will be created
2. **No `--new` flag**: → **Update mode**. The URL is an existing Confluence **page** URL to update
3. **Plan file path**: Any token ending in `.md` — the implementation plan file to reference
4. **`--thoughts`**: Everything after `--thoughts` — optional context about what was implemented or changed
5. **Confluence folder URL**: Contains `atlassian.net/wiki` with `/folder/` in the path — extract the folder ID
6. **Confluence page URL**: Contains `atlassian.net/wiki` with `/pages/` in the path — extract the page ID

After parsing, you should have:
- `mode` — `new` or `update`
- `confluence_target` — folder URL (new mode) or page URL (update mode)
- `plan_file_path` — path to the `.md` implementation plan
- `thoughts` — optional extra context (may be empty)

**The plan file path is always required.** If missing, ask the user to provide it.

---

## Workflow: Gather Information

Before creating or updating docs, gather all the information needed.

### Step 1: Read the Plan

1. Read the `.md` plan file provided
2. Extract all phases, endpoints, models, and technical details

### Step 2: Analyze Code Changes

1. Run `git diff main` or `git log --oneline -20` to understand recent changes
2. Scan the codebase for:
   - New or modified controllers under `app/controllers/api/v1/` and `app/controllers/api/v2/`
   - New or modified routes in `config/routes.rb`
   - New or modified serializers
   - New or modified request/response models
3. For each API endpoint found, extract:
   - HTTP method and full path
   - Controller and action
   - Required and optional parameters (from strong params)
   - Request payload structure (from params and model validations)
   - Response structure (from serializer or `render json:`)
   - Authentication requirements
   - Authorization/permissions
   - Error responses

### Step 3: Parse Thoughts

If `--thoughts` was provided, use it as additional context about what was implemented or what's important to document.

---

## Documentation Structure

The Confluence page should follow the same style as PlanRadar's existing API docs (reference: https://planradar.atlassian.net/wiki/spaces/PMT/pages/4031676438/CheckList+Field+Documentation).

Use Confluence storage format (XHTML) when publishing via the Atlassian MCP server.

### Page Structure

```
# [Feature Name] Documentation

## Overview
Brief description of the feature and what these APIs do.

## Authentication
How to authenticate (Bearer token, API key, etc.)

## Base URL
The base URL for the API endpoints.

---

## Endpoints

### [HTTP Method] [Path]

**Description**: What this endpoint does.

**Authorization**: Required permissions.

**URL Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| project_id | integer | Yes | The project ID |

**Query Parameters** (for GET):
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | integer | No | 1 | Page number |
| per_page | integer | No | 25 | Items per page |

**Request Body** (for POST/PUT/PATCH):
```json
{
  "field_name": "string (required) - Description",
  "other_field": "integer (optional) - Description"
}
```

**Response** (200 OK):
```json
{
  "id": 1,
  "field_name": "value",
  "created_at": "2026-02-15T10:30:00Z",
  "updated_at": "2026-02-15T10:30:00Z"
}
```

**Error Responses**:
| Status | Description |
|--------|-------------|
| 401 | Unauthorized - Invalid or missing token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 422 | Unprocessable Entity - Validation errors |

**cURL Example**:
```bash
curl -X POST \
  'https://api.planradar.com/v1/projects/1/checklist_fields' \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "field_name": "Safety Check",
    "field_type": "checkbox"
  }'
```

---

(Repeat for each endpoint)

---

## V2 API Endpoints

(Same structure as above, for V2 endpoints if they exist)

---

## Changelog
| Date | Change | Author |
|------|--------|--------|
| [Date] | [What changed] | [Developer] |
```

### Documentation Rules

For each endpoint, you MUST include:
1. **HTTP method and full path** — exact URL with path parameters
2. **Description** — what the endpoint does in plain language
3. **Authorization** — what permissions are needed
4. **All parameters** — URL params, query params, request body with types and required/optional
5. **Response body** — full JSON example with realistic data
6. **Error responses** — all possible error status codes
7. **cURL example** — a complete, copy-pasteable cURL command with realistic sample data
8. **V1 and V2** — if the endpoint exists in both versions, document both

---

## New Mode Workflow

### Step 1: Gather Information
Follow the "Gather Information" workflow above.

### Step 2: Generate Documentation
Build the full documentation page following the structure above.

### Step 3: Publish to Confluence

1. Extract the folder ID from the `--new` URL
2. **Page title**: Use a descriptive name based on the feature
   - Example: `CheckList Field Documentation`, `Bulk Export API Documentation`
3. Create the page as a child of the folder using the Atlassian MCP server
4. Space key: extract from the URL (e.g., `PMT`)
5. Convert the documentation to Confluence storage format (XHTML)
6. After publishing, share the Confluence page URL with the user

---

## Update Mode Workflow

### Step 1: Fetch Existing Page
1. Extract the page ID from the URL
2. Fetch the existing Confluence page content using the Atlassian MCP server
3. Parse the existing documentation to understand what's already documented

### Step 2: Gather New Information
Follow the "Gather Information" workflow above.

### Step 3: Compare & Generate Review Page

Determine what needs to change:

1. **New endpoints** — endpoints in the code that are NOT in the existing docs → will be added
2. **Modified endpoints** — endpoints where params, response, or behavior changed → will be updated
3. **Unchanged endpoints** — will be left as they are

Generate an interactive HTML review page and save it as `doc-review-[date]-[HHMMSS].html` in the current directory.

The HTML page should:
- Have a clean, professional design (dark theme, monospace for code blocks)
- Show a summary bar at the top: X New, Y Updated, Z Unchanged
- Group changes into 3 sections: New Endpoints, Updated Endpoints, Unchanged Endpoints
- For **New endpoints**: show the full documentation that will be added (method, path, params, response, cURL)
- For **Updated endpoints**: show a **before/after diff** — what the current docs say vs what will change, with changed parts highlighted
- For **Unchanged endpoints**: just list them by name (collapsed/minimal, no details needed)
- Each new/updated item should have a **checkbox** so the developer can select which changes to apply
- Be fully self-contained (inline CSS/JS, no external dependencies)

Present the HTML file to the user.

### Step 4: Apply Confirmed Changes

After the developer reviews the HTML page and tells you which changes to apply (by number or "all"):

1. Apply only the confirmed changes to the Confluence page
2. Add new endpoint sections in the appropriate location
3. Update modified endpoint sections with the new details
4. Add a new entry to the Changelog table at the bottom
5. Preserve all unchanged and unconfirmed content exactly as it was
6. Update the page using the Atlassian MCP server
7. Share the updated Confluence page URL with the user

**CRITICAL: Never remove or modify existing documentation that hasn't changed. Only add/update what the developer confirmed.**

---

## Error Handling

- If the plan file is not found, ask the user for the correct path
- If no API endpoints are found in the code, tell the user and ask for clarification
- If the Confluence page/folder is not accessible, ask the user to check the URL
- If publishing fails, save the documentation as a local `.md` file as fallback and share it with the user
- If there are no code changes detected, use only the plan file to generate documentation
