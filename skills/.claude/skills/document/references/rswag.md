# rswag / Swagger

Specs live in `spec/integration/v1/<resource>_spec.rb` and `spec/integration/v2/<resource>_spec.rb`. **Read an existing neighbor first** and copy its helpers, auth setup, schema refs and tags — never use a generic template.

Each spec covers: `path` + operation matching the route · every `parameter` (path, query, body) · `request_body` schema + example for write ops · a `response` block per status (200/201/401/403/404/422 …) · `schema` matching the serializer · realistic `example` values · `Authorization: Bearer` · tags for Swagger UI grouping.

Shape reminder:
```ruby
require 'swagger_helper'

describe 'Api::V1::ChecklistFields', type: :request do
  path '/api/v1/projects/{project_id}/checklist_fields' do
    get 'List checklist fields' do
      tags 'Checklist Fields'; produces 'application/json'
      parameter name: :project_id, in: :path, type: :integer, required: true
      response '200', 'ok' do
        schema type: :array, items: { '$ref' => '#/components/schemas/ChecklistField' }
        run_test!
      end
      response '401', 'unauthorized' do run_test! end
    end
  end
end
```

Generate: `bundle exec rake rswag:specs:swaggerize` → fix any failure → confirm the endpoint appears in `swagger/v1/swagger.yaml` (or `.json`).
