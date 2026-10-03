# Этап 6. Полный продуктовый сценарий

Статус: **завершён**.

## Результат

Все основные и системные сценарии Alias сведены в одну experience architecture. Storyboard thumbnails превращены в спецификации полноценных экранов, переходов и edge cases.

Подробные документы:

- [Entry & Setup v1](13-entry-and-setup-spec.md)
- [Match & Results v1](14-match-and-results-spec.md)
- [System Flows & Edge Cases v1](15-system-flows-and-edge-cases.md)

Визуальные борды:

- [Setup Flow](VisualReferences/19-card-impact-setup-flow-v2.png)
- [Match Flow](VisualReferences/20-card-impact-match-flow.png)
- [System Flows](VisualReferences/21-card-impact-system-flows-v2.png)

## Финальная архитектура опыта

```text
STAGE DOOR
├── Rules sheet
├── Continue
│   ├── saved preparation ─────────────▶ ROUND CALL
│   ├── saved active / paused ─────────▶ PAUSE
│   └── saved round result ────────────▶ ROUND HIT
└── New Game
    └── LINE-UP ⇄ GAME PULSE ⇄ WORD DECK
                                     │ confirm + first save
                                     ▼
                                 ROUND CALL
                                     │ Play
                                     ▼
                                  LIVE CARD
                                  │       │
                              Pause       Timer 0
                                  │       ├── no winner ─▶ ROUND HIT ─▶ ROUND CALL
                                  │       └── winner ────▶ VICTORY SLAM
                                  └── Menu: save ────────▶ STAGE DOOR
```

Сохраняются восемь основных экранов:

1. Stage Door.
2. Line-up.
3. Game Pulse.
4. Word Deck.
5. Round Call.
6. Live Card.
7. Round Hit.
8. Victory Slam.

Rules, replacement confirmation, Pause и Resume являются overlays/states, а не отдельными пунктами основной навигации.

## Ключевые решения этапа

### Stage Door

- primary action зависит от наличия корректного save;
- Continue всегда остаётся видимой;
- invalid save не превращает Home в тревожный error screen;
- Rules полностью изолирован от save navigation.

### Line-up

- названия автоматически генерируются;
- ручное редактирование имён не входит в v1;
- минимум две, максимум пять команд;
- duplicate name считается нарушением генератора, а не пользовательской ошибкой.

### Word Deck

- category tap выбирает карточку;
- отдельный Forward подтверждает выбор и создаёт первое active save;
- unavailable category видима, но disabled;
- empty pool не может открыть Round Call.

### Round Call

- iPhone передаётся до старта таймера;
- team → challenge → score → Play;
- отсутствие challenge обозначается нейтрально;
- `RoundStartControl` отделён от setup navigation.

### Round Hit

- показывает итог, breakdown, resolved words, scoreboard и следующую команду;
- valid zero score не получает error treatment;
- restored result не проигрывает score mutation заново.

### Victory Slam

- победа открывается напрямую после winning round;
- интерактивный Round Hit перед ней не нужен;
- `НОВАЯ ИГРА` ведёт в новый Line-up;
- `СЫГРАТЬ ЕЩЁ РАЗ` не используется без отдельного reuse contract.

### System flows

- replacement save: native destructive confirmation;
- Rules: native informational sheet;
- active restore: всегда Pause;
- Menu: сначала save, затем закрытие route;
- routine success feedback остаётся компактным;
- blocking Card Impact error используется только когда безопасное продолжение невозможно.

## Новые component compositions

Stage 6 добавляет:

- `SavedGameCard`;
- `AddTeamSlot`;
- `TeamTurnHero`;
- `CompactScoreboardStrip`;
- `RoundStartControl`;
- `ScoreBreakdown`;
- `WordOutcomeList`;
- `RoundAdvanceControl`.

Они дополняют Component Library v1 без создания универсальной screen-card.

## Поведенческие изменения перед реализацией

Дизайн осознанно предлагает два улучшения текущего product contract:

1. Setup становится обратимым: Back сохраняет draft между шагами.
2. Category selection требует отдельного подтверждения Forward вместо мгновенного старта по первому тапу.

Оба изменения считаются принятыми продуктовыми решениями и должны быть реализованы напрямую. Существующая навигация не используется как ограничение.

Также остаются продуктовые gaps:

- пустые категории;
- sound routing;
- поведение общего последнего слова;
- генерация уникальных названий команд;
- исчерпание запаса слов.

## Критерии готовности

- все обязательные возможности имеют экран, overlay или защитное состояние;
- каждый экран имеет одно главное действие;
- Continue восстанавливает точную сохранённую фазу;
- setup не теряет draft при Back;
- destructive replacement подтверждается;
- безопасный выход сохраняет игру до навигации;
- timer никогда не запускается до Play или автоматически после restore;
- результат объясняет scoring, включая penalty и floor zero;
- победа завершает save lifecycle;
- нет тупика без безопасного действия;
- visual system остаётся спокойнее в setup и интенсивнее в active/result phases;
- все сценарии собираются из Component Library v1 и документированных additions.

Этап 6 завершён. Техническая передача дизайна выполнена в [SwiftUI Handoff v1](07-swiftui-handoff.md).
