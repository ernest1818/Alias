# Implementation gaps

This register prevents known empirical behavior from being mistaken for the
accepted product contract in `openspec/specs/`.

Status values are `Open`, `Planned`, and `Resolved`. Resolve an entry only after
an approved OpenSpec change is implemented, verified, merged into current specs
and archived.

## Product gaps

| ID | Status | Capability | Observed mismatch |
| --- | --- | --- | --- |
| GAP-001 | Open | `word-categories` | The “Для всей семьи” and “Все возможные уровни” selections return an empty word pool, so a round can start without a word card. |
| GAP-002 | Resolved | `gameplay` | Timer expiration now transitions immediately and idempotently to the round result. Resolved by [`add-continue-game`](../openspec/changes/archive/2026-08-23-add-continue-game/). |
| GAP-003 | Open | `preferences` | The “Звук в игре” preference is persisted and passed to the game, but swipe feedback always plays a system sound and haptic; button actions do not use the preference either. |
| GAP-004 | Open | `gameplay` | The “Общее последнее слово” preference is persisted and passed forward but has no gameplay behavior. |
| GAP-005 | Resolved | `app-navigation` | Continue and Rules now use distinct typed routes, and Continue restores the active snapshot. Resolved by [`add-continue-game`](../openspec/changes/archive/2026-08-23-add-continue-game/). |
| GAP-006 | Open | `new-game-setup` | Adding a team can select a name already in use; the team list renders by name even though teams have UUID identities. |
| GAP-010 | Open | `word-categories` | When every word in a selected pool is guessed or skipped before the target score is reached, the game has no replenishment policy and stops producing an active card. |

## Engineering gaps

| ID | Status | Area | Observed mismatch |
| --- | --- | --- | --- |
| GAP-007 | Open | Tests | Unit and UI test targets contain only generated example tests; baseline requirements have no automated acceptance coverage. |
| GAP-008 | Open | Navigation | Router dependencies are injected in some places and read from the shared singleton in others. |
| GAP-009 | Resolved | Identity | `WordsCategory` now has stable raw-value identity suitable for SwiftUI and snapshot coding. Resolved by [`add-continue-game`](../openspec/changes/archive/2026-08-23-add-continue-game/). |

## Resolution workflow

1. Select one coherent gap or related group of gaps.
2. Confirm intended behavior with the product owner.
3. Create an OpenSpec change referencing the affected gap IDs.
4. Add or modify requirements and scenarios before implementation.
5. Implement and verify the change.
6. Mark the gap `Resolved` and link the archived change directory.
