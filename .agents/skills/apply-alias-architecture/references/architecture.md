# Alias Architecture Reference

This is a snapshot of the current design. Re-check the source before relying on details.

## Baseline

Alias is an iOS 17.5 SwiftUI application organized by feature and using a lightweight MVVM style. It has no separate domain, repository, dependency-container, or networking layer.

| Concern | Location | Current decision |
| --- | --- | --- |
| Composition | `AliasApp.swift` | Create feature view models and map typed routes to screens. |
| Navigation | `Navigation/Router.swift` | Store `[Route]` in a shared `ObservableObject`; expose mutations through `RouterProtocol`. |
| Features | `*Module/` | Pair SwiftUI views with `ObservableObject` view models. |
| Shared UI | `Components/` | Provide reusable buttons and modifiers. |
| Setup data | `GameConfigModel.swift`, `SettingsModule/` | Pass teams, settings, and category forward as Hashable value models. |
| Game domain | `GameModule/` | Keep phase, score, round, word, and timer behavior in models and view models. |
| Persistence | `SettingsViewModel.swift` | Encode a nested Codable settings value into `UserDefaults`. |
| Static data | `GameData/` | Supply bundled team names and category words. |

## Navigation and configuration flow

`AliasApp` owns `NavigationStack(path:)`. A feature calls `RouterProtocol.add(route:)`; `Route` carries the value needed by the destination. New-game data flows as follows:

```text
MakeCommandViewModel -> [Team]
SettingsViewModel -> Configuration -> GameConfigModel
WordsListViewModel -> selected WordsCategory in GameConfigModel
GameViewModel -> gameplay state and results
```

Keep data flowing forward in route payloads. Use `back()` or `backToRoot()` for reverse navigation rather than letting views manipulate the navigation path directly.

## State ownership

- Use `@ObservedObject` for a view model received by a view initializer, matching existing screens.
- Use view-local `@State` only for ephemeral presentation details such as gesture offset or animation color.
- Keep business state in the view model. `GameViewModel` owns `GameState`, current team/word, scores, and results.
- Use explicit intent methods such as `startGame()`, `skipWord()`, and `showNext()` instead of mutating model state from views.
- Keep domain data as structs and enums. Add `Identifiable`, `Equatable`, and `Hashable` only where UI collections, comparison, or route payloads require them.

## Extension decisions

For a new screen, create `<Feature>Module/<Feature>View.swift` and `<Feature>ViewModel.swift`, add a `Route` case, then compose the destination in `AliasApp`. Extract a component only after it is reused or has independent interaction logic.

For new game rules, add state to game models and transitions to `GameViewModel`; do not place scoring or phase changes in `GameView`. Keep timer behavior in `TimerViewModel` and expose events/state to the game coordinator view model.

For new persistence, retain `UserDefaults` for small preferences. Introduce a protocol-backed store when tests need isolation, data grows beyond settings, or migration/error handling becomes necessary.

## Known limitations

Do not mistake every current implementation detail for a target pattern:

- Router injection is inconsistent: `EntranceViewModel` uses `RouterProtocol`, while other view models access `Router.shared` directly. Prefer initializer injection for new or touched code.
- Random team names, shuffled words, `Timer`, and `UserDefaults.standard` reduce deterministic testability. Add narrow protocol or closure seams when testing affected behavior.
- `WordsCategory.id` creates a new UUID on every access. Prefer stable identity when modifying category models.
- Models and configuration types are colocated with some feature files. Move them only when ownership becomes ambiguous; avoid a repository-wide reorganization for a small feature.
