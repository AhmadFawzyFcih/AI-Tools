# Architecture Discussion — six topics, one at a time

Propose concretely for THIS feature, then confirm with `AskUserQuestion` before moving on. Do not dump all topics at once.

## a. SOLID
- **SRP** — which classes/services, each responsible for what?
- **Open/Closed** — how do we add behavior without modifying existing code?
- **Liskov** — any inheritance? Safe to substitute?
- **Interface Segregation** — is any class forced to depend on methods it doesn't use?
- **Dependency Inversion** — what should be injected instead of hardcoded?
Propose specific classes/modules.

## b. MVC & Clean Architecture
What lives in models vs controllers vs services vs concerns. Business logic in service objects — never fat models or fat controllers. What the API response layer owns.

## c. Service boundaries (SOA)
Separate service objects? Boundaries between them? Communication: direct calls, events, or background jobs?

## d. Design patterns
Suggest only what genuinely fits and say why: Strategy (interchangeable behaviors), Factory (creation logic), Observer (event-driven side effects), Decorator (extend without modifying), Command (encapsulated operations), Repository (data-access abstraction). Never force a pattern.

## e. V2 API coverage
Ask: "Does this feature need V2 API coverage too, or only the current API?" Record the answer — it drives the phase loop.

## f. Folder & file structure
Present the proposed tree, e.g.
```
app/
├── controllers/api/v1/<feature>_controller.rb
├── models/<model>.rb
├── services/<feature>/{create,update,...}_service.rb
└── serializers/<feature>_serializer.rb
spec/
├── controllers/ · models/ · services/<feature>/ · factories/
└── integration/v1/<feature>_spec.rb
```
Confirm or adjust before writing code.
