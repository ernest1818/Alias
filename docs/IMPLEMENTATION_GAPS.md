# Implementation gaps

This register keeps known implementation mismatches separate from accepted
product and design decisions in `DesignDocs/`.

Status values are `Open`, `Planned`, and `Resolved`. Resolve an entry only after
the intended behavior is implemented and verified.

## Product gaps

| ID | Status | Capability | Observed mismatch |
| --- | --- | --- | --- |
| GAP-001 | Open | `word-categories` | The “Для всей семьи” and “Все возможные уровни” selections return an empty word pool, so a round can start without a word card. |
| GAP-002 | Resolved | `gameplay` | Timer expiration now transitions immediately and idempotently to the round result. |
| GAP-003 | Open | `preferences` | The “Звук в игре” preference is persisted and passed to the game, but swipe feedback always plays a system sound and haptic; button actions do not use the preference either. |
| GAP-004 | Open | `gameplay` | The “Общее последнее слово” preference is persisted and passed forward but has no gameplay behavior. |
| GAP-005 | Resolved | `app-navigation` | Stage Door now distinguishes no save, available, invalid, and load-failure states; Continue restores the active snapshot through a typed route, while Rules use an isolated native sheet. |
| GAP-006 | Open | `new-game-setup` | Adding a team can select a name already in use; the team list renders by name even though teams have UUID identities. |
| GAP-010 | Open | `word-categories` | When every word in a selected pool is guessed or skipped before the target score is reached, the game has no replenishment policy and stops producing an active card. |

## Engineering gaps

| ID | Status | Area | Observed mismatch |
| --- | --- | --- | --- |
| GAP-007 | Resolved | Tests | Deterministic unit coverage now exercises configuration, game transitions, persistence, and Stage Door states; the unused UI-test target is excluded from the shared scheme. |
| GAP-008 | Open | Navigation | Router dependencies are injected in some places and read from the shared singleton in others. |
| GAP-009 | Resolved | Identity | `WordsCategory` now has stable raw-value identity suitable for SwiftUI and snapshot coding. |

## Resolution workflow

1. Select one coherent gap or related group of gaps.
2. Confirm intended behavior with the product owner.
3. Record the accepted decision in the relevant `DesignDocs/` file when needed.
4. Implement the change and deterministic tests.
5. Verify build and relevant tests.
6. Mark the gap `Resolved` and note the delivered behavior.
