//
//  GameViewModel.swift
//  Alias
//
//  Created by Ernest Avagovich on 17.02.2025.
//

import Foundation
import Combine

public final class GameViewModel: ObservableObject {
    // MARK: - Published properties
    @Published private(set) var currentState: GameState = .preparing
    @Published private(set) var currentTeam: Team
    @Published private(set) var currentWord: WordCard?
    @Published private(set) var roundResults: [RoundResult] = []
    @Published private(set) var gameScores: [GameScore] = []
    @Published private(set) var gameInfo: GameInfo
    @Published private(set) var currentChallenge: GameChallenge?
    
    private var isEndRoundTime: Bool = false
    private var isFirstFlow: Bool = true
    private static var currentGameNumber: Int = 1
    
    private var disposables: Set<AnyCancellable> = []
    
    // MARK: - Public properties
    public var timerViewModel: TimerViewModel
    public let gameConfig: GameConfigModel
    
    private var words: [WordCard] = []
    private var currentTeamIndex: Int = 0
    private var currentRoundResult: RoundResult?
    private let randomValue: () -> Double
    
    // MARK: - Init
    public init(
        gameConfig: GameConfigModel,
        randomValue: @escaping () -> Double = { Double.random(in: 0..<1) }
    ) {
        self.gameConfig = gameConfig
        self.currentTeam = gameConfig.teams[currentTeamIndex]
        self.timerViewModel = TimerViewModel(initialTime: gameConfig.configuration.roundTimer)
        self.currentChallenge = nil
        self.randomValue = randomValue
        var dict = [UUID: Team]()
        for team in gameConfig.teams {
            dict[team.id] = team
        }
        self.gameInfo = GameInfo(teams: dict)
        setupGame()
        prepareChallenge()
        bind()
    }
    
    // MARK: - Public methods
    func startGame() {
        guard currentState == .preparing else { return }
        startRound()
    }
    
    func prepareForNextRound() {
        currentTeam = gameConfig.teams[currentTeamIndex]
        currentState = .preparing
        prepareChallenge()
    }
    
    func markWordAsGuessed() {
        guard currentState == .playing,
              let currentWord = currentWord,
              let wordIndex = words.firstIndex(where: { $0.id == currentWord.id })
        else { return }
        
        words[wordIndex].isGuessed = true
        currentTeam.roundResult.correctWords.append(words[wordIndex])
        moveToNextWord()
    }
    
    func skipWord() {
        guard currentState == .playing,
              let currentWord = currentWord,
              let wordIndex = words.firstIndex(where: { $0.id == currentWord.id }) else { return }
        
        words[wordIndex].isSkipped = true
        currentTeam.roundResult.skippedWords.append(words[wordIndex])
        
        if gameConfig.configuration.isSkipPenalty {
            currentTeam.roundResult.penalties += 1
        }
        
        moveToNextWord()
    }
    
    func pauseGame() {
        guard currentState == .playing else { return }
        currentState = .paused
        timerViewModel.pause()
    }
    
    func resumeGame() {
        guard currentState == .paused else { return }
        currentState = .playing
        timerViewModel.resume()
    }
    
    // MARK: - Private methods
    private func bind() {
        timerViewModel
            .$isEndTime
            .sink { _ in} receiveValue: { isEndRoundTime in
                if isEndRoundTime {
                    self.isEndRoundTime = isEndRoundTime
                }
        }
            .store(in: &disposables)

    }
    private func setupGame() {
        // Initialize scores for each team
        gameScores = gameConfig.teams.map { GameScore(teamId: $0.id) }
        currentTeam = gameConfig.teams[currentTeamIndex]
        
        // Initialize words from selected category or default
        if let category = gameConfig.words {
            words = GameData.getCurrentCategoryWords(category: category).map { WordCard(word: $0) }
        } else {
            // TODO: Get words from default category
            words = ["тест", "игра", "слово"].map { WordCard(word: $0) }
        }
        words.shuffle()
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
    
    public func startRound() {
        isEndRoundTime = false
        currentState = .playing
        currentTeam = gameConfig.teams[currentTeamIndex]
        
        // Reset and shuffle words
        words.shuffle()
        moveToNextWord()
        
        // Reset and start timer
        timerViewModel.reset()
        timerViewModel.start()
    }
    
    private func moveToNextWord() {
        currentWord = words.first { !$0.isGuessed && !$0.isSkipped }
        
        if isEndRoundTime {
            endRound()
        }
    }
    
    private func endRound() {
        currentState = .roundEnd
        timerViewModel.pause()
        
        if let index = gameScores.firstIndex(where: { $0.teamId == currentTeam.id }) {
            gameScores[index].totalScore += currentTeam.roundResult.score
            gameInfo.teamsMap[currentTeam.id] = currentTeam
            roundResults.append(currentTeam.roundResult)
        }
        
        currentTeamIndex = (currentTeamIndex + 1) % gameConfig.teams.count
        
        gameInfo.currentRound += 1
        if gameInfo.currentRound > gameConfig.teams.count {
            gameInfo.currentRound = 1
            gameInfo.gameNumber = gameInfo.gameNumber == 1 ? 2 : 1
        }
        
        if shouldEndGame() {
            endGame()
        }
    }
    
    private func endGame() {
        currentState = .gameEnd
        GameViewModel.currentGameNumber += 1
    }
    
    private func shouldEndGame() -> Bool {
        return gameScores.contains(where: { $0.totalScore >= gameConfig.configuration.wordsCount })
    }
}

struct Game {
    
}
