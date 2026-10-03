import SwiftData
import XCTest
@testable import Alias

final class PartyPopDesignSystemTests: XCTestCase {
    func testSemanticColorTokensMatchApprovedPalette() {
        XCTAssertEqual(
            Dictionary(uniqueKeysWithValues: PartyColorToken.allCases.map { ($0, $0.hex) }),
            [
                .background: "193564",
                .elevated: "244777",
                .spotlight: "5182BC",
                .primaryAction: "DC3C24",
                .coral: "DC3C24",
                .lime: "E6BF98",
                .yellow: "E6BF98",
                .success: "E6BF98",
                .danger: "DC3C24",
                .info: "5182BC",
                .primaryText: "F6E8DD",
                .secondaryText: "E6BF98"
            ]
        )
    }

    func testLayoutTokensMatchApprovedScaleAndTouchTarget() {
        XCTAssertEqual(PartySpacing.all, [4, 8, 12, 16, 24, 32, 40])
        XCTAssertEqual(PartyRadius.all, [12, 20, 28, 1_000])
        XCTAssertEqual(PartyLayout.minimumTouchTarget, 44)
    }

    func testSemanticIconsAndChallengeMappingsUseExpectedSFSymbols() {
        XCTAssertEqual(PartyIcon.play.systemName, "play.fill")
        XCTAssertEqual(PartyIcon.pause.systemName, "pause.fill")
        XCTAssertEqual(PartyIcon.add.systemName, "plus")
        XCTAssertEqual(PartyIcon.delete.systemName, "trash.fill")
        XCTAssertEqual(PartyIcon.back.systemName, "chevron.left")
        XCTAssertEqual(PartyIcon.forward.systemName, "chevron.right")
        XCTAssertEqual(PartyIcon.correct.systemName, "checkmark")
        XCTAssertEqual(PartyIcon.skip.systemName, "xmark")

        XCTAssertEqual(GameChallenge.whisper.symbolName, PartyIcon.whisper.systemName)
        XCTAssertEqual(GameChallenge.robotVoice.symbolName, PartyIcon.robotVoice.systemName)
        XCTAssertEqual(GameChallenge.imagineOpening.symbolName, PartyIcon.imagineOpening.systemName)
    }
}

@MainActor
final class SnapshotAndTimerTests: XCTestCase {
    func testSnapshotJSONRoundTripPreservesStableIdentityAndState() throws {
        let store = SpyGameSessionStore()
        let factory = ManualTickerFactory()
        let viewModel = GameViewModel(
            gameConfig: makeGameConfig(),
            store: store,
            router: SpyRouter(),
            randomValue: { 1 },
            wordShuffler: { $0 },
            tickerFactory: factory.make
        )

        viewModel.startGame()
        viewModel.markWordAsGuessed()

        let snapshot = try XCTUnwrap(store.savedSnapshots.last)
        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(GameSessionSnapshot.self, from: data)

        XCTAssertEqual(decoded, snapshot)
        XCTAssertEqual(decoded.currentTeam.id, viewModel.currentTeam.id)
        XCTAssertEqual(decoded.configuration.id, viewModel.gameConfig.configuration.id)
        XCTAssertEqual(decoded.orderedWords.map(\.id), snapshot.orderedWords.map(\.id))
        XCTAssertTrue(decoded.isValid)
    }

    func testWordsCategoryIdentityIsStableAndCodable() throws {
        for category in WordsCategory.allCases {
            XCTAssertEqual(category.id, category.id)
            let data = try JSONEncoder().encode(category)
            XCTAssertEqual(try JSONDecoder().decode(WordsCategory.self, from: data), category)
        }
    }

    func testRestoredTimerTicksFromSavedValueAndExpiresExactlyOnce() {
        let ticker = ManualTicker()
        let timer = TimerViewModel(initialTime: 20, timeRemaining: 2, ticker: ticker)
        var ticks: [Int] = []
        var expirationCount = 0
        timer.onTick = { ticks.append($0) }
        timer.onExpiration = { expirationCount += 1 }

        timer.start()
        ticker.fire()
        ticker.fire()
        ticker.fire()
        timer.start()

        XCTAssertEqual(ticks, [1, 0])
        XCTAssertEqual(timer.timeRemaining, 0)
        XCTAssertFalse(timer.isRunning)
        XCTAssertTrue(timer.isEndTime)
        XCTAssertEqual(expirationCount, 1)
    }
}

@MainActor
final class SwiftDataGameSessionStoreTests: XCTestCase {
    func testOneSlotReplacementRoundTripAndDeletion() throws {
        let container = try makeInMemoryContainer()
        let store = SwiftDataGameSessionStore(
            modelContext: container.mainContext,
            now: { Date(timeIntervalSince1970: 100) }
        )
        let first = makeSnapshot(phase: .preparing, remainingTime: 8)
        let replacement = makeSnapshot(phase: .paused, remainingTime: 4)

        try store.saveActive(first)
        try store.saveActive(replacement)

        XCTAssertEqual(store.loadActive(), replacement)
        XCTAssertEqual(
            try container.mainContext.fetch(FetchDescriptor<SavedGameRecord>()).count,
            1
        )

        try store.deleteActive()
        XCTAssertNil(store.loadActive())
        XCTAssertTrue(try container.mainContext.fetch(FetchDescriptor<SavedGameRecord>()).isEmpty)
    }

    func testUnsupportedAndCorruptRecordsAreIsolated() throws {
        let unsupportedContainer = try makeInMemoryContainer()
        let validPayload = try JSONEncoder().encode(makeSnapshot())
        unsupportedContainer.mainContext.insert(
            SavedGameRecord(schemaVersion: 999, payload: validPayload)
        )
        try unsupportedContainer.mainContext.save()
        let unsupportedStore = SwiftDataGameSessionStore(
            modelContext: unsupportedContainer.mainContext
        )
        XCTAssertNil(unsupportedStore.loadActive())

        let corruptContainer = try makeInMemoryContainer()
        corruptContainer.mainContext.insert(SavedGameRecord(payload: Data([0xFF, 0x00])))
        try corruptContainer.mainContext.save()
        let corruptStore = SwiftDataGameSessionStore(modelContext: corruptContainer.mainContext)
        XCTAssertNil(corruptStore.loadActive())
    }
}

@MainActor
final class GameViewModelPersistenceTests: XCTestCase {
    func testRestoresPreparingStateExactlyWithoutStartingTimer() {
        let snapshot = makeSnapshot(phase: .preparing, remainingTime: 7)
        let viewModel = restoredViewModel(snapshot)

        XCTAssertEqual(viewModel.currentState, .preparing)
        XCTAssertEqual(viewModel.currentTeam.id, snapshot.currentTeam.id)
        XCTAssertEqual(viewModel.currentWord?.id, snapshot.currentWordID)
        XCTAssertEqual(viewModel.currentChallenge, snapshot.currentChallenge)
        XCTAssertEqual(viewModel.timerViewModel.timeRemaining, 7)
        XCTAssertFalse(viewModel.timerViewModel.isRunning)
        XCTAssertEqual(viewModel.makeSnapshot(), snapshot)
    }

    func testRestoresPlayingAndPausedSnapshotsAsPaused() {
        for phase in [PersistedGamePhase.playing, .paused] {
            let snapshot = makeSnapshot(phase: phase, remainingTime: 6)
            let viewModel = restoredViewModel(snapshot)

            XCTAssertEqual(viewModel.currentState, .paused)
            XCTAssertEqual(viewModel.timerViewModel.timeRemaining, 6)
            XCTAssertFalse(viewModel.timerViewModel.isRunning)
        }
    }

    func testRestoresRoundEndStateAndResult() {
        let snapshot = makeSnapshot(phase: .roundEnd, remainingTime: 0)
        let viewModel = restoredViewModel(snapshot)

        XCTAssertEqual(viewModel.currentState, .roundEnd)
        XCTAssertEqual(viewModel.roundResults.map(\.id), snapshot.roundResults.map(\.id))
        XCTAssertEqual(viewModel.gameScores.map(\.totalScore), snapshot.scores.map(\.totalScore))
        XCTAssertFalse(viewModel.timerViewModel.isRunning)
    }

    func testCheckpointsCreationActionsPhasesAndEveryTimerTick() {
        let store = SpyGameSessionStore()
        let factory = ManualTickerFactory()
        let viewModel = GameViewModel(
            gameConfig: makeGameConfig(roundTimer: 3),
            store: store,
            router: SpyRouter(),
            randomValue: { 1 },
            wordShuffler: { $0 },
            tickerFactory: factory.make
        )
        XCTAssertEqual(store.savedSnapshots.count, 1)

        viewModel.startGame()
        XCTAssertEqual(store.savedSnapshots.count, 2)

        factory.timer.fire()
        XCTAssertEqual(store.savedSnapshots.last?.remainingTime, 2)

        viewModel.markWordAsGuessed()
        XCTAssertEqual(store.savedSnapshots.last?.currentWordID, viewModel.currentWord?.id)

        viewModel.pauseGame()
        XCTAssertEqual(store.savedSnapshots.last?.phase, .paused)
    }

    func testTimerExpirationImmediatelyEndsRoundOnlyOnce() {
        let store = SpyGameSessionStore()
        let factory = ManualTickerFactory()
        let viewModel = GameViewModel(
            gameConfig: makeGameConfig(roundTimer: 1, targetScore: 20),
            store: store,
            router: SpyRouter(),
            randomValue: { 1 },
            wordShuffler: { $0 },
            tickerFactory: factory.make
        )

        viewModel.startGame()
        factory.timer.fire()
        factory.timer.fire()

        XCTAssertEqual(viewModel.currentState, .roundEnd)
        XCTAssertEqual(viewModel.roundResults.count, 1)
        XCTAssertEqual(store.savedSnapshots.last?.phase, .roundEnd)

        viewModel.prepareForNextRound()
        XCTAssertEqual(viewModel.currentState, .preparing)
        XCTAssertEqual(store.savedSnapshots.last?.phase, .preparing)
    }

    func testResumeCountdownRejectsRepeatsAndRestartsAfterInterruption() {
        let store = SpyGameSessionStore()
        let factory = ManualTickerFactory()
        let viewModel = GameViewModel(
            gameConfig: makeGameConfig(roundTimer: 5),
            store: store,
            router: SpyRouter(),
            randomValue: { 1 },
            wordShuffler: { $0 },
            tickerFactory: factory.make
        )
        viewModel.startGame()
        factory.timer.fire()
        viewModel.pauseGame()
        let savedRemainder = viewModel.timerViewModel.timeRemaining

        viewModel.resumeGame()
        viewModel.resumeGame()
        XCTAssertEqual(factory.countdown.startCount, 1)
        XCTAssertEqual(viewModel.resumeCountdownStep, .three)
        XCTAssertEqual(viewModel.timerViewModel.timeRemaining, savedRemainder)

        factory.countdown.fire()
        XCTAssertEqual(viewModel.resumeCountdownStep, .two)
        viewModel.applicationDidBecomeInactive()
        XCTAssertEqual(viewModel.currentState, .paused)
        XCTAssertNil(viewModel.resumeCountdownStep)

        viewModel.resumeGame()
        XCTAssertEqual(viewModel.resumeCountdownStep, .three)
        factory.countdown.fire(times: 4)

        XCTAssertEqual(viewModel.currentState, .playing)
        XCTAssertNil(viewModel.resumeCountdownStep)
        XCTAssertTrue(viewModel.timerViewModel.isRunning)
        XCTAssertEqual(viewModel.timerViewModel.timeRemaining, savedRemainder)
    }

    func testGameEndDeletesActiveSave() {
        let store = SpyGameSessionStore()
        let factory = ManualTickerFactory()
        let viewModel = GameViewModel(
            gameConfig: makeGameConfig(roundTimer: 1, targetScore: 1),
            store: store,
            router: SpyRouter(),
            randomValue: { 1 },
            wordShuffler: { $0 },
            tickerFactory: factory.make
        )

        viewModel.startGame()
        viewModel.markWordAsGuessed()
        factory.timer.fire()

        XCTAssertEqual(viewModel.currentState, .gameEnd)
        XCTAssertEqual(store.deleteCount, 1)
        XCTAssertNil(store.activeSnapshot)
    }

    func testReturnToMenuPausesSavesThenReturnsToRoot() {
        let store = SpyGameSessionStore()
        let router = SpyRouter()
        let factory = ManualTickerFactory()
        let viewModel = GameViewModel(
            gameConfig: makeGameConfig(),
            store: store,
            router: router,
            randomValue: { 1 },
            wordShuffler: { $0 },
            tickerFactory: factory.make
        )
        viewModel.startGame()

        viewModel.returnToMenu()

        XCTAssertEqual(viewModel.currentState, .paused)
        XCTAssertFalse(viewModel.timerViewModel.isRunning)
        XCTAssertEqual(store.savedSnapshots.last?.phase, .paused)
        XCTAssertEqual(router.backToRootCount, 1)
    }
}

@MainActor
final class EntranceViewModelTests: XCTestCase {
    func testContinueDisabledWhenNoValidSaveAndMissingLoadDoesNotNavigate() {
        let store = SpyGameSessionStore()
        let router = SpyRouter()
        let viewModel = EntranceViewModel(router: router, store: store)

        viewModel.refreshSaveAvailability()
        viewModel.select(.continueGame)

        XCTAssertFalse(viewModel.hasSavedGame)
        XCTAssertTrue(router.routes.isEmpty)
    }

    func testContinueLoadsValueSnapshotIntoTypedRoute() {
        let snapshot = makeSnapshot()
        let store = SpyGameSessionStore(activeSnapshot: snapshot)
        let router = SpyRouter()
        let viewModel = EntranceViewModel(router: router, store: store)

        viewModel.refreshSaveAvailability()
        viewModel.select(.continueGame)

        XCTAssertTrue(viewModel.hasSavedGame)
        XCTAssertEqual(router.routes, [.resumeGame(snapshot)])
    }

    func testCancelAndConfirmNewGameReplacement() {
        let snapshot = makeSnapshot()
        let store = SpyGameSessionStore(activeSnapshot: snapshot)
        let router = SpyRouter()
        let viewModel = EntranceViewModel(router: router, store: store)

        viewModel.select(.newGame)
        XCTAssertTrue(viewModel.isShowingReplacementConfirmation)
        viewModel.cancelNewGameReplacement()
        XCTAssertEqual(store.deleteCount, 0)
        XCTAssertEqual(store.activeSnapshot, snapshot)
        XCTAssertTrue(router.routes.isEmpty)

        viewModel.select(.newGame)
        viewModel.confirmNewGameReplacement()
        XCTAssertEqual(store.deleteCount, 1)
        XCTAssertNil(store.activeSnapshot)
        XCTAssertEqual(router.routes, [.showCommand])
    }

    func testRulesNavigationNeverReadsOrMutatesSave() {
        let store = SpyGameSessionStore(activeSnapshot: makeSnapshot())
        let router = SpyRouter()
        let viewModel = EntranceViewModel(router: router, store: store)

        viewModel.select(.rules)

        XCTAssertEqual(store.loadCount, 0)
        XCTAssertEqual(store.deleteCount, 0)
        XCTAssertEqual(router.routes, [.showRules])
    }
}

@MainActor
private final class ManualTicker: GameTicker {
    private var tick: (() -> Void)?
    private(set) var isStarted = false
    private(set) var startCount = 0

    func start(_ tick: @escaping () -> Void) {
        guard !isStarted else { return }
        self.tick = tick
        isStarted = true
        startCount += 1
    }

    func stop() {
        isStarted = false
        tick = nil
    }

    func fire(times: Int = 1) {
        for _ in 0..<times {
            guard isStarted, let tick else { return }
            tick()
        }
    }
}

@MainActor
private final class ManualTickerFactory {
    private(set) var created: [ManualTicker] = []

    var countdown: ManualTicker { created[0] }
    var timer: ManualTicker { created[1] }

    func make() -> GameTicker {
        let ticker = ManualTicker()
        created.append(ticker)
        return ticker
    }
}

@MainActor
private final class SpyGameSessionStore: GameSessionStore {
    var activeSnapshot: GameSessionSnapshot?
    private(set) var savedSnapshots: [GameSessionSnapshot] = []
    private(set) var loadCount = 0
    private(set) var deleteCount = 0

    init(activeSnapshot: GameSessionSnapshot? = nil) {
        self.activeSnapshot = activeSnapshot
    }

    func loadActive() -> GameSessionSnapshot? {
        loadCount += 1
        return activeSnapshot
    }

    func saveActive(_ snapshot: GameSessionSnapshot) throws {
        activeSnapshot = snapshot
        savedSnapshots.append(snapshot)
    }

    func deleteActive() throws {
        deleteCount += 1
        activeSnapshot = nil
    }
}

@MainActor
private final class SpyRouter: RouterProtocol {
    private(set) var routes: [Route] = []
    private(set) var backCount = 0
    private(set) var backToRootCount = 0

    func add(route: Route) {
        routes.append(route)
    }

    func back() {
        backCount += 1
    }

    func backToRoot() {
        backToRootCount += 1
        routes.removeAll()
    }
}

@MainActor
private func restoredViewModel(_ snapshot: GameSessionSnapshot) -> GameViewModel {
    GameViewModel(
        restoring: snapshot,
        store: SpyGameSessionStore(activeSnapshot: snapshot),
        router: SpyRouter(),
        randomValue: { 1 },
        wordShuffler: { $0 },
        tickerFactory: ManualTickerFactory().make
    )
}

private func makeGameConfig(
    roundTimer: Int = 10,
    targetScore: Int = 20
) -> GameConfigModel {
    GameConfigModel(
        teams: [Team(name: "Первая"), Team(name: "Вторая")],
        configuration: Configuration(
            wordsCount: targetScore,
            roundTimer: roundTimer,
            isSkipPenalty: true,
            islastWordForAllTeam: false,
            challenges: .always,
            selectedChallenges: [.whisper, .robotVoice],
            isSoundOn: true
        ),
        words: .light
    )
}

private func makeSnapshot(
    phase: PersistedGamePhase = .preparing,
    remainingTime: Int = 8
) -> GameSessionSnapshot {
    let firstWord = WordCard(word: "слово", isGuessed: true)
    let secondWord = WordCard(word: "пример")
    let completedResult = RoundResult(correctWords: [firstWord])
    let currentResult = RoundResult(skippedWords: [firstWord], penalties: 1)
    let firstTeam = Team(name: "Первая", roundResult: currentResult)
    let secondTeam = Team(name: "Вторая")
    let configuration = Configuration(
        wordsCount: 20,
        roundTimer: 10,
        isSkipPenalty: true,
        islastWordForAllTeam: false,
        challenges: .always,
        selectedChallenges: [.whisper],
        isSoundOn: true
    )

    return GameSessionSnapshot(
        configuration: ConfigurationSnapshot(configuration),
        teams: [TeamSnapshot(Team(id: firstTeam.id, name: firstTeam.name)), TeamSnapshot(secondTeam)],
        category: .light,
        phase: phase,
        currentTeamIndex: 0,
        currentTeam: TeamSnapshot(firstTeam),
        gameInfoID: UUID(),
        gameNumber: 2,
        currentRound: 1,
        scores: [
            GameScoreSnapshot(GameScore(teamId: firstTeam.id, totalScore: 3)),
            GameScoreSnapshot(GameScore(teamId: secondTeam.id, totalScore: 2))
        ],
        roundResults: [RoundResultSnapshot(completedResult)],
        orderedWords: [WordCardSnapshot(firstWord), WordCardSnapshot(secondWord)],
        currentWordID: secondWord.id,
        currentChallenge: .whisper,
        remainingTime: remainingTime
    )
}

@MainActor
private func makeInMemoryContainer() throws -> ModelContainer {
    try ModelContainer(
        for: SavedGameRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
}
