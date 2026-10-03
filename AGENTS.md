# Alias repository instructions

These instructions apply to the entire repository.

## Product and source of truth

Alias is a local iOS party game built with SwiftUI. Product, UX and visual
decisions are documented in `DesignDocs/`. OpenSpec is not used in this
repository workflow and must not be treated as a source of truth.

Use this precedence when sources disagree:

1. The user's current, explicit request.
2. Accepted decisions in `DesignDocs/`.
3. Observable behavior in code and tests.
4. `docs/ARCHITECTURE.md` and other current project documentation.
5. Historical notes.

Do not silently choose between an accepted design decision and current code.
Record or update the entry in `docs/IMPLEMENTATION_GAPS.md`, explain the
mismatch, and ask only when the intended behavior is not already explicit.

## Product change workflow

Before changing user-visible behavior:

1. Read the affected files in `DesignDocs/` and `docs/IMPLEMENTATION_GAPS.md`.
2. Inspect the live implementation and tests for the affected capability.
3. Use accepted DesignDocs decisions directly. If behavior is still unresolved,
   document the decision and obtain agreement before implementation.
4. Implement in focused vertical slices and add tests for each material state
   transition, validation rule and persistence path.
5. Validate implementation against the affected DesignDocs and unaffected
   product invariants.
6. Update `docs/IMPLEMENTATION_GAPS.md` when a mismatch is resolved or found.

## Architecture baseline

Preserve the current lightweight, feature-oriented MVVM architecture unless an
approved design intentionally changes it:

- Keep screens and feature view models together in `<Feature>Module/`.
- Keep SwiftUI views focused on rendering, bindings, and forwarding intent.
- Put validation, transitions, and orchestration in `ObservableObject` view
  models; use `@Published private(set)` for externally observed state that only
  the view model may mutate.
- Add typed destinations to `Route`, navigate through `RouterProtocol`, and
  compose destinations centrally in `AliasApp`.
- Carry new-game data forward through `Team` → `Configuration` →
  `GameConfigModel`; do not introduce unrelated global state.
- Keep mutually exclusive game phases in `GameState` and transition through
  explicit view-model methods.
- Keep shared controls in `Components/`, static word data in `GameData/`, and
  game rules/state in `GameModule/`.
- Persist small preferences as Codable values in `UserDefaults`. Add a
  protocol-backed store only when isolation, migration, or data complexity
  requires it.
- Prefer dependency injection for touched code. Preserve compatibility with
  `Router.shared` through default initializer arguments where needed.
- Do not add coordinators, service containers, repositories, or third-party
  architecture frameworks without a concrete requirement and approved design.

See `docs/ARCHITECTURE.md` for the current component map and known architectural
limitations.

## Verification

Run the shared Xcode scheme after source changes:

```bash
xcodebuild \
  -project Alias/Alias.xcodeproj \
  -scheme Alias \
  -destination 'generic/platform=iOS Simulator' \
  build
```

Run unit tests using an installed simulator, replacing the device name when
needed:

```bash
xcodebuild \
  -project Alias/Alias.xcodeproj \
  -scheme Alias \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:AliasTests \
  test
```

Do not run `AliasUITests`, UI tests, or UI performance tests. Only run them when
the user explicitly requests a UI-test run in the current conversation.

If full Xcode is unavailable, report that constraint rather than claiming the
build or tests passed. Do not rely on the existing template tests as meaningful
coverage.

## Definition of done

A behavior change is complete only when:

- implementation matches every affected requirement and scenario;
- unaffected invariants remain true;
- deterministic XCTest coverage exists for state transitions and configuration
  propagation affected by the change;
- timers, randomness, and persistence are controlled in tests;
- the Xcode build and relevant tests pass, or the exact environment blocker is
  reported;
- resolved entries are updated in `docs/IMPLEMENTATION_GAPS.md`;
- affected DesignDocs remain aligned with the delivered behavior.
