//
//  AliasButton.swift
//  Alias
//
//  Created by Ernest Avagovich on 12.02.2025.
//

import Foundation
import SwiftUI

public typealias Action = () -> Void

public struct AliasButton: View {
    private let action: Action
    private let title: String
    
    public init(action: @escaping Action, title: String) {
        self.action = action
        self.title = title
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.superCrownXL)
                .frame(width: UIScreen.main.bounds.width - 130)
                .foregroundColor(.white)
                .padding(.vertical, 20)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 6)
                .background(
                    ZStack {
                        Color.greenButtonBackground
                        Group {
                            Color(.greenRight)
                                .overlay(content: {
                                    Rectangle()
                                        .fill(Color(.greenLeft))
                                        .rotationEffect(.degrees(55))
                                        .frame(width: 200, height: 200)
                                        .offset(x: -90, y: 40)
                                })
                                .clipShape(RoundedRectangle(cornerRadius: 50))
                        }
                        .offset(y: -10)
                    }
                    
                )
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.white, lineWidth: 4)
                )
                
        }
    }
}

#Preview {
    AliasButton(action: {}, title: "Play")
}
