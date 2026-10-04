# Architecture

## Baseline

Alias is an iOS 17.5 SwiftUI application using lightweight, feature-oriented
MVVM. The project currently has no networking, domain-service, repository,
dependency-container, or third-party architecture layer.

This document preserves the current baseline. It does not propose a repository
reorganization or new framework.

## Component map

| Concern | Location | Current responsibility |
| --- | --- | --- |
| Composition | `Alias/Alias/AliasApp.swift` | Own the navigation stack and map routes to screens. |
| Navigation | `Alias/Alias/Navigation/` | Store typed routes and expose navigation operations. |
| Start menu | `Alias/Alias/StartModule/` | Present entry points into the application. |
| Team setup | `Alias/Alias/MakeCommandModule/` | Create the participating teams and pass them forward. |
| Game settings | `Alias/Alias/SettingsModule/` | Edit, validate and persist game preferences. |
| Category selection | `Alias/Alias/WordsListModule/` | Select the word category for a configured game. |
| Game flow | `Alias/Alias/GameModule/` | Own phases, timer coordination, words, rounds and scores. |
| Shared UI | `Alias/Alias/Components/` | Reusable buttons and visual modifiers. |
| Static content | `Alias/Alias/GameData/` | Bundled team names and category word lists. |
| Resources | `Alias/Alias/Resourses/` | Fonts, colors and application assets. |

## Navigation and data flow

`AliasApp` owns `NavigationStack(path:)`. `Route` carries the value required by
each destination. Features request navigation through `RouterProtocol`.

The implemented new-game flow is:

```text
Entrance
  → [Team]
  → Configuration
  → GameConfigModel + WordsCategory
  → GameViewModel
```

New data should continue to flow in route payloads. Reverse navigation should
use router operations rather than direct path mutation from views.

## State ownership

- Views render observable state, expose bindings and forward user intent.
- Feature view models own validation, orchestration and transitions.
- `GameViewModel` coordinates `GameState`, current team, current word, round
  results, scores and round challenges.
- `TimerViewModel` owns countdown state and timer lifecycle.
- View-local `@State` is reserved for ephemeral presentation state such as
  animations, gesture offsets and disclosure visibility.
- Domain data remains in structs and enums. `Hashable` is required for route
  payloads used by `NavigationStack`.

## Persistence

Game preferences are stored as one Codable value in `UserDefaults`. Saved game
progress uses a protocol-backed one-slot SwiftData store so Stage Door can
distinguish an absent save, a resumable snapshot, invalid data, and a storage
failure. Keep migration and validation at that persistence boundary as the
snapshot schema evolves.

## Extension rules

- New screens belong in `<Feature>Module/` with a paired view model.
- New destinations require a typed `Route` case and central composition in
  `AliasApp`.
- New game rules belong in game models and explicit `GameViewModel` transition
  methods, not in `GameView`.
- Timer policy stays behind `TimerViewModel`; expose events to the game
  coordinator rather than letting views decide when rounds end.
- Extract shared UI only after reuse or independent interaction logic is clear.
- Add narrow protocols or closures around routing, timers, randomness and
  persistence when touching those areas so tests can be deterministic.

## Documented limitations

- Router injection is inconsistent; several view models access `Router.shared`
  directly. Prefer initializer injection in touched code.
- Random team names, shuffled words, a Foundation timer and
  `UserDefaults.standard` limit deterministic testing.
- `WordsCategory` produces a new UUID each time its identity is read.
- Some models are colocated with feature files. Move them only when ownership
  becomes ambiguous; do not reorganize the whole repository for a local change.
- Automated tests are still generated templates and do not verify product
  behavior.

Observable product limitations and spec/code mismatches are tracked separately
in `docs/IMPLEMENTATION_GAPS.md`.
