import Foundation
import Combine

@MainActor
public final class GameViewModel: ObservableObject {
    @Published private(set) var currentState: GameState
    @Published private(set) var currentTeam: Team
    @Published private(set) var currentWord: WordCard?
    @Published private(set) var roundResults: [RoundResult]
    @Published private(set) var gameScores: [GameScore]
    @Published private(set) var gameInfo: GameInfo
    @Published private(set) var currentChallenge: GameChallenge?
    @Published private(set) var resumeCountdownStep: ResumeCountdownStep?
    @Published private(set) var lastPersistenceError: String?

    public let timerViewModel: TimerViewModel
    public let gameConfig: GameConfigModel

    private let store: GameSessionStore
    private let router: RouterProtocol
    private let randomValue: () -> Double
    private let wordShuffler: ([WordCard]) -> [WordCard]
    private let countdownTicker: GameTicker

    private var words: [WordCard]
    private var currentTeamIndex: Int

    init(
        gameConfig: GameConfigModel,
        store: GameSessionStore = UnavailableGameSessionStore.shared,
        router: RouterProtocol = Router.shared,
        randomValue: @escaping () -> Double = { Double.random(in: 0..<1) },
        wordShuffler: @escaping ([WordCard]) -> [WordCard] = { $0.shuffled() },
        tickerFactory: @escaping @MainActor () -> GameTicker = { FoundationGameTicker() }
    ) {
        let firstTeam = gameConfig.teams.first ?? Team(name: "Команда")
        var teamsMap = Dictionary(uniqueKeysWithValues: gameConfig.teams.map { ($0.id, $0) })
        teamsMap[firstTeam.id] = firstTeam

        self.gameConfig = gameConfig
        self.store = store
        self.router = router
        self.randomValue = randomValue
        self.wordShuffler = wordShuffler
        self.countdownTicker = tickerFactory()
        self.timerViewModel = TimerViewModel(
            initialTime: gameConfig.configuration.roundTimer,
            ticker: tickerFactory()
        )
        self.currentState = .preparing
        self.currentTeam = firstTeam
        self.currentWord = nil
        self.roundResults = []
        self.gameScores = gameConfig.teams.map { GameScore(teamId: $0.id) }
        self.gameInfo = GameInfo(teams: teamsMap)
        self.currentChallenge = nil
        self.resumeCountdownStep = nil
        self.lastPersistenceError = nil
        self.currentTeamIndex = 0

        let category = gameConfig.words ?? .light
        let initialWords = GameData.getCurrentCategoryWords(category: category)
            .map { WordCard(word: $0) }
        self.words = wordShuffler(initialWords)

        bindTimer()
        prepareChallenge()
        checkpoint()
    }

    init(
        restoring snapshot: GameSessionSnapshot,
        store: GameSessionStore = UnavailableGameSessionStore.shared,
        router: RouterProtocol = Router.shared,
        randomValue: @escaping () -> Double = { Double.random(in: 0..<1) },
        wordShuffler: @escaping ([WordCard]) -> [WordCard] = { $0.shuffled() },
        tickerFactory: @escaping @MainActor () -> GameTicker = { FoundationGameTicker() }
    ) {
        precondition(snapshot.isValid, "A restored game requires a valid snapshot")

        let gameConfig = snapshot.gameConfig
        var teamsMap = Dictionary(uniqueKeysWithValues: gameConfig.teams.map { ($0.id, $0) })
        let restoredCurrentTeam = snapshot.currentTeam.model
        teamsMap[restoredCurrentTeam.id] = restoredCurrentTeam

        self.gameConfig = gameConfig
        self.store = store
        self.router = router
        self.randomValue = randomValue
        self.wordShuffler = wordShuffler
        self.countdownTicker = tickerFactory()
        self.timerViewModel = TimerViewModel(
            initialTime: gameConfig.configuration.roundTimer,
            timeRemaining: snapshot.remainingTime,
            ticker: tickerFactory()
        )
        self.currentState = snapshot.phase.safeRuntimeState
        self.currentTeam = restoredCurrentTeam
        self.words = snapshot.orderedWords.map(\.model)
        self.currentWord = snapshot.currentWordID.flatMap { id in
            snapshot.orderedWords.first(where: { $0.id == id })?.model
        }
        self.roundResults = snapshot.roundResults.map(\.model)
        self.gameScores = snapshot.scores.map(\.model)
        self.gameInfo = GameInfo(
            id: snapshot.gameInfoID,
            gameNumber: snapshot.gameNumber,
            currentRound: snapshot.currentRound,
            teams: teamsMap
        )
        self.currentChallenge = snapshot.currentChallenge
        self.resumeCountdownStep = nil
        self.lastPersistenceError = nil
        self.currentTeamIndex = snapshot.currentTeamIndex

        bindTimer()
    }

    func startGame() {
        guard currentState == .preparing else { return }

        currentState = .playing
        moveToNextWord()
        timerViewModel.reset()
        checkpoint()
        timerViewModel.start()
    }

    func prepareForNextRound() {
        guard currentState == .roundEnd else { return }

        currentTeamIndex = (currentTeamIndex + 1) % gameConfig.teams.count
        gameInfo.currentRound += 1
        if gameInfo.currentRound > gameConfig.teams.count {
            gameInfo.currentRound = 1
            gameInfo.gameNumber += 1
        }

        currentTeam = gameConfig.teams[currentTeamIndex]
        currentWord = nil
        timerViewModel.reset()
        currentState = .preparing
        prepareChallenge()
        checkpoint()
    }

    func markWordAsGuessed() {
        guard currentState == .playing,
              let currentWord,
              let wordIndex = words.firstIndex(where: { $0.id == currentWord.id })
        else { return }

        words[wordIndex].isGuessed = true
        currentTeam.roundResult.correctWords.append(words[wordIndex])
        moveToNextWord()
        checkpoint()
    }

    func skipWord() {
        guard currentState == .playing,
              let currentWord,
              let wordIndex = words.firstIndex(where: { $0.id == currentWord.id })
        else { return }

        words[wordIndex].isSkipped = true
        currentTeam.roundResult.skippedWords.append(words[wordIndex])
        if gameConfig.configuration.isSkipPenalty {
            currentTeam.roundResult.penalties += 1
        }
        moveToNextWord()
        checkpoint()
    }

    func pauseGame() {
        guard currentState == .playing else { return }
        timerViewModel.pause()
        currentState = .paused
        checkpoint()
    }

    func resumeGame() {
        guard currentState == .paused else { return }

        timerViewModel.pause()
        currentState = .resumeCountdown
        resumeCountdownStep = .three
        checkpoint()
        countdownTicker.start { [weak self] in
            self?.advanceResumeCountdown()
        }
    }

    func applicationDidBecomeInactive() {
        switch currentState {
        case .playing:
            timerViewModel.pause()
            currentState = .paused
            checkpoint()
        case .resumeCountdown:
            countdownTicker.stop()
            resumeCountdownStep = nil
            currentState = .paused
            checkpoint()
        default:
            break
        }
    }

    func returnToMenu() {
        switch currentState {
        case .playing:
            timerViewModel.pause()
            currentState = .paused
        case .resumeCountdown:
            countdownTicker.stop()
            resumeCountdownStep = nil
            currentState = .paused
        default:
            break
        }

        if currentState == .gameEnd || checkpoint() {
            router.backToRoot()
        }
    }

    func makeSnapshot() -> GameSessionSnapshot? {
        guard let phase = currentState.persistedPhase else { return nil }

        return GameSessionSnapshot(
            configuration: ConfigurationSnapshot(gameConfig.configuration),
            teams: gameConfig.teams.map(TeamSnapshot.init),
            category: gameConfig.words ?? .light,
            phase: phase,
            currentTeamIndex: currentTeamIndex,
            currentTeam: TeamSnapshot(currentTeam),
            gameInfoID: gameInfo.id,
            gameNumber: gameInfo.gameNumber,
            currentRound: gameInfo.currentRound,
            scores: gameScores.map(GameScoreSnapshot.init),
            roundResults: roundResults.map(RoundResultSnapshot.init),
            orderedWords: words.map(WordCardSnapshot.init),
            currentWordID: currentWord?.id,
            currentChallenge: currentChallenge,
            remainingTime: timerViewModel.timeRemaining
        )
    }

    private func bindTimer() {
        timerViewModel.onTick = { [weak self] _ in
            self?.checkpoint()
        }
        timerViewModel.onExpiration = { [weak self] in
            self?.timerDidExpire()
        }
    }

    private func prepareChallenge() {
        let configuration = gameConfig.configuration
        let selectedChallenges = configuration.selectedChallenges

        guard !selectedChallenges.isEmpty,
              randomValue() < configuration.challenges.activationProbability
        else {
            currentChallenge = nil
            return
        }

        let alternatives = selectedChallenges.filter { $0 != currentChallenge }
        let candidates = alternatives.isEmpty ? selectedChallenges : alternatives
        let rawIndex = Int(randomValue() * Double(candidates.count))
        currentChallenge = candidates[min(rawIndex, candidates.count - 1)]
    }

    private func moveToNextWord() {
        currentWord = words.first { !$0.isGuessed && !$0.isSkipped }
    }

    private func advanceResumeCountdown() {
        guard currentState == .resumeCountdown, let resumeCountdownStep else {
            countdownTicker.stop()
            return
        }

        switch resumeCountdownStep {
        case .three:
            self.resumeCountdownStep = .two
        case .two:
            self.resumeCountdownStep = .one
        case .one:
            self.resumeCountdownStep = .started
        case .started:
            countdownTicker.stop()
            self.resumeCountdownStep = nil
            currentState = .playing
            checkpoint()
            timerViewModel.resume()
        }
    }

    private func timerDidExpire() {
        guard currentState == .playing else { return }
        endRound()
    }

    private func endRound() {
        guard currentState == .playing else { return }

        timerViewModel.pause()
        currentState = .roundEnd

        if let index = gameScores.firstIndex(where: { $0.teamId == currentTeam.id }) {
            gameScores[index].totalScore += currentTeam.roundResult.score
            gameInfo.teamsMap[currentTeam.id] = currentTeam
            roundResults.append(currentTeam.roundResult)
        }

        if gameScores.contains(where: { $0.totalScore >= gameConfig.configuration.wordsCount }) {
            currentState = .gameEnd
            do {
                try store.deleteActive()
                lastPersistenceError = nil
            } catch {
                lastPersistenceError = String(describing: error)
            }
        } else {
            checkpoint()
        }
    }

    @discardableResult
    private func checkpoint() -> Bool {
        guard let snapshot = makeSnapshot() else { return true }

        do {
            try store.saveActive(snapshot)
            lastPersistenceError = nil
            return true
        } catch {
            lastPersistenceError = String(describing: error)
            return false
        }
    }
}

private extension PersistedGamePhase {
    var safeRuntimeState: GameState {
        switch self {
        case .preparing: return .preparing
        case .playing, .paused: return .paused
        case .roundEnd: return .roundEnd
        }
    }
}

private extension GameState {
    var persistedPhase: PersistedGamePhase? {
        switch self {
        case .preparing: return .preparing
        case .playing: return .playing
        case .paused, .resumeCountdown: return .paused
        case .roundEnd: return .roundEnd
        case .gameEnd: return nil
        }
    }
}
