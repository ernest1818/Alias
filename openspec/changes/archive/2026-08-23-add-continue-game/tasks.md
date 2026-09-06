## 1. Persistable game state and deterministic time

- [x] 1.1 Add versioned Codable snapshot value types for configuration, teams,
  scores, round results, ordered word cards, current challenge, phase and remaining
  time; add restoring initializers that preserve stored UUID values.
- [x] 1.2 Give `WordsCategory` a stable raw-value identity suitable for snapshot
  encoding, while preserving its current cases, titles and colors.
- [x] 1.3 Introduce an injectable clock/ticker seam and extend timer behavior to
  start from restored time, publish one tick per second and emit one idempotent
  expiration event at zero.
- [x] 1.4 Add XCTest coverage for snapshot encode/decode round trips, stable
  identities, restored timer values and single expiration delivery.

## 2. SwiftData active-game store

- [x] 2.1 Add schema-version-1 `SavedGameRecord` with one stable active-slot key,
  timestamp and encoded snapshot payload, and register it in the app's
  `ModelContainer`.
- [x] 2.2 Define `GameSessionStore` and implement SwiftData load, explicit-save
  upsert and delete operations, including unsupported-version and corrupt-payload
  handling without a crash.
- [x] 2.3 Compose the persistent store at `AliasApp` and inject it into affected
  view models without adding a global service container.
- [x] 2.4 Add in-memory SwiftData integration tests proving one-slot replacement,
  durable round-trip loading, deletion and invalid-record isolation.

## 3. Game checkpoint and restoration flow

- [x] 3.1 Extend `GameViewModel` with new-game and restored-snapshot initializers;
  rebuild derived data and map persisted playing/paused phases to a paused runtime
  state without starting the timer.
- [x] 3.2 Save a full checkpoint after initial game creation, word resolution,
  phase transitions, pause, next-round preparation and every active timer tick;
  delete the slot only after the final game result is fixed.
- [x] 3.3 Replace delayed zero handling with an immediate, idempotent round-end
  transition and checkpoint when the timer expires, resolving `GAP-002`.
- [x] 3.4 Add the resume-countdown phase and deterministic `3`, `2`, `1`,
  `Начали!` progression; keep the game timer stopped until completion and reject
  repeated resume requests.
- [x] 3.5 Render the animated countdown in `GameView` and forward inactive/background
  scene transitions to the view model so playing or countdown is paused and
  checkpointed before suspension.
- [x] 3.6 Add deterministic GameViewModel tests for exact restoration in preparing,
  playing/paused and round-end phases; checkpoint triggers; countdown interruption;
  automatic expiration; and save deletion at game end.

## 4. Main menu and typed navigation

- [x] 4.1 Separate typed routes for a restored game and Rules, carrying only a
  value snapshot through navigation and keeping SwiftData models out of the path.
- [x] 4.2 Inject router and store into `EntranceViewModel`; refresh save availability
  on menu appearance and disable `Continue Game` when loading a valid snapshot is
  impossible.
- [x] 4.3 Implement New Game replacement confirmation so cancel preserves the slot
  and confirm deletes it before opening team setup; keep Rules independent from
  persistence.
- [x] 4.4 Route the game toolbar's «Меню» action through a view-model intent that
  pauses, checkpoints and then returns to root via injected `RouterProtocol`.
- [x] 4.5 Add unit/UI coverage for enabled and disabled Continue states, successful
  restored navigation, both replacement-confirmation outcomes, distinct Rules
  navigation and saved return-to-menu behavior.

## 5. Verification and completion

- [x] 5.2 Run `openspec validate --all --strict --no-interactive` and resolve every
  proposal or delta-spec validation error.
- [x] 5.3 Run the shared Alias Xcode build for a generic iOS Simulator destination
  and record any exact full-Xcode environment blocker.
  - Verified with Xcode 26.3 through `mcpbridge`: the active `Alias` scheme built
    successfully for `iphonesimulator` (arm64) with no compiler errors.
- [x] 5.4 Run the relevant unit/UI tests on an installed simulator and verify that
  timer, persistence, navigation and restoration tests are deterministic.
  - Verified 17 deterministic unit tests on the booted iPhone 17 Pro simulator:
    all passed with `TEST SUCCEEDED`. The separate XCTest UI rerun was omitted at
    the user's request; the earlier combined run had already reported its three
    UI checks as passed before Xcode's result-finalization process stalled.
- [x] 5.5 After successful verification, update `docs/IMPLEMENTATION_GAPS.md` for
  `GAP-002`, `GAP-005` and `GAP-009`, then sync the accepted deltas into current
  specs and archive `add-continue-game` through the OpenSpec archive workflow.
  - Updated all three gap entries and synced `app-navigation`, `gameplay` and the
    new `saved-game` capability into the current specs; strict validation passes.
