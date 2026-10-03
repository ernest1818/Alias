import Foundation
import SwiftData

enum GameState: Equatable {
    case preparing
    case playing
    case paused
    case resumeCountdown
    case roundEnd
    case gameEnd
}

enum ResumeCountdownStep: Int, Equatable, CaseIterable {
    case three = 3
    case two = 2
    case one = 1
    case started = 0

    var title: String {
        switch self {
        case .three: return "3"
        case .two: return "2"
        case .one: return "1"
        case .started: return "Начали!"
        }
    }
}

public struct WordCard: Identifiable, Equatable {
    public let id: UUID
    public let word: String
    public var isGuessed: Bool
    public var isSkipped: Bool
    
    public init(
        id: UUID = UUID(),
        word: String,
        isGuessed: Bool = false,
        isSkipped: Bool = false
    ) {
        self.id = id
        self.word = word
        self.isGuessed = isGuessed
        self.isSkipped = isSkipped
    }
}

extension WordCard: Hashable {}

public struct RoundResult: Identifiable {
    public let id: UUID
    public var correctWords: [WordCard]
    public var skippedWords: [WordCard]
    public var penalties: Int
    
    public init(
        id: UUID = UUID(),
        correctWords: [WordCard] = [],
        skippedWords: [WordCard] = [],
        penalties: Int = 0
    ) {
        self.id = id
        self.correctWords = correctWords
        self.skippedWords = skippedWords
        self.penalties = penalties
    }
}

extension RoundResult: Equatable {}
extension RoundResult: Hashable {}

extension RoundResult {
    var score: Int {
        max(correctWords.count - penalties, 0)
    }
}

struct GameScore: Identifiable {
    let id: UUID
    let teamId: UUID
    var totalScore: Int
    var roundsWon: Int
    
    init(
        id: UUID = UUID(),
        teamId: UUID,
        totalScore: Int = 0,
        roundsWon: Int = 0
    ) {
        self.id = id
        self.teamId = teamId
        self.totalScore = totalScore
        self.roundsWon = roundsWon
    }
}

struct GameInfo: Identifiable {
    let id: UUID
    var gameNumber: Int
    var currentRound: Int
    var teamsMap: [UUID : Team]
    
    init(
        id: UUID = UUID(),
        gameNumber: Int = 1,
        currentRound: Int = 1,
        teams: [UUID : Team]
    ) {
        self.id = id
        self.gameNumber = gameNumber
        self.currentRound = currentRound
        self.teamsMap = teams
    }
}

enum PersistedGamePhase: String, Codable, Hashable {
    case preparing
    case playing
    case paused
    case roundEnd
}

struct WordCardSnapshot: Codable, Hashable {
    let id: UUID
    let word: String
    let isGuessed: Bool
    let isSkipped: Bool

    init(_ card: WordCard) {
        id = card.id
        word = card.word
        isGuessed = card.isGuessed
        isSkipped = card.isSkipped
    }

    var model: WordCard {
        WordCard(id: id, word: word, isGuessed: isGuessed, isSkipped: isSkipped)
    }
}

struct RoundResultSnapshot: Codable, Hashable {
    let id: UUID
    let correctWords: [WordCardSnapshot]
    let skippedWords: [WordCardSnapshot]
    let penalties: Int

    init(_ result: RoundResult) {
        id = result.id
        correctWords = result.correctWords.map(WordCardSnapshot.init)
        skippedWords = result.skippedWords.map(WordCardSnapshot.init)
        penalties = result.penalties
    }

    var model: RoundResult {
        RoundResult(
            id: id,
            correctWords: correctWords.map(\.model),
            skippedWords: skippedWords.map(\.model),
            penalties: penalties
        )
    }
}

struct TeamSnapshot: Codable, Hashable {
    let id: UUID
    let name: String
    let roundResult: RoundResultSnapshot

    init(_ team: Team) {
        id = team.id
        name = team.name
        roundResult = RoundResultSnapshot(team.roundResult)
    }

    var model: Team {
        Team(id: id, name: name, roundResult: roundResult.model)
    }
}

struct ConfigurationSnapshot: Codable, Hashable {
    let id: UUID
    let wordsCount: Int
    let roundTimer: Int
    let isSkipPenalty: Bool
    let isLastWordForAllTeams: Bool
    let challenges: Challenge
    let selectedChallenges: [GameChallenge]
    let isSoundOn: Bool

    init(_ configuration: Configuration) {
        id = configuration.id
        wordsCount = configuration.wordsCount
        roundTimer = configuration.roundTimer
        isSkipPenalty = configuration.isSkipPenalty
        isLastWordForAllTeams = configuration.islastWordForAllTeam
        challenges = configuration.challenges
        selectedChallenges = configuration.selectedChallenges
        isSoundOn = configuration.isSoundOn
    }

    var model: Configuration {
        Configuration(
            id: id,
            wordsCount: wordsCount,
            roundTimer: roundTimer,
            isSkipPenalty: isSkipPenalty,
            islastWordForAllTeam: isLastWordForAllTeams,
            challenges: challenges,
            selectedChallenges: selectedChallenges,
            isSoundOn: isSoundOn
        )
    }
}

struct GameScoreSnapshot: Codable, Hashable {
    let id: UUID
    let teamID: UUID
    let totalScore: Int
    let roundsWon: Int

    init(_ score: GameScore) {
        id = score.id
        teamID = score.teamId
        totalScore = score.totalScore
        roundsWon = score.roundsWon
    }

    var model: GameScore {
        GameScore(
            id: id,
            teamId: teamID,
            totalScore: totalScore,
            roundsWon: roundsWon
        )
    }
}

struct GameSessionSnapshot: Codable, Hashable {
    static let currentVersion = 1

    let version: Int
    let configuration: ConfigurationSnapshot
    let teams: [TeamSnapshot]
    let category: WordsCategory
    let phase: PersistedGamePhase
    let currentTeamIndex: Int
    let currentTeam: TeamSnapshot
    let gameInfoID: UUID
    let gameNumber: Int
    let currentRound: Int
    let scores: [GameScoreSnapshot]
    let roundResults: [RoundResultSnapshot]
    let orderedWords: [WordCardSnapshot]
    let currentWordID: UUID?
    let currentChallenge: GameChallenge?
    let remainingTime: Int

    init(
        version: Int = currentVersion,
        configuration: ConfigurationSnapshot,
        teams: [TeamSnapshot],
        category: WordsCategory,
        phase: PersistedGamePhase,
        currentTeamIndex: Int,
        currentTeam: TeamSnapshot,
        gameInfoID: UUID,
        gameNumber: Int,
        currentRound: Int,
        scores: [GameScoreSnapshot],
        roundResults: [RoundResultSnapshot],
        orderedWords: [WordCardSnapshot],
        currentWordID: UUID?,
        currentChallenge: GameChallenge?,
        remainingTime: Int
    ) {
        self.version = version
        self.configuration = configuration
        self.teams = teams
        self.category = category
        self.phase = phase
        self.currentTeamIndex = currentTeamIndex
        self.currentTeam = currentTeam
        self.gameInfoID = gameInfoID
        self.gameNumber = gameNumber
        self.currentRound = currentRound
        self.scores = scores
        self.roundResults = roundResults
        self.orderedWords = orderedWords
        self.currentWordID = currentWordID
        self.currentChallenge = currentChallenge
        self.remainingTime = remainingTime
    }

    var gameConfig: GameConfigModel {
        GameConfigModel(
            teams: teams.map(\.model),
            configuration: configuration.model,
            words: category
        )
    }

    var isValid: Bool {
        let teamIDs = teams.map(\.id)
        let wordIDs = Set(orderedWords.map(\.id))

        return version == Self.currentVersion
            && !teams.isEmpty
            && Set(teamIDs).count == teamIDs.count
            && teams.indices.contains(currentTeamIndex)
            && teamIDs.contains(currentTeam.id)
            && scores.allSatisfy { teamIDs.contains($0.teamID) }
            && configuration.roundTimer > 0
            && (0...configuration.roundTimer).contains(remainingTime)
            && currentWordID.map(wordIDs.contains) != false
    }
}

@Model
final class SavedGameRecord {
    static let activeSlot = "active"

    @Attribute(.unique) var slotKey: String
    var schemaVersion: Int
    var updatedAt: Date
    var payload: Data

    init(
        slotKey: String = SavedGameRecord.activeSlot,
        schemaVersion: Int = GameSessionSnapshot.currentVersion,
        updatedAt: Date = Date(),
        payload: Data
    ) {
        self.slotKey = slotKey
        self.schemaVersion = schemaVersion
        self.updatedAt = updatedAt
        self.payload = payload
    }
}

@MainActor
protocol GameSessionStore: AnyObject {
    func loadActive() -> GameSessionSnapshot?
    func saveActive(_ snapshot: GameSessionSnapshot) throws
    func deleteActive() throws
}

@MainActor
final class UnavailableGameSessionStore: GameSessionStore {
    static let shared = UnavailableGameSessionStore()

    private init() {}

    func loadActive() -> GameSessionSnapshot? { nil }
    func saveActive(_ snapshot: GameSessionSnapshot) throws {}
    func deleteActive() throws {}
}

@MainActor
final class SwiftDataGameSessionStore: GameSessionStore {
    private let modelContext: ModelContext
    private let now: () -> Date

    init(modelContext: ModelContext, now: @escaping () -> Date = Date.init) {
        self.modelContext = modelContext
        self.now = now
    }

    func loadActive() -> GameSessionSnapshot? {
        do {
            let records = try activeRecords()
            guard let record = records.max(by: { $0.updatedAt < $1.updatedAt }),
                  record.schemaVersion == GameSessionSnapshot.currentVersion
            else { return nil }

            let snapshot = try JSONDecoder().decode(GameSessionSnapshot.self, from: record.payload)
            return snapshot.isValid ? snapshot : nil
        } catch {
            return nil
        }
    }

    func saveActive(_ snapshot: GameSessionSnapshot) throws {
        guard snapshot.isValid else { throw GameSessionStoreError.invalidSnapshot }

        let payload = try JSONEncoder().encode(snapshot)
        let records = try activeRecords()
        let record: SavedGameRecord

        if let existing = records.max(by: { $0.updatedAt < $1.updatedAt }) {
            record = existing
            record.schemaVersion = snapshot.version
            record.updatedAt = now()
            record.payload = payload
        } else {
            record = SavedGameRecord(updatedAt: now(), payload: payload)
            modelContext.insert(record)
        }

        for duplicate in records where duplicate !== record {
            modelContext.delete(duplicate)
        }
        try modelContext.save()
    }

    func deleteActive() throws {
        for record in try activeRecords() {
            modelContext.delete(record)
        }
        try modelContext.save()
    }

    private func activeRecords() throws -> [SavedGameRecord] {
        try modelContext.fetch(FetchDescriptor<SavedGameRecord>())
            .filter { $0.slotKey == SavedGameRecord.activeSlot }
    }
}

enum GameSessionStoreError: Error {
    case invalidSnapshot
}
