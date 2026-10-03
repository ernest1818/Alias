# SwiftUI Token Map

Это принятое соответствие дизайн-токенов и semantic component names будущим SwiftUI API. Оно не требует немедленного изменения текущего кода.

## Colors

| Design token | Suggested Swift name |
| --- | --- |
| `backgroundPrimary` | `CardImpactColor.backgroundPrimary` |
| `backgroundElevated` | `CardImpactColor.backgroundElevated` |
| `surfacePrimary` | `CardImpactColor.surfacePrimary` |
| `surfaceMuted` | `CardImpactColor.surfaceMuted` |
| `textOnDark` | `CardImpactColor.textOnDark` |
| `textOnLight` | `CardImpactColor.textOnLight` |
| `actionPrimary` | `CardImpactColor.actionPrimary` |
| `feedbackSuccess` | `CardImpactColor.success` |
| `feedbackDanger` | `CardImpactColor.danger` |
| `feedbackWarning` | `CardImpactColor.warning` |

Raw palette values остаются внутренними. Публичные controls получают semantic role, а не произвольный `Color`. Исключение — team identity и закрытые `ValueStepperKind.targetScore / .roundDuration`.

## Typography

| Design style | Suggested Swift name |
| --- | --- |
| `scoreHero` | `CardImpactTypography.scoreHero` |
| `displayHero` | `CardImpactTypography.displayHero` |
| `gameWord` | `CardImpactTypography.gameWord` |
| `gameTimer` | `CardImpactTypography.gameTimer` |
| `screenTitle` | `CardImpactTypography.screenTitle` |
| `sectionTitle` | `CardImpactTypography.sectionTitle` |
| `actionLabel` | `CardImpactTypography.actionLabel` |
| `body` | `CardImpactTypography.body` |
| `caption` | `CardImpactTypography.caption` |

Implementation notes:

- `gameTimer` uses `.monospacedDigit()` and condensed system width.
- Interface styles use relative text styles or `UIFontMetrics` equivalent.
- Custom display font is bundled with the app and registered once.
- Font fallback must preserve Cyrillic and comparable width.

## Layout

| Design token | Suggested Swift name |
| --- | --- |
| `space1...space8` | `CardImpactSpacing` |
| `radiusSmall...radiusCard` | `CardImpactRadius` |
| Screen insets | `CardImpactLayout.screenInset(for:)` |
| Maximum content width | `CardImpactLayout.maximumContentWidth` |

Дополнительные implementation tokens:

| Design token | Suggested Swift name |
| --- | --- |
| Border 1 / 2 / 3 pt | `CardImpactBorder.subtle / strong / focus` |
| Shadow 3 / 5 / 8 / 12 pt | `CardImpactShadow.small / action / card / hero` |
| Disabled content opacity 38% | `CardImpactOpacity.disabledContent` |
| Pause scrim 88% | `CardImpactOpacity.pauseScrim` |
| Minimum touch target 44 pt | `CardImpactLayout.minimumTouchTarget` |
| Setup control target 48 pt | `CardImpactLayout.setupTouchTarget` |

## Shapes and primitives

Предполагаемые примитивы:

- `CutCornerRectangle` — rounded rectangle с одним срезанным углом.
- `FlatShadowSurface` — face + offset layer без blur; не содержит semantics.
- `CardStack` — максимум две подложки.
- `ImpactMark` — burst, speed и snap.

Не вводить один публичный `ImpactCircleButtonStyle` для всех круглых действий. Навигация, round outcomes и utility icons имеют разные semantic contracts.

## Components

### Actions

- `ImpactButton` + `ImpactButtonRole.primary / .secondary / .destructive`.
- `StepNavigationControl` — асимметричная пара Back/Forward.
- `RoundOutcomeControls` — равная пара Skip/Correct.
- `UtilityIconButton` — pause/close/info, но не navigation/outcome.

### Setup

- `SetupHeader`.
- `ValueStepperCard` + `ValueStepperKind.targetScore / .roundDuration`.
- `SettingRow` с native `Toggle`.
- `FrequencyPicker`.
- `ChallengeSelectionRow`.
- `CategoryCard`.
- `TeamCard`.
- `AddTeamSlot`.

### Game and feedback

- `SignatureWordCard` + `WordCardVisualState`.
- `TimerSignalField` + `TimerSignalState`.
- `TeamBadge`.
- `SavedGameCard` + `SavedGameAvailability`.
- `TeamTurnHero`.
- `CompactScoreboardStrip`.
- `RoundStartControl`.
- `ScoreboardRow` + `ScoreboardRowStyle`.
- `ChallengeCard`.
- `RoundResultHero`.
- `ScoreBreakdown`.
- `WordOutcomeList`.
- `RoundAdvanceControl`.
- `VictoryHero`.
- `InlineValidationMessage`.
- `StatusPanel` + `StatusPanelState`.
- `PauseOverlay`.

Полный visual/state contract: [../12-component-library.md](../12-component-library.md).

## Motion

- `CardImpactMotion.Duration` — instant, press, micro, feedback, transition, cardExit, cardEnter, result и victory.
- `CardImpactMotion.Animation` — impactOut, exit, standard, returnSpring, enterSpring и impactSpring.
- `CardImpactMotion.preset(reduceMotion:)` — выбирает default или reduced choreography без изменения game timing.
- `CardResolutionTransition` — presentation-only outgoing snapshot и появление следующей карточки.
- `ResumeCountdownAnimator` — последовательность `3`, `2`, `1`, `НАЧАЛИ!`; не владеет игровым timer.

## State ownership

- Card drag offset, rotation и временный impact mark являются presentation state и могут жить во View.
- Подтверждение correct/skip, изменение счёта и переход раунда остаются intent-методами ViewModel.
- Semantic state передаётся в компонент явно; компонент не угадывает success или danger по цвету.
- Доступность `Back` и `Forward`, loading и disabled передаются в `StepNavigationControl` явно; компонент не принимает решение о валидности шага.
- Reduce Motion меняет animation strategy, но не игровые переходы состояния.
- `isPressed` принадлежит `ButtonStyle` или локальному gesture state, а не feature ViewModel.
- Public components принимают semantic enums; флаги вида `isRed`, `isBig`, `hasShadow` запрещены.
- `SignatureWordCard`, `TimerSignalField`, `ScoreboardRow` и status components получают готовый presentation state и не вычисляют domain state самостоятельно.

## Стоимость

| Элемент | Оценка |
| --- | --- |
| Semantic colors и typography | Низкая |
| Custom clipped-corner Shape | Низкая |
| Flat shadows и offset layers | Низкая |
| Drag rotation и reveal | Средняя |
| Impact marks | Низкая |
| Полный motion choreography | Средняя |

Текущая foundations-система не требует Metal shaders, SceneKit, сторонних UI-библиотек или сложной графической инфраструктуры.
