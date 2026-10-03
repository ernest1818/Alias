---
name: apply-alias-architecture
description: Preserve and apply the architectural decisions of the Alias iOS SwiftUI repository. Use when Codex analyzes, implements, refactors, or reviews Alias features involving view/view-model boundaries, typed navigation, game configuration, state machines, persistence, shared components, or testability.
---

# Apply Alias Architecture

## Establish context

1. Locate `Alias.xcodeproj` and read the repository `AGENTS.md`.
2. Inspect the affected feature and its nearest analogous feature; treat live source as authoritative.
3. Read [references/architecture.md](references/architecture.md) before making an architectural recommendation or code change.
4. State whether a proposal preserves the current baseline or intentionally improves a documented limitation.

## Place responsibilities

- Keep screens and feature-specific view models together in `<Feature>Module/`.
- Keep SwiftUI views focused on rendering, bindings, and forwarding user intent.
- Put screen state, validation, transitions, and orchestration in an `ObservableObject` view model.
- Publish externally observed state with `@Published`; prefer `private(set)` when only the view model should mutate it.
- Put reusable visual controls in `Components/`, typed destinations in `Navigation/`, static word data in `GameData/`, and game rules/state in `GameModule/`.
- Model route payloads and configuration as value types conforming to `Hashable` when required by `NavigationStack`.

## Extend existing flows

- Add navigation destinations to `Route`, mutate navigation only through `RouterProtocol`, and render destinations centrally in `AliasApp`.
- Carry new-game setup through `Team` -> `Configuration` -> `GameConfigModel`; avoid unrelated global state.
- Represent mutually exclusive game phases with `GameState` and explicit view-model transition methods.
- Persist small user preferences through a dedicated Codable value encoded in `UserDefaults`; introduce a repository only when storage requirements materially exceed that design.
- Inject new collaborators behind protocols. Preserve compatibility with `Router.shared` through a default initializer argument when needed, rather than hard-coding new singleton dependencies.

## Validate the result

- Keep changes local; do not introduce coordinators, service containers, or third-party architecture frameworks without a concrete requirement.
- Add XCTest coverage for view-model transitions and configuration propagation. Control timers, randomness, and persisted defaults in tests.
- Build and test the shared `Alias` scheme using the commands in `AGENTS.md`.
- Report architectural tradeoffs and any deliberate deviation from the reference.
