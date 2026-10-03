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
            background
                .ignoresSafeArea()

            content
        }
        .foregroundStyle(Color.partyPrimaryText)
        .tint(Color.partyPrimaryAction)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var background: some View {
        ZStack {
            Color.partyBackground

            if #available(iOS 18.0, *) {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: meshPoints,
                    colors: meshColors,
                    background: Color.partyBackground,
                    smoothsColors: true
                )
            } else {
                legacyGradient
            }
        }
    }

    private var meshPoints: [SIMD2<Float>] {
        let center: SIMD2<Float> = gradient == .radial
            ? .init(0.5, 0.42)
            : .init(0.62, 0.46)

        return [
            .init(0, 0), .init(0.46, 0), .init(1, 0),
            .init(0, 0.48), center, .init(1, 0.56),
            .init(0, 1), .init(0.42, 1), .init(1, 1)
        ]
    }

    private var meshColors: [Color] {
        [
            .partyBackground, .partyInfo.opacity(0.82), .partyElevated,
            .partyInfo.opacity(0.5), .partyBackground, .partyElevated,
            .partyBackground, .partyPrimaryAction.opacity(0.62), .partyBackground
        ]
    }

    @ViewBuilder
    private var legacyGradient: some View {
        if gradient == .radial {
            RadialGradient(
                colors: [
                    .partyInfo.opacity(0.66),
                    .partyBackground,
                    .partyPrimaryAction.opacity(0.28)
                ],
                center: .top,
                startRadius: 20,
                endRadius: 700
            )
        } else {
            LinearGradient(
                colors: [
                    .partyInfo.opacity(0.58),
                    .partyBackground,
                    .partyPrimaryAction.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

public extension View {
    func gradientBackground(gradient: GradientState = .linear) -> some View {
        self.modifier(GradientBackground(gradient: gradient))
    }
}

public enum GradientState: Equatable {
    case linear
    case radial
}
