//
//  GameSkipButton.swift
//  Alias
//
//  Created by Ernest Avagovich on 05.04.2025.
//

import Foundation
import SwiftUI

public struct GameSkipButton: View {
    private let action: Action
    private let title: String
    private let color: Color
    
    public init(
        action: @escaping Action,
        title: String,
        color: Color = .green
    ) {
        self.action = action
        self.title = title
        self.color = color
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 72)
        }
        .buttonStyle(PartySecondaryButtonStyle(tint: color))
    }
}
