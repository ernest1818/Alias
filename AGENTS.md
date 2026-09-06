# Alias repository instructions

These instructions apply to the entire repository.

## Product and source of truth

Alias is a local iOS party game built with SwiftUI. The active behavioral
contract lives in `openspec/specs/`; `openspec/config.yaml` contains shared
project context and artifact rules.

Use this precedence when sources disagree:

1. The user's current, explicit request.
2. An approved active delta in `openspec/changes/<change-name>/specs/`.
3. The current capability specs in `openspec/specs/`.
4. Observable behavior in code and tests.
5. Historical notes and archived changes.

Do not silently choose between a spec and code mismatch. Record or update the
entry in `docs/IMPLEMENTATION_GAPS.md`, explain the mismatch, and confirm whether
the code or the spec should change when intent is not already explicit.

## SDD workflow

Before changing user-visible behavior:

1. Read `openspec/config.yaml`, the affected current specs, and
   `docs/IMPLEMENTATION_GAPS.md`.
2. Inspect the live implementation and tests for the affected capability.
3. Create a focused OpenSpec change with `proposal.md`, delta specs, optional
   `design.md`, and `tasks.md` before implementation.
4. Use `ADDED`, `MODIFIED`, `REMOVED`, or `RENAMED` requirements in deltas.
5. Obtain agreement on the behavior before implementing it.
6. Implement tasks, add tests for each material scenario, then validate code
   against both the delta and unaffected current specs.
7. Archive the change only after implementation and verification are complete.

Keep current specs under one `## Requirements` section. Every requirement must
contain at least one `#### Scenario:`. Specs describe observable behavior;
implementation choices belong in `design.md` or architecture documentation.

Small internal refactors that cannot alter observable behavior may omit delta
specs, but their proposal must explicitly set or document `skip_specs: true`.

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

Run specification validation after changing specs or deltas:

```bash
openspec validate --all --strict --no-interactive
```

Run the shared Xcode scheme after source changes:

```bash
xcodebuild \
  -project Alias/Alias.xcodeproj \
  -scheme Alias \
  -destination 'generic/platform=iOS Simulator' \
  build
```

Run tests using an installed simulator, replacing the device name when needed:

```bash
xcodebuild \
  -project Alias/Alias.xcodeproj \
  -scheme Alias \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  test
```

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
- OpenSpec strict validation passes;
- the Xcode build and relevant tests pass, or the exact environment blocker is
  reported;
- resolved entries are updated in `docs/IMPLEMENTATION_GAPS.md`;
- the accepted delta is merged into current specs and archived.
