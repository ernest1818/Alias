//
//  Team.swift
//  Alias
//
//  Created by Ernest Avagovich on 12.02.2025.
//

import Foundation

public struct Team: Identifiable {
    public let id = UUID()
    public let name: String
    public var roundResult: RoundResult = .init()
    
    public init(name: String) {
        self.name = name
    }
}

extension Team: Equatable {}
extension Team: Hashable {}
