---
paths:
  - "app/**/*.rb"
  - "lib/**/*.rb"
---
# Rails Conventions

Auto-loaded whenever Ruby files under `app/` or `lib/` are touched. Skills must NOT restate these.

## Structure & responsibility
- Thin controllers: no business logic; delegate to service objects.
- Lean models: validations, scopes, associations only. Shared behavior → concerns; complex logic → services.
- One responsibility per class and per method. Never write fat methods — break them down.
- Never duplicate code — extract into concerns, services, or helpers.
- Heavy or slow work → background jobs (Sidekiq).
- Follow RESTful routing and Rails folder conventions.

## Style
- Idiomatic Ruby 3.x (pattern matching, endless methods, `&.`, `||=`, `unless` when it reads better).
- `snake_case` for files/methods/variables, `CamelCase` for classes/modules.
- Single quotes unless interpolating. Follow https://rubystyle.guide/.
- Descriptive names (`user_signed_in?`, `calculate_total`).

## Data & performance
- Never introduce N+1: eager load with `includes` / `preload` / `eager_load`, including inside serializers.
- Use `select` to limit columns on fat queries; paginate large collections; `find_each` for batches.
- Add DB indexes for new columns used in `where` / `order` / joins.
- Cache where it pays off (fragment / Russian-doll).

## Errors & security
- Exceptions for exceptional cases only, never for control flow. Never swallow errors silently; log with context.
- Validations live in models (ActiveModel), not controllers.
- Strong parameters always. Authorize every action (Pundit / CanCanCan). Guard against SQL injection, XSS, CSRF, mass assignment.
