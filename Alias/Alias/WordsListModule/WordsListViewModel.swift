//
//  WordsListViewModel.swift
//  Alias
//
//  Created by Ernest Avagovich on 16.02.2025.
//

import Foundation
import SwiftUI

@MainActor
final class WordsListViewModel: ObservableObject {
    @Published var wordsList: [WordsCategory] = WordsCategory.allCases
    
    private let router = Router.shared
    private var gameConfig: GameConfigModel
    
    public init(gameConfig: GameConfigModel) {
        self.gameConfig = gameConfig
    }

    func showStartGame(_ words: WordsCategory) {
        gameConfig.words = words
        router.add(route: .showStartGame(gameConfig))
    }
}

public enum WordsCategory: String, CaseIterable, Codable, Identifiable, Hashable {
    public var id: String { rawValue }
    case light
    case optimise
    case forFamily
    case random
    case heavy
    
    public var title: String {
        switch self {
        case .light:
            "Легкое начинание"
        case .optimise:
            "Комфортные знания"
        case .forFamily:
            "Для всей семьи"
        case .random:
            "Все возможные уровни"
        case .heavy:
            "Мозголомка"
        }
    }
    
    public var partyAccent: Color {
        switch self {
        case .light:
            return .partyCoral
        case .optimise:
            return .partyYellow
        case .forFamily:
            return .partyLime
        case .random:
            return .partyInfo
        case .heavy:
            return .partyDanger
        }
    }
}
