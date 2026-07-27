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
        Button {
            action()
        } label: {
            VStack {
                Image(systemName: title)
                    .font(.largeTitle)
                    .foregroundColor(color)
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 30)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.indigo.opacity(0.3))
            }
            
        }
        
    }
}
