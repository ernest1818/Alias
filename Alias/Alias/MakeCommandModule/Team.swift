//
//  Team.swift
//  Alias
//
//  Created by Ernest Avagovich on 12.02.2025.
//

import Foundation

public struct Team: Identifiable {
    public let id: UUID
    public let name: String
    public var roundResult: RoundResult = .init()
    
    public init(
        id: UUID = UUID(),
        name: String,
        roundResult: RoundResult = .init()
    ) {
        self.id = id
        self.name = name
        self.roundResult = roundResult
    }
}

extension Team: Equatable {}
extension Team: Hashable {}
