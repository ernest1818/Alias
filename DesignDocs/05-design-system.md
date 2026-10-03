# Этап 5. Компоненты дизайн-системы

Статус: **завершён**.

## Результат

Принятые решения Card Impact собраны в компонентную библиотеку с конкретными variants, states, responsive-правилами, accessibility-поведением и SwiftUI naming.

Полная спецификация: [12-component-library.md](12-component-library.md).

Визуальные борды:

- [Actions & Setup](VisualReferences/17-card-impact-actions-setup.png)
- [Game & Feedback](VisualReferences/18-card-impact-game-feedback.png)

## Архитектура библиотеки

```text
Foundations
    ↓
Primitives
    ↓
Controls
    ↓
Product compositions
```

Главное правило: общий внешний мотив не превращает разные продуктовые действия в один универсальный компонент. Поэтому:

- `StepNavigationControl` отвечает только за Back/Forward;
- `RoundOutcomeControls` отвечает только за Skip/Correct;
- `UtilityIconButton` отвечает за одиночные pause/close/info actions;
- `SignatureWordCard` остаётся отдельным игровым объектом;
- Round Result и Victory используют разные hero compositions.

## Принятый инвентарь

### Actions

- `ImpactButton`
- `StepNavigationControl`
- `RoundOutcomeControls`
- `UtilityIconButton`

### Setup

- `SetupHeader`
- `ValueStepperCard`
- `SettingRow`
- `FrequencyPicker`
- `ChallengeSelectionRow`
- `CategoryCard`
- `TeamCard`

### Game

- `SignatureWordCard`
- `TimerSignalField`
- `TeamBadge`
- `ScoreboardRow`
- `ChallengeCard`
- `RoundResultHero`
- `VictoryHero`

### Feedback

- `InlineValidationMessage`
- `StatusPanel`
- `PauseOverlay`
- system `confirmationDialog` / `alert` where a custom surface adds no product value

## Состояния

Для каждого применимого компонента определены:

- default;
- pressed;
- selected;
- disabled;
- loading;
- success;
- warning;
- error;
- destructive;
- accessibility focus.

Не каждое состояние добавляется каждому компоненту. Невозможные комбинации явно исключены в state matrix, чтобы API не превратился в набор конфликтующих boolean-флагов.

## Уточнение палитры

Chartreuse, vermilion и amber остаются semantic colors. Для двух hero value cards на Game Pulse допускается узкое expressive-исключение: `targetScore` и `roundDuration` могут использовать chartreuse/vermilion как плакатные поля только внутри этой фиксированной пары. Это не публичный произвольный accent и не статус компонента.

## Реализуемость

Система реализуема стандартными SwiftUI API:

- custom `Shape` для одного скошенного угла;
- `ButtonStyle` для физики нажатия;
- native `Toggle` с brand tint;
- layout containers и adaptive stacks;
- `DragGesture` для word card;
- `KeyframeAnimator`, `PhaseAnimator` и локальные transitions;
- semantic enums вместо произвольных styling flags.

Metal, SceneKit, сторонний gesture engine и внешняя UI-библиотека не требуются.

## Критерии готовности

- восемь ключевых экранов собираются из библиотеки без локальных визуальных форков;
- Back/Forward и Skip/Correct имеют разные продуктовые компоненты;
- disabled, selected, loading, warning, error и destructive различимы;
- смысл не передаётся только цветом;
- длинный русский текст и Dynamic Type не теряют смысл;
- touch target каждого действия не меньше 44 pt;
- responsive-поведение определено для compact, standard, large и accessibility layouts;
- SwiftUI naming и границы владения state зафиксированы;
- известные проблемы реализации не маскируются визуальными defensive states.

Этап 5 завершён. Следующий этап — спроектировать оставшиеся продуктовые сценарии и edge cases на базе этой библиотеки.
