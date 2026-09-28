---
paths:
  - "spec/**/*.rb"
---
# RSpec Conventions

- Spec path mirrors app path: `app/services/foo.rb` → `spec/services/foo_spec.rb`.
- `describe` for the class/module, `context` for scenarios, descriptive `it` names. Use `expect` syntax and `subject`.
- Cover the happy path AND edge cases: invalid input, empty/nil, large data, error conditions.
- FactoryBot over fixtures. `let` / `let!` with minimal setup. Every example independent — no shared state.
- Mock external services; stub predefined returns. Shared examples for common behavior; extract repetitive setup into helpers or custom matchers.
- Comment only where logic is non-obvious.
- Run the affected specs before declaring a phase done: `bundle exec rspec <files>`.
