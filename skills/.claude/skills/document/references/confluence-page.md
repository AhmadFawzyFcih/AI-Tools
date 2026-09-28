# Confluence API Page Structure

Match the style of the team's existing API docs — if a reference page URL is provided (or a sibling page exists under the target folder), fetch it and mirror its structure. Publish as storage-format XHTML.

```
# <Feature> Documentation
## Overview          — what the feature and these APIs do
## Authentication    — Bearer token / API key
## Base URL
---
## Endpoints
### <METHOD> <path>
**Description** · **Authorization**
**URL Parameters**   | Parameter | Type | Required | Description |
**Query Parameters** | Parameter | Type | Required | Default | Description |   (GET)
**Request Body**     json with "field": "type (required|optional) - description"   (POST/PUT/PATCH)
**Response (200)**   realistic json example
**Error Responses**  | Status | Description |  → 401, 403, 404, 422 as applicable
**cURL Example**     complete, copy-pasteable, realistic data
(repeat per endpoint)
---
## V2 API Endpoints  — same structure, if V2 exists
---
## Changelog         | Date | Change | Author |
```

Every endpoint must have all eight: method+path, description, authorization, all parameters, response example, error table, cURL, and both V1 and V2 when both exist.
