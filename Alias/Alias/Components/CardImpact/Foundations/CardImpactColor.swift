import SwiftUI

enum CardImpactPaletteToken: CaseIterable {
  case ink900
  case ink800
  case bone50
  case bone100
  case cobalt500
  case chartreuse500
  case vermilion500
  case amber500

  var hex: String {
    switch self {
    case .ink900: "121319"
    case .ink800: "20222B"
    case .bone50: "F4EFE6"
    case .bone100: "E7E0D6"
    case .cobalt500: "3157FF"
    case .chartreuse500: "C7F000"
    case .vermilion500: "FF4D2E"
    case .amber500: "FFB11B"
    }
  }

  var color: Color {
    let value = UInt64(hex, radix: 16) ?? 0
    return Color(
      .sRGB,
      red: Double((value >> 16) & 0xFF) / 255,
      green: Double((value >> 8) & 0xFF) / 255,
      blue: Double(value & 0xFF) / 255,
      opacity: 1
    )
  }
}

enum CardImpactColor {
  static let backgroundPrimary = CardImpactPaletteToken.ink900.color
  static let backgroundElevated = CardImpactPaletteToken.ink800.color
  static let surfacePrimary = CardImpactPaletteToken.bone50.color
  static let surfaceMuted = CardImpactPaletteToken.bone100.color
  static let textOnDark = CardImpactPaletteToken.bone50.color
  static let textOnLight = CardImpactPaletteToken.ink900.color
  static let actionPrimary = CardImpactPaletteToken.cobalt500.color
  static let success = CardImpactPaletteToken.chartreuse500.color
  static let danger = CardImpactPaletteToken.vermilion500.color
  static let warning = CardImpactPaletteToken.amber500.color
  static let borderStrong = CardImpactPaletteToken.ink900.color
}
