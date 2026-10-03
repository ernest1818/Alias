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
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(PartyPrimaryButtonStyle())
        .frame(maxWidth: PartyLayout.maximumContentWidth)
    }
}

#if DEBUG
    #Preview {
        AliasButton(action: {}, title: "Play")
    }
#endif
