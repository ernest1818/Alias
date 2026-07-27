//
//  GradientBackgraund+Modifier.swift
//  Alias
//
//  Created by Ernest Avagovich on 13.04.2025.
//

import SwiftUI

public struct GradientBackground: ViewModifier {
    
    let gradient: GradientState
    
    public init(gradient: GradientState) {
        self.gradient = gradient
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            switch gradient {
            case .linear:
                LinearGradient(gradient: Gradient(colors: [.backGroundColor2, .backGroundColor1]),
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
            case .radial:
                RadialGradient(
                    gradient: Gradient(colors: [.backGroundColor2, .backGroundColor1]),
                    center: .center,
                    startRadius: 40,
                    endRadius: 100
                )
                .ignoresSafeArea()
            }
            content
        }
    }
}

public extension View {
    func gradientBackground(gradient: GradientState = .linear) -> some View {
        self.modifier(GradientBackground(gradient: gradient))
    }
}

public enum GradientState {
    case linear
    case radial
}
