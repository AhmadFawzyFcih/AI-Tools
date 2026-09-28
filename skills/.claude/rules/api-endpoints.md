---
paths:
  - "config/routes.rb"
  - "app/controllers/api/**/*.rb"
  - "app/serializers/**/*.rb"
  - "spec/integration/**/*.rb"
---
# API Endpoint Rules

Whenever an API endpoint is added or changed:

1. **Permissions** — update `config/initializers/init_dr_permissions.rb`. Non-negotiable; a hook will remind you but you own it.
2. **V2 coverage** — if the developer confirmed V2 for this feature, implement the V2 endpoint alongside V1.
3. **Swagger** — add or update the rswag integration spec in `spec/integration/v1/` or `spec/integration/v2/` matching the existing project style (read a neighboring spec first — never use a generic template). Then run `bundle exec rake rswag:specs:swaggerize` and confirm the endpoint appears in `swagger/`.
4. **Backward compatibility** — no breaking changes to existing contracts, serializers, or response shapes without a feature flag or versioning. Migrations must be reversible.
