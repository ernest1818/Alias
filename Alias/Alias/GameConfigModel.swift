//
//  GameConfigModel.swift
//  Alias
//
//  Created by Ernest Avagovich on 16.02.2025.
//

import Foundation

public struct GameConfigModel {
    let teams: [Team]
    let configuration: Configuration
    var words: WordsCategory? = nil
}

extension GameConfigModel: Equatable {}
extension GameConfigModel: Hashable {}
