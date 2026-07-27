//
//  SettingsViewModel.swift
//  Alias
//
//  Created by Ernest Avagovich on 16.02.2025.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    private let router = Router.shared
    private let teams: [Team]

    @Published var wordsCount: Double = 60
    @Published var roundTimer: Double = 20
    @Published var isSkipPenalty = false
    @Published var islastWordForAllTeam = false
    @Published var challenge: Challenge = .often
    @Published private(set) var selectedChallenges: Set<GameChallenge> = Set(GameChallenge.allCases)
    @Published var isSoundOn: Bool = true

    let availableChallenges = GameChallenge.allCases
    
    private let defaults = UserDefaults.standard
    private let settingsKey = "game_settings"
    
    struct Settings: Codable {
        var wordsCount: Double
        var roundTimer: Double
        var isSkipPenalty: Bool
        var islastWordForAllTeam: Bool
        var challenge: Challenge
        var selectedChallenges: [GameChallenge]
        var isSoundOn: Bool

        private enum CodingKeys: String, CodingKey {
            case wordsCount
            case roundTimer
            case isSkipPenalty
            case islastWordForAllTeam
            case challenge
            case selectedChallenges
            case challengesList
            case isSoundOn
        }

        init(
            wordsCount: Double,
            roundTimer: Double,
            isSkipPenalty: Bool,
            islastWordForAllTeam: Bool,
            challenge: Challenge,
            selectedChallenges: [GameChallenge],
            isSoundOn: Bool
        ) {
            self.wordsCount = wordsCount
            self.roundTimer = roundTimer
            self.isSkipPenalty = isSkipPenalty
            self.islastWordForAllTeam = islastWordForAllTeam
            self.challenge = challenge
            self.selectedChallenges = selectedChallenges
            self.isSoundOn = isSoundOn
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            wordsCount = try container.decode(Double.self, forKey: .wordsCount)
            roundTimer = try container.decode(Double.self, forKey: .roundTimer)
            isSkipPenalty = try container.decode(Bool.self, forKey: .isSkipPenalty)
            islastWordForAllTeam = try container.decode(Bool.self, forKey: .islastWordForAllTeam)
            challenge = try container.decode(Challenge.self, forKey: .challenge)
            isSoundOn = try container.decode(Bool.self, forKey: .isSoundOn)

            if let savedChallenges = try container.decodeIfPresent(
                [GameChallenge].self,
                forKey: .selectedChallenges
            ) {
                selectedChallenges = savedChallenges
            } else {
                let legacyValues = try container.decodeIfPresent([String].self, forKey: .challengesList) ?? []
                let migratedChallenges = legacyValues.compactMap(GameChallenge.fromLegacyValue)
                selectedChallenges = migratedChallenges.isEmpty ? GameChallenge.allCases : migratedChallenges
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(wordsCount, forKey: .wordsCount)
            try container.encode(roundTimer, forKey: .roundTimer)
            try container.encode(isSkipPenalty, forKey: .isSkipPenalty)
            try container.encode(islastWordForAllTeam, forKey: .islastWordForAllTeam)
            try container.encode(challenge, forKey: .challenge)
            try container.encode(selectedChallenges, forKey: .selectedChallenges)
            try container.encode(isSoundOn, forKey: .isSoundOn)
        }
    }
    
    public init(teams: [Team]) {
        self.teams = teams
        loadSettings()
    }
    
    private func saveSettings() {
        let settings = Settings(
            wordsCount: wordsCount,
            roundTimer: roundTimer,
            isSkipPenalty: isSkipPenalty,
            islastWordForAllTeam: islastWordForAllTeam,
            challenge: challenge,
            selectedChallenges: orderedSelectedChallenges,
            isSoundOn: isSoundOn
        )
        
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: settingsKey)
        }
    }
    
    private func loadSettings() {
        guard let data = defaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(Settings.self, from: data) 
        else { return }
        
        self.wordsCount = settings.wordsCount
        self.roundTimer = settings.roundTimer
        self.isSkipPenalty = settings.isSkipPenalty
        self.islastWordForAllTeam = settings.islastWordForAllTeam
        self.challenge = settings.challenge
        self.selectedChallenges = Set(settings.selectedChallenges)
        self.isSoundOn = settings.isSoundOn
    }

    var canContinue: Bool {
        challenge == .off || !selectedChallenges.isEmpty
    }

    var orderedSelectedChallenges: [GameChallenge] {
        availableChallenges.filter(selectedChallenges.contains)
    }

    func isChallengeSelected(_ challenge: GameChallenge) -> Bool {
        selectedChallenges.contains(challenge)
    }

    func toggleChallenge(_ challenge: GameChallenge) {
        var updatedSelection = selectedChallenges
        if updatedSelection.contains(challenge) {
            updatedSelection.remove(challenge)
        } else {
            updatedSelection.insert(challenge)
        }
        selectedChallenges = updatedSelection
    }

    func selectAllChallenges() {
        selectedChallenges = Set(availableChallenges)
    }

    func clearChallenges() {
        selectedChallenges = []
    }
    
    func showNext() {
        guard canContinue else { return }
        saveSettings()
        let config = Configuration(
            wordsCount: Int(wordsCount),
            roundTimer: Int(roundTimer),
            isSkipPenalty: isSkipPenalty,
            islastWordForAllTeam: islastWordForAllTeam,
            challenges: challenge,
            selectedChallenges: orderedSelectedChallenges,
            isSoundOn: isSoundOn
        )
        
        let gameConfig = GameConfigModel(
            teams: teams,
            configuration: config
        )
        router.add(route: .showCategoryList(gameConfig))
    }
}

public enum Challenge: Double, CaseIterable, Codable {
    case off = 0.0
    case rarely = 1.0
    case often = 2.0
    case always = 3.0
    
    public var title: String {
        switch self {
        case .off: return "Выключено"
        case .rarely: return "Редко"
        case .often: return "Часто"
        case .always: return "Всегда"
        }
    }
    
    public var smile: String {
        switch self {
        case .off: return "😎"
        case .rarely: return "😏"
        case .often: return "😫"
        case .always: return "😤"
        }
    }
    
    static func from(_ value: Double) -> Challenge {
        return Self.allCases.min(by: { abs($0.rawValue - value) < abs($1.rawValue - value) }) ?? .off
    }

    var activationProbability: Double {
        switch self {
        case .off: return 0
        case .rarely: return 0.25
        case .often: return 0.6
        case .always: return 1
        }
    }
}

public struct Configuration: Identifiable {
    public let id = UUID()
    public let wordsCount: Int
    public let roundTimer: Int
    public let isSkipPenalty: Bool
    public let islastWordForAllTeam: Bool
    public let challenges: Challenge
    public let selectedChallenges: [GameChallenge]
    public let isSoundOn: Bool
    
    public init(
        wordsCount: Int,
        roundTimer: Int,
        isSkipPenalty: Bool,
        islastWordForAllTeam: Bool,
        challenges: Challenge,
        selectedChallenges: [GameChallenge],
        isSoundOn: Bool
    ) {
        self.wordsCount = wordsCount
        self.roundTimer = roundTimer
        self.isSkipPenalty = isSkipPenalty
        self.islastWordForAllTeam = islastWordForAllTeam
        self.challenges = challenges
        self.selectedChallenges = selectedChallenges
        self.isSoundOn = isSoundOn
    }
}

extension Configuration: Equatable {}
extension Configuration: Hashable {}
