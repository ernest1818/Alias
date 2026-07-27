import Foundation

enum GameState {
    case preparing
    case playing
    case paused
    case roundEnd
    case gameEnd
}

public struct WordCard: Identifiable, Equatable {
    public let id: UUID
    public let word: String
    public var isGuessed: Bool
    public var isSkipped: Bool
    
    public init(word: String) {
        self.id = UUID()
        self.word = word
        self.isGuessed = false
        self.isSkipped = false
    }
}

extension WordCard: Hashable {}

public struct RoundResult: Identifiable {
    public let id: UUID
    public var correctWords: [WordCard]
    public var skippedWords: [WordCard]
    public var penalties: Int
    
    public init() {
        self.id = UUID()
        self.correctWords = []
        self.skippedWords = []
        self.penalties = 0
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
    
    init(teamId: UUID) {
        self.id = UUID()
        self.teamId = teamId
        self.totalScore = 0
        self.roundsWon = 0
    }
}

struct GameInfo: Identifiable {
    let id: UUID
    var gameNumber: Int
    var currentRound: Int
    var teamsMap: [UUID : Team]
    
    init(teams: [UUID : Team]) {
        self.id = UUID()
        self.gameNumber = 1
        self.currentRound = 1
        self.teamsMap = teams
    }
} 
