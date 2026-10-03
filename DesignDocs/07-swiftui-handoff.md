# Этап 7. SwiftUI Handoff v1

Статус: **завершён — production-ready handoff зафиксирован**.

Этот документ переводит Card Impact из дизайн-спецификации в план реализации на SwiftUI. Он не меняет принятый продуктовый сценарий и не использует существующий Party Pop UI как визуальный референс.

Источники решений:

- foundations: `Foundations/`;
- experience architecture: [09-experience-architecture.md](09-experience-architecture.md);
- active round: [10-live-card-spec.md](10-live-card-spec.md);
- motion: [11-motion-spec.md](11-motion-spec.md);
- components: [12-component-library.md](12-component-library.md);
- entry/setup: [13-entry-and-setup-spec.md](13-entry-and-setup-spec.md);
- match/results: [14-match-and-results-spec.md](14-match-and-results-spec.md);
- system flows: [15-system-flows-and-edge-cases.md](15-system-flows-and-edge-cases.md).

Если visual reference board и числовой контракт расходятся, приоритет у Markdown-спецификации.

---

## 1. Архитектурное решение

### Что сохраняется

Реализация остаётся на текущей lightweight feature-oriented MVVM-базе:

- SwiftUI View отвечает за layout, accessibility и transient presentation state;
- `ObservableObject` ViewModel отвечает за validation, orchestration и переходы;
- `Route` остаётся типизированным;
- `AliasApp` остаётся composition root;
- game rules и phase state остаются в `GameModule`;
- небольшие локальные данные сохраняются через существующие protocol-backed stores;
- сторонний UI framework, coordinator, service container и отдельный repository layer не вводятся.

### Два намеренных улучшения

#### 1. Единый `SetupFlow`

`Line-up`, `Game Pulse` и `Word Deck` реализуются как три шага одного feature container с одним `SetupFlowViewModel` и одним `SetupDraft`.

Причина: принятый UX требует Back без потери данных. Три независимых route payload и три независимо создаваемых ViewModel делают сохранение draft хрупким и дублируют orchestration.

Это не coordinator. `SetupFlowViewModel` является обычным feature ViewModel и владеет только new-game draft.

#### 2. Явное владение lifecycle

Route-entry views владеют ViewModel через `@StateObject`. Вложенные экраны получают его или готовые display models через `@ObservedObject`/value inputs.

Это устраняет риск пересоздания ViewModel при повторном вычислении `navigationDestination` и сохраняет текущий принцип dependency injection.

### Что не переносится из старого UI

- `PartyPopDesignSystem` и его цвета;
- gradient/mesh background;
- pill buttons;
- blur shadows;
- текущие карточки и toolbar-композиция;
- текущий route-per-setup-step как целевая UX-модель;
- current `WordCardView` как визуальная основа.

Старые элементы могут временно существовать рядом во время миграции, но один экран не смешивает Party Pop и Card Impact.

---

## 2. Целевая карта модулей

```text
Alias/
├── AliasApp.swift
├── Navigation/
│   └── Router.swift
├── Components/
│   └── CardImpact/
│       ├── Foundations/
│       │   ├── CardImpactColor.swift
│       │   ├── CardImpactTypography.swift
│       │   ├── CardImpactMetrics.swift
│       │   └── CardImpactMotion.swift
│       ├── Primitives/
│       │   ├── CutCornerRectangle.swift
│       │   ├── FlatShadowSurface.swift
│       │   ├── CardStack.swift
│       │   └── ImpactMark.swift
│       ├── Actions/
│       ├── Setup/
│       ├── Game/
│       └── Feedback/
├── StartModule/
│   ├── StageDoorScene.swift
│   ├── StageDoorView.swift
│   ├── StageDoorViewModel.swift
│   └── RulesSheet.swift
├── SetupModule/
│   ├── SetupFlowScene.swift
│   ├── SetupFlowView.swift
│   ├── SetupFlowViewModel.swift
│   ├── SetupDraft.swift
│   ├── LineUpView.swift
│   ├── GamePulseView.swift
│   └── WordDeckView.swift
├── GameModule/
│   ├── GameScene.swift
│   ├── GameView.swift
│   ├── GameViewModel.swift
│   ├── GameModels.swift
│   ├── RoundCallView.swift
│   ├── LiveCardView.swift
│   ├── RoundHitView.swift
│   ├── VictorySlamView.swift
│   ├── PauseOverlay.swift
│   └── ResumeCountdownView.swift
├── GameData/
└── Resourses/
    ├── Assets.xcassets
    ├── Fonts/
    └── Sounds/
```

`MakeCommandModule`, `SettingsModule` и `WordsListModule` удаляются только после того, как `SetupModule` полностью заменит их поведение. Массовое перемещение моделей до этого не требуется.

### Соответствие экранов

| Design screen | Target SwiftUI type | State owner |
| --- | --- | --- |
| Stage Door | `StageDoorView` | `StageDoorViewModel` |
| Line-up | `LineUpView` | `SetupFlowViewModel` |
| Game Pulse | `GamePulseView` | `SetupFlowViewModel` |
| Word Deck | `WordDeckView` | `SetupFlowViewModel` |
| Round Call | `RoundCallView` | `GameViewModel` |
| Live Card | `LiveCardView` | `GameViewModel` + local gesture state |
| Round Hit | `RoundHitView` | `GameViewModel` |
| Victory Slam | `VictorySlamView` | `GameViewModel` |
| Rules | `RulesSheet` | local presentation state |
| Pause | `PauseOverlay` | `GameViewModel` |
| Resume | `ResumeCountdownView` | `GameViewModel` + local keyframes |

### Audit текущего кода

| Current implementation | Что сохраняется | Что заменяется |
| --- | --- | --- |
| `AliasApp` + `NavigationStack` | composition root и typed destinations | destination construction переносится в lifecycle-safe Scene wrappers |
| `EntranceViewModel` | injected router/store и replacement flow | boolean `hasSavedGame` заменяется полноценным availability state |
| `EntranceView` | entry responsibility | вся Party Pop композиция заменяется Stage Door |
| `MakeCommandViewModel` | team add/remove intent | random generator исправляется, state переезжает в `SetupDraft` |
| `SettingsViewModel` | ranges, challenge validation, preference persistence | отдельный route/view model заменяется шагом `SetupFlow` |
| `WordsListViewModel` | stable `WordsCategory` identity | tap-to-start заменяется select + explicit Forward |
| `GameViewModel` | единая phase state machine, score, snapshot и restore | добавляются display adapters, idempotent outcome и точные feedback events |
| `TimerViewModel` | countdown ownership и expiration idempotency | ticker interface расширяется для тестируемого cadence |
| `SwiftDataGameSessionStore` | one-slot persistence | inspection начинает различать none/invalid/failure |
| `WordCardView` | локальный drag как presentation state | visual/gesture contract полностью заменяется Card Impact |
| `PartyPopDesignSystem` | ничего визуального | временно остаётся только для ещё не мигрированных экранов |

Deployment target iOS 17.5 сохраняется. `KeyframeAnimator`, `PhaseAnimator`, `sensoryFeedback`, `safeAreaInset` и native sheet/dialog доступны без compatibility layer.

---

## 3. Навигация и lifecycle

### Target routes

```swift
enum Route: Hashable {
    case setup
    case game(GameLaunchContext)
}

enum GameLaunchContext: Hashable {
    case new(GameConfigModel)
    case restore(GameSessionSnapshot)
}
```

Rules не является push-route. Он открывается native sheet из Stage Door или Pause. Replacement save остаётся native confirmation dialog.

### Scene ownership

```swift
struct SetupFlowScene: View {
    @StateObject private var viewModel: SetupFlowViewModel
}

struct GameScene: View {
    @StateObject private var viewModel: GameViewModel
}
```

`AliasApp` создаёт dependencies и передаёт их в scene initializer. Scene создаёт и удерживает ViewModel. Внутренние step/phase views не создают новые feature ViewModel.

### Setup transitions

```text
Stage Door
    └── Route.setup
          └── Line-up ⇄ Game Pulse ⇄ Word Deck
                                      └── confirm
                                            └── Route.game(.new(config))
```

- Back между шагами меняет `SetupStep`, а не router path.
- Back на Line-up закрывает setup и удаляет только in-memory draft.
- Отдельный confirmation для выхода из setup не нужен: активное сохранение ещё не создано, названия генерируются автоматически, а подтверждённые preferences уже находятся в store.
- Выбор категории не навигирует.
- Forward на Word Deck атомарно формирует `GameConfigModel`, создаёт первый active checkpoint через game initialization и только затем открывает Round Call.

### Match transitions

Текущий `GameView` остаётся единым phase container. Существующие state cases получают следующее визуальное соответствие:

| Current state | Product phase |
| --- | --- |
| `.preparing` | Round Call |
| `.playing` | Live Card |
| `.paused` | Live Card + Pause overlay |
| `.resumeCountdown` | Resume full-screen state |
| `.roundEnd` | Round Hit |
| `.gameEnd` | Victory Slam |

Переименование enum не является условием первой поставки. Важнее сохранить одну state machine и один источник score/timer/team state.

---

## 4. Setup state и data flow

### `SetupDraft`

```swift
struct SetupDraft: Equatable {
    var teams: [Team]
    var targetScore: Int
    var roundDuration: Int
    var isSkipPenaltyEnabled: Bool
    var isSharedLastWordEnabled: Bool
    var challengeFrequency: Challenge
    var selectedChallenges: Set<GameChallenge>
    var isSoundEnabled: Bool
    var selectedCategory: WordsCategory?
}
```

Defaults:

- 2 unique generated teams;
- target score 60;
- round duration 20 seconds;
- saved confirmed preferences override numeric/rule defaults;
- selected category starts `nil` for every new setup;
- draft exists only for the lifetime of `SetupFlowScene`.

### `SetupStep`

```swift
enum SetupStep: Int, CaseIterable {
    case lineUp
    case gamePulse
    case wordDeck
}
```

### `SetupFlowViewModel` responsibility

Owns:

- current step;
- full draft;
- team generation/removal;
- settings validation;
- category selection and availability;
- persistence of confirmed preferences;
- final `GameConfigModel` creation;
- transition loading/input lock.

Does not own:

- button press animation;
- scroll position;
- impact marks;
- game session state after configuration is accepted.

Required intents:

```swift
func addTeam()
func removeTeam(id: Team.ID)
func setTargetScore(_ value: Int)
func setRoundDuration(_ value: Int)
func setSkipPenaltyEnabled(_ value: Bool)
func setSharedLastWordEnabled(_ value: Bool)
func setSoundEnabled(_ value: Bool)
func setChallengeFrequency(_ value: Challenge)
func toggleChallenge(_ challenge: GameChallenge)
func selectAllChallenges()
func clearChallenges()
func selectCategory(_ category: WordsCategory)
func goBack()
func goForward()
```

`goForward()` на последнем шаге возвращает или публикует готовый `GameConfigModel`; `CategoryCard` не создаёт route и не читает word pool.

### Narrow dependencies

Для детерминированности достаточно трёх узких границ:

```swift
protocol GamePreferencesStore
protocol TeamNameGenerating
protocol WordCatalogProviding
```

- `GamePreferencesStore` кодирует существующую `Configuration`/preferences в `UserDefaults`.
- `TeamNameGenerating` гарантирует уникальное имя относительно уже выбранных имён.
- `WordCatalogProviding` сообщает доступность категорий и выдаёт слова game layer.

Отдельный repository/service-container не нужен.

---

## 5. Game state boundaries

### ViewModel owns

- current phase;
- current team and queue position;
- round/game numbers;
- current word;
- remaining time and timer lifecycle;
- challenge selection;
- outcome acceptance;
- round result snapshot;
- winner/final snapshot;
- persistence and restore;
- phase-level input locks;
- semantic feedback event.

### View owns

- drag offset and rotation;
- preview progress;
- whether Armed haptic already fired for the current drag;
- outgoing card snapshot used by the 380 ms transition;
- local impact mark;
- scroll position;
- sheet/dialog visibility where it has no domain consequence;
- keyframe presentation driven by ViewModel countdown step.

### Outcome API

Swipe и buttons обязаны идти в один intent:

```swift
enum WordOutcome: Hashable {
    case correct
    case skipped
}

func resolveWord(id: WordCard.ID, as outcome: WordOutcome)
```

Intent содержит `wordID`, чтобы повторное событие от уже ушедшей карточки было идемпотентно отклонено. View локально блокирует controls на время card transition, но score и persistence не ждут завершения motion.

### Timer race

`GameViewModel` выполняется на `MainActor` и является единственным арбитром race между outcome и timer zero:

- outcome принимается только для текущего unresolved word в `.playing`;
- после перехода в `.roundEnd` любое outcome отклоняется;
- timer-zero word не добавляется в `WordOutcomeList`;
- View не решает race по animation state.

### Resume timing

Current one-second ticker не подходит для точного `650 + 650 + 650 + 400 ms` countdown. Целевая граница:

```swift
protocol GameTicker: AnyObject {
    func start(interval: TimeInterval, _ tick: @escaping () -> Void)
    func stop()
}
```

Round timer использует `1.0`; resume sequence — отдельную расписанную последовательность с injectable clock/task. Нельзя запускать второй игровой timer.

### Restore

Store inspection должен различать состояния, а не возвращать один `nil` для всех ошибок:

```swift
enum SavedGameAvailability: Equatable {
    case checking
    case none
    case available(SavedGameSummary)
    case invalid
    case loadFailed(message: String)
}
```

Restore mapping остаётся принятым:

- preparation → Round Call;
- playing/paused → paused Live Card;
- round end → Round Hit without score replay;
- completed game → save отсутствует.

---

## 6. Display models

Views и shared components не должны вычислять domain rules или искать связанные объекты по UUID. Feature boundary создаёт компактные display models.

```swift
struct TeamIdentityDisplayModel: Identifiable, Equatable {
    let id: Team.ID
    let name: String
    let style: TeamVisualStyle
}

enum TeamVisualStyle: Int, CaseIterable {
    case violetStripe
    case tealSplitCircle
    case orangeCross
    case pinkDots
    case greenChevron
}
```

Style определяется стабильной позицией команды в roster. Он не является произвольным `Color` и всегда включает цвет + геометрический marker.

```swift
struct SavedGameSummary: Equatable {
    let team: TeamIdentityDisplayModel
    let phaseLabel: String
    let contextLabel: String
}

struct ScoreCellDisplayModel: Identifiable, Equatable {
    let id: Team.ID
    let team: TeamIdentityDisplayModel
    let score: Int
    let isCurrent: Bool
    let isWinner: Bool
}

struct ChallengeDisplayModel: Equatable {
    let title: String
    let instruction: String
    let symbolName: String
}

struct WordOutcomeDisplayModel: Identifiable, Equatable {
    let id: WordCard.ID
    let word: String
    let outcome: WordOutcome
}

struct RoundResultDisplayModel: Equatable {
    let roundScore: Int
    let guessedCount: Int
    let skippedCount: Int
    let penaltyCount: Int?
    let outcomes: [WordOutcomeDisplayModel]
    let scores: [ScoreCellDisplayModel]
    let nextTeam: TeamIdentityDisplayModel
    let isRestored: Bool
}

struct VictoryDisplayModel: Equatable {
    let winner: TeamIdentityDisplayModel
    let winningScore: Int
    let scores: [ScoreCellDisplayModel]
    let finalRoundDelta: Int
}
```

Display models не `Codable` и не сохраняются. Persistence продолжает использовать domain snapshots.

---

## 7. Foundations SwiftUI API

### Colors

```swift
enum CardImpactColor {
    static let backgroundPrimary
    static let backgroundElevated
    static let surfacePrimary
    static let surfaceMuted
    static let textOnDark
    static let textOnLight
    static let actionPrimary
    static let success
    static let danger
    static let warning
    static let borderStrong
}
```

Raw palette values остаются private/internal implementation details. Shared public controls не принимают произвольный `Color`, кроме закрытого `TeamVisualStyle`.

### Typography

```swift
enum CardImpactTypography {
    static let scoreHero: Font
    static let displayHero: Font
    static let gameWord: Font
    static let gameTimer: Font
    static let screenTitle: Font
    static let sectionTitle: Font
    static let actionLabel: Font
    static let bodyEmphasis: Font
    static let body: Font
    static let bodySmall: Font
    static let caption: Font
}
```

- Sofia Sans используется только для display styles.
- Interface text строится через relative system text styles.
- Timer получает condensed width и `.monospacedDigit()`.
- Game word имеет bounded scale 64 → 40 pt и максимум две строки.

### Metrics

```swift
enum CardImpactSpacing { /* 4, 8, 12, 16, 24, 32, 48, 64 */ }
enum CardImpactRadius { /* 8, 14, 18, 24 */ }
enum CardImpactBorder { /* 1, 2, 3 */ }
enum CardImpactShadow { /* 3, 5, 8, 12 */ }
enum CardImpactOpacity { /* disabled 0.38, pause 0.88 */ }
enum CardImpactLayout {
    static let minimumTouchTarget: CGFloat = 44
    static let setupTouchTarget: CGFloat = 48
    static let maximumContentWidth: CGFloat = 600
    static func screenInset(for width: CGFloat) -> CGFloat
}
```

`screenInset`: 20 pt до 375, 24 pt для standard, 32 pt от 430.

### Motion

```swift
enum CardImpactMotion {
    enum Duration { /* 80, 120, 160, 200, 280, 220, 160, 520, 720 ms */ }
    static func impactOut(reduceMotion: Bool) -> Animation
    static func exit(reduceMotion: Bool) -> Animation
    static func standard(reduceMotion: Bool) -> Animation
    static func returnSpring(reduceMotion: Bool) -> Animation
    static func enterSpring(reduceMotion: Bool) -> Animation
    static func impactSpring(reduceMotion: Bool) -> Animation
}
```

Глобальный `.animation` на корневом view запрещён. Animation задаётся локально на конкретное state change.

---

## 8. Public component APIs

Ниже зафиксирована форма API. Названия labels могут быть `LocalizedStringKey` или готовым локализованным `String`, но компонент не придумывает copy.

### Actions

```swift
enum ImpactButtonRole { case primary, secondary, destructive }

struct ImpactButton: View {
    init(
        title: LocalizedStringKey,
        systemImage: String? = nil,
        role: ImpactButtonRole,
        isLoading: Bool = false,
        action: @escaping () -> Void
    )
}
```

Disabled приходит через environment. Loading сохраняет label и размеры.

```swift
struct StepNavigationControl: View {
    init(
        canGoBack: Bool,
        canGoForward: Bool,
        isForwardLoading: Bool = false,
        forwardAccessibilityLabel: LocalizedStringKey,
        onBack: @escaping () -> Void,
        onForward: @escaping () -> Void
    )
}
```

Back 64 pt Bone; Forward 76 pt Cobalt. Компонент не валидирует setup.

```swift
struct RoundOutcomeControls: View {
    init(
        isInputLocked: Bool,
        onSkip: @escaping () -> Void,
        onCorrect: @escaping () -> Void
    )
}

enum UtilityIconKind { case pause, close, info, menu }

struct UtilityIconButton: View {
    init(
        kind: UtilityIconKind,
        accessibilityLabel: LocalizedStringKey,
        action: @escaping () -> Void
    )
}
```

### Setup

```swift
struct SetupHeader: View {
    init(title: String, step: Int, totalSteps: Int = 3)
}

enum ValueStepperKind { case targetScore, roundDuration }

struct ValueStepperCard: View {
    init(
        kind: ValueStepperKind,
        value: Int,
        range: ClosedRange<Int>,
        step: Int,
        onChange: @escaping (Int) -> Void
    )
}

struct SettingRow: View {
    init(
        title: String,
        explanation: String? = nil,
        isOn: Binding<Bool>
    )
}

struct FrequencyPicker: View {
    init(selection: Binding<Challenge>)
}

struct ChallengeSelectionRow: View {
    init(
        model: ChallengeDisplayModel,
        isSelected: Bool,
        isEnabled: Bool,
        action: @escaping () -> Void
    )
}

enum CategoryAvailability { case available, unavailable }

struct CategoryCard: View {
    init(
        title: String,
        descriptor: String? = nil,
        isSelected: Bool,
        availability: CategoryAvailability,
        action: @escaping () -> Void
    )
}

struct TeamCard: View {
    init(
        team: TeamIdentityDisplayModel,
        canRemove: Bool,
        onRemove: @escaping () -> Void
    )
}

enum AddTeamSlotState { case enabled, maximum }

struct AddTeamSlot: View {
    init(state: AddTeamSlotState, action: @escaping () -> Void)
}
```

### Game

```swift
enum TimerSignalState { case normal, warning, critical, expired, paused }

struct TimerSignalField: View {
    init(timeRemaining: Int, state: TimerSignalState)
}

enum WordCardVisualState: Equatable {
    case idle
    case previewCorrect(progress: CGFloat)
    case armedCorrect
    case previewSkip(progress: CGFloat)
    case armedSkip
    case resolving
    case defensiveError(message: String)
}

struct SignatureWordCard: View {
    init(word: String?, visualState: WordCardVisualState)
}
```

`SignatureWordCard` только рисует. `DragGesture` живёт в `LiveCardView` или отдельном feature-local gesture layer, потому что commit должен вызвать domain intent.

```swift
struct TeamBadge: View {
    init(team: TeamIdentityDisplayModel, roundDelta: Int)
}

struct SavedGameCard: View {
    init(availability: SavedGameAvailability)
}

struct TeamTurnHero: View {
    init(team: TeamIdentityDisplayModel, queuePosition: Int, teamCount: Int, round: Int)
}

struct CompactScoreboardStrip: View {
    init(scores: [ScoreCellDisplayModel])
}

struct RoundStartControl: View {
    init(isLoading: Bool, isEnabled: Bool, action: @escaping () -> Void)
}

enum ScoreboardRowStyle { case standard, currentTeam, winner, compact }

struct ScoreboardRow: View {
    init(model: ScoreCellDisplayModel, style: ScoreboardRowStyle)
}

enum ChallengeCardVariant { case preRound, inline, active }

struct ChallengeCard: View {
    init(model: ChallengeDisplayModel?, variant: ChallengeCardVariant)
}

struct RoundResultHero: View {
    init(score: Int, isRestored: Bool)
}

struct ScoreBreakdown: View {
    init(guessed: Int, skipped: Int, penalty: Int?, total: Int)
}

struct WordOutcomeList: View {
    init(items: [WordOutcomeDisplayModel])
}

struct RoundAdvanceControl: View {
    init(
        nextTeam: TeamIdentityDisplayModel,
        isLoading: Bool,
        isEnabled: Bool,
        action: @escaping () -> Void
    )
}

struct VictoryHero: View {
    init(model: VictoryDisplayModel, playEntrance: Bool)
}
```

### Feedback

```swift
struct InlineValidationMessage: View {
    init(message: String)
}

enum StatusPanelState: Equatable {
    case loading(message: String)
    case empty(title: String, message: String)
    case recoverableError(title: String, message: String)
    case blockingError(title: String, message: String, isStateSafe: Bool)
}

struct StatusPanel<ActionContent: View>: View {
    init(state: StatusPanelState, @ViewBuilder actions: () -> ActionContent)
}

struct PauseOverlay: View {
    init(
        team: TeamIdentityDisplayModel,
        remainingTime: Int,
        restoreMessage: String?,
        onContinue: @escaping () -> Void,
        onRules: @escaping () -> Void,
        onMenu: @escaping () -> Void
    )
}
```

---

## 9. Screen composition contracts

| Screen | Scroll | Pinned zone | First focus | Primary intent |
| --- | --- | --- | --- | --- |
| Stage Door | no, standard height | lower action stack | Alias lockup → saved context | Continue/New Game |
| Line-up | yes | StepNavigationControl | first team card | Forward |
| Game Pulse | yes | StepNavigationControl | target/time pair | Forward |
| Word Deck | yes | StepNavigationControl | first/selected category | Forward confirm |
| Round Call | conditional | RoundStartControl | current team | Start round |
| Live Card | never | outcome controls | current word | resolve word |
| Round Hit | yes | RoundAdvanceControl | round score | next team |
| Victory Slam | conditional | action stack | winner | New Game |

Для pinned zones используется `safeAreaInset(edge: .bottom)`, а не overlay поверх ScrollView. Scroll content получает системно корректную нижнюю область и не требует magic padding.

### Stable phase container

`GameView` сохраняет единый Ink background и переключает phase content через explicit `switch`. Toolbar старого интерфейса удаляется; menu/pause являются screen-local `UtilityIconButton`, чтобы hierarchy соответствовала дизайну.

---

## 10. Resources и assets

### Font

Новый обязательный ресурс:

```text
Resourses/Fonts/SofiaSansExtraCondensed-Black.ttf
```

Также в bundle добавляется файл лицензии `OFL.txt`. Точное PostScript name проверяется после добавления файла и централизуется в одной константе. `Super-Crown.ttf` не используется Card Impact и удаляется только после миграции последнего старого экрана.

Fallback:

- `Font.system(..., design: .default).width(.condensed).weight(.black)`;
- fallback должен применяться централизованно, а не на отдельных экранах;
- отсутствие custom font в production build считается P1 defect.

### SF Symbols

Основные symbols:

- `arrow.left`, `arrow.right`;
- `play.fill`, `pause.fill`, `xmark`, `checkmark`;
- `timer`, `stopwatch.fill`;
- `book.closed.fill`, `info.circle`, `line.3.horizontal`;
- challenge symbols из `GameChallenge.symbolName`.

Каждый symbol проверяется на iOS 17.5. Недоступный symbol получает явный fallback в semantic icon map.

### Custom drawing

| Asset | Implementation | Cost | Fallback |
| --- | --- | --- | --- |
| Cut corner | SwiftUI `Shape` | low | normal rounded rectangle |
| Flat shadow | offset shape layer | low | 2 pt border |
| Team markers | SwiftUI Shape/SF Symbol | low | symbol + text label |
| Impact marks | Shape/Canvas | low | static symbol |
| Alias lockup | SwiftUI text + card layers | medium | static vector PDF after typography lock |
| Victory burst | static shapes + keyframes | medium | static marks + fade |

Raster UI assets, Metal, shader, SceneKit and third-party animation libraries не нужны.

### Sound assets

Планируемые имена:

```text
correct.caf
skip.caf
critical-tick.caf
round-end.caf
countdown.caf
round-start.caf
victory.caf
```

Финальные audio files ещё не являются частью handoff. До их появления UI реализуется без подмены системными звуками, которые невозможно последовательно отключить setting-ом. `isSoundEnabled = false` обязан отключать все cues из sound matrix.

---

## 11. Motion implementation map

| Motion | SwiftUI mechanism | State source |
| --- | --- | --- |
| Button press | custom `ButtonStyle` | `configuration.isPressed` |
| Setup step | `.transition` + explicit transaction | `SetupStep` |
| Drag preview | direct `DragGesture` values, no implicit animation | View local |
| Card cancel | explicit spring/ease | View local release |
| Card resolution | outgoing snapshot + identity transition | accepted outcome event |
| Timer state | explicit enum transition | remaining time mapping |
| Pause | opacity/offset transition | game phase |
| Resume | `KeyframeAnimator` or cancellable task | countdown step |
| Round Hit | keyframe/phase entrance | committed snapshot |
| Victory | finite `KeyframeAnimator` | final snapshot |

### Card resolution sequence

1. `LiveCardView` captures current display word as outgoing snapshot.
2. It calls `resolveWord(id:as:)` once.
3. ViewModel commits score, advances word and checkpoints immediately.
4. Snapshot exits for 220 ms.
5. New current word enters for 160 ms.
6. Local input lock clears no later than 380 ms.

No domain transition waits for animation completion.

### Feedback event

ViewModel exposes one-shot semantic events, not raw colors:

```swift
struct GameFeedbackEvent: Identifiable, Equatable {
    let id: UUID
    let kind: GameFeedbackKind
}

enum GameFeedbackKind: Equatable {
    case correct
    case skipped
    case warningThreshold
    case criticalThreshold
    case timerExpired
    case roundStarted
    case roundEnded
    case victory
}
```

У каждого semantic event новый ID, поэтому `.sensoryFeedback(trigger:)` срабатывает ровно один раз даже для одинакового kind в соседних раундах. Sound player maps `kind` through the sound setting. Drag preview itself never triggers sound.

---

## 12. Adaptive layout and accessibility

### Size profiles

```swift
enum CardImpactSizeProfile {
    case compact   // width <= 375
    case standard  // 376...429
    case large     // width >= 430
}
```

Profile is derived from actual container width through `GeometryReader` at screen boundary. Components receive semantic size where necessary; they do not read device model names.

### Environment values to support

- `dynamicTypeSize`;
- `accessibilityReduceMotion`;
- `accessibilityDifferentiateWithoutColor`;
- `accessibilityVoiceOverEnabled` where interaction strategy changes;
- `scenePhase` in game container only.

### Dynamic Type switches

- `FrequencyPicker`: segmented → vertical single-choice list;
- `RoundOutcomeControls`: circles → full-width action cards;
- `RoundStartControl` / `RoundAdvanceControl`: label + circle → full-width text action;
- `TeamBadge`: 44 → up to 64 pt, two lines;
- setup cards grow vertically;
- full word and timer values remain exposed to VoiceOver even when visual scaling is bounded.

### Reading order

Live Card:

1. word;
2. remaining time;
3. team and round delta;
4. Skip;
5. Correct;
6. Pause.

Pause removes underlying active controls from the accessibility tree. Resume announces only the current numeral/message.

### Color scheme

Card Impact v1 is one authored visual theme, not separate light/dark themes. Main app surfaces use Ink/Bone semantics and a dark status-bar context. Rules sheet may use Bone presentation background with light content appearance. System confirmation retains native appearance.

---

## 13. Preview matrix

Не нужен preview каждого boolean. Нужны previews, которые ловят композиционные поломки и обязательные semantic states.

### Devices

| Profile | Reference device | Size intent |
| --- | --- | --- |
| Compact | iPhone SE (3rd generation) | 375 × 667 |
| Standard | iPhone 15 Pro | 393 × 852 |
| Large | iPhone 15 Pro Max | 430 × 932 |
| Landscape | iPhone 15 Pro | short-height behavior |

### Environment variants

- default text;
- `.accessibility3` Dynamic Type;
- Reduce Motion;
- Differentiate Without Color;
- long Russian team name;
- longest available word/title;
- 5 teams;
- sound off for event routing tests.

### Required component previews

- `ImpactButton`: primary/secondary/destructive + pressed/disabled/loading;
- `StepNavigationControl`: enabled/disabled/loading;
- `ValueStepperCard`: both closed variants + min/max;
- `FrequencyPicker`: segmented/accessibility list;
- `CategoryCard`: default/selected/unavailable;
- `SignatureWordCard`: idle/correct/skip/error;
- `TimerSignalField`: normal/warning/critical/expired/paused;
- `RoundOutcomeControls`: circles/accessibility cards;
- `StatusPanel`: loading/empty/recoverable/blocking.

### Required screen previews

- Stage Door: none/available/invalid save;
- Line-up: 2 and 5 teams;
- Game Pulse: valid and active-frequency-empty-selection;
- Word Deck: no selection/selected/unavailable-all;
- Round Call: no challenge/challenge;
- Live Card: normal/critical/paused/no-word;
- Round Hit: positive/zero/restored/empty outcomes;
- Victory: 2 teams/5 teams/long winner name.

Preview fixtures должны быть deterministic и не обращаться к SwiftData, timers, random names или real audio.

---

## 14. Safe implementation order

Каждый slice должен собираться, иметь previews и не требовать одновременного переписывания всего приложения.

### Slice 0 — Card Impact foundations

- добавить Sofia Sans и license;
- реализовать color, typography, spacing, shape, shadow и motion tokens;
- реализовать primitives;
- создать component preview gallery;
- старый UI не менять.

Exit: foundations соответствуют numeric contract и проверены на compact/standard/large.

### Slice 1 — Actions and setup controls

- `ImpactButton`;
- `StepNavigationControl`;
- `SetupHeader`;
- `ValueStepperCard`;
- setting/frequency/challenge/category/team controls;
- accessibility variants.

Exit: component boards 17–18 воспроизводятся без screen-specific forks.

### Slice 2 — Stage Door

- `StageDoorScene/View/ViewModel`;
- save availability enum and summary adapter;
- native Rules sheet;
- replacement confirmation;
- loading threshold 250 ms;
- заменить только root screen.

Exit: no-save, valid-save, invalid-save и load-failure paths работают.

### Slice 3 — Unified setup

- `SetupDraft` и `SetupFlowViewModel`;
- Line-up, Game Pulse, Word Deck;
- Back preserves draft;
- category tap selects only;
- final Forward builds config;
- preferences store and unique team generator seams.

Exit: новый setup полностью заменяет три старых модуля, но game UI ещё может быть старым.

### Slice 4 — Match shell and Round Call

- `GameScene` lifecycle;
- phase switch without old toolbar;
- display model adapters;
- Round Call components;
- Play starts timer only after Live Card becomes interactive.

Exit: new setup opens new Round Call and creates first valid checkpoint.

### Slice 5 — Live Card core

- timer signal field;
- signature card and gesture layer;
- outcome controls;
- idempotent `resolveWord(id:as:)`;
- 380 ms replacement choreography;
- haptic/sound event routing;
- defensive no-word state.

Exit: full round can be played by swipe or buttons without double scoring.

### Slice 6 — Pause, restore and interruption

- Pause overlay;
- exact resume countdown;
- `scenePhase` interruption;
- active restore always paused;
- Rules from Pause;
- save-before-menu behavior and failure state.

Exit: app background/restore never resumes timer automatically.

### Slice 7 — Round Hit

- committed result snapshot adapter;
- breakdown/outcome list/scoreboard;
- restored result without replay;
- next-team transition.

Exit: positive, zero, no-word-outcomes and penalty-off cases are correct.

### Slice 8 — Victory Slam

- direct winning branch;
- final snapshot and save lifecycle;
- finite 720 ms choreography;
- New Game and Menu actions.

Exit: completed game cannot reappear as Continue.

### Slice 9 — Edge cases and design hardening

- category availability;
- storage failures;
- all Dynamic Type/Reduce Motion variants;
- final Rules copy;
- audio assets;
- physical-device gesture tuning;
- remove unused Party Pop code only after all routes are replaced.

---

## 15. Verification plan

### Unit tests

#### Setup

- initializes exactly two unique teams;
- add stops at five;
- remove stops at two;
- generated names remain unique;
- active challenge frequency requires a selected challenge;
- Back/Forward preserve all draft values;
- category tap does not navigate;
- unavailable category cannot be selected;
- final confirm emits exactly one config and one game launch;
- preferences are saved only at the documented point.

#### Game state

- Play starts one timer;
- duplicate word ID is ignored;
- button and swipe outcomes use the same transition;
- timer zero accepts no unresolved outcome;
- scoring floor remains zero;
- result commits once;
- next team rotates once;
- winning round goes directly to game end;
- restored round result never adds score again.

#### Persistence

- availability distinguishes none/invalid/failure/available;
- preparation restores Round Call;
- playing and paused restore Pause;
- round result restores committed snapshot;
- save completes before menu dismissal;
- completed game deletes active save;
- corrupted data never opens an empty game phase.

#### Timing

- warning occurs at 10 once;
- critical occurs at 5 once;
- expiration occurs once;
- resume sequence is `3, 2, 1, НАЧАЛИ!`;
- remaining round time does not change during resume;
- interruption cancels countdown and returns Pause.

All timers, random values, persistence and word order use injected test doubles.

### UI/design verification

- SwiftUI previews for the matrix above;
- physical iPhone check for 12%, 30%, 34% and fast-commit gesture thresholds;
- VoiceOver reading order;
- Switch Control path without swipe;
- Reduce Motion comparison;
- screen recording at 60 fps for 380/520/720 ms sequences;
- screenshot comparison with reference boards by hierarchy and proportion, not generated text artifacts.

Third-party snapshot-test framework is optional and not required for the first implementation.

---

## 16. Priority and cost

### Must ship

- semantic tokens and custom display font;
- exact Back/Forward and Skip/Correct hierarchy;
- unified reversible setup;
- explicit category confirmation;
- phase-safe timer and restore;
- readable Live Card;
- Round Hit scoring explanation;
- Victory save lifecycle;
- Dynamic Type, VoiceOver and Reduce Motion behavior;
- deterministic tests for state and persistence.

### Should ship

- impact marks;
- complete haptic matrix;
- saved-success notice;
- result and victory choreography;
- landscape adaptations.

### Can be simplified initially

- Alias lockup may be SwiftUI composition before a final vector asset;
- victory burst may use static shapes + fade;
- score count-up may be omitted while final value appears immediately;
- setup transition may be crossfade + 20 pt slide without custom geometry effect.

### Do not build

- Metal shader;
- realistic paper physics;
- particle/confetti engine;
- universal configurable card component;
- global animation system;
- custom modal replacement for native sheet/dialog;
- new architecture framework.

---

## 17. Known implementation gates

Эти пункты не блокируют начало slices 0–4, но должны быть закрыты до завершения всего продукта:

1. Починить пустые word pools до публикации соответствующих категорий.
2. Определить и реализовать пополнение исчерпанного word pool без пустой карточки.
3. Определить gameplay для `Общее последнее слово`; до реализации настройка не должна обещать неработающую функцию в release build.
4. Добавить финальные audio files и единый sound routing.
5. Утвердить финальный текст Rules.
6. Гарантировать уникальные названия команд.

Рекомендованный безопасный fallback для пунктов 1–3: недоступную возможность скрыть или явно disable, а не показывать работающей. Defensive Card Impact error остаётся последним рубежом, а не заменой domain behavior.

---

## 18. Definition of done этапа 7

- целевые feature modules и lifecycle ownership определены;
- setup draft и обратимая навигация имеют однозначного владельца;
- match остаётся одной state machine;
- display models отделены от persistence/domain snapshots;
- публичные component APIs и semantic enums зафиксированы;
- font, symbols, shapes, sound placeholders и fallbacks перечислены;
- motion сопоставлен со стандартными SwiftUI API;
- adaptive, Dynamic Type, VoiceOver и Reduce Motion rules включены;
- preview и test matrices определены;
- внедрение разбито на безопасные vertical slices;
- старый визуальный слой может заменяться постепенно без смешивания стилей на одном экране.

Этап 7 завершён. Следующий этап — реализация по slices и этап 8: дизайн-контроль собранных экранов на previews, simulator и физическом iPhone.
