import SwiftUI
import UIKit

enum CardImpactTypeSize {
  static let scoreHero: CGFloat = 88
  static let displayHero: CGFloat = 72
  static let gameWord: CGFloat = 64
  static let minimumGameWord: CGFloat = 40
  static let gameTimer: CGFloat = 56
  static let screenTitle: CGFloat = 40
  static let sectionTitle: CGFloat = 24
  static let actionLabel: CGFloat = 20
  static let bodyEmphasis: CGFloat = 17
  static let body: CGFloat = 17
  static let bodySmall: CGFloat = 15
  static let caption: CGFloat = 13
}

enum CardImpactTypography {
  static let displayPostScriptName = "SofiaSansExtraCondensed-Black"

  static var scoreHero: Font { display(size: CardImpactTypeSize.scoreHero) }
  static var displayHero: Font { display(size: CardImpactTypeSize.displayHero) }
  static var gameWord: Font { display(size: CardImpactTypeSize.gameWord) }
  static var screenTitle: Font { display(size: CardImpactTypeSize.screenTitle) }

  static let gameTimer = Font.system(
    size: CardImpactTypeSize.gameTimer,
    weight: .black,
    design: .default
  )
  .width(.condensed)
  .monospacedDigit()

  static let sectionTitle = Font.system(
    size: CardImpactTypeSize.sectionTitle,
    weight: .bold,
    design: .default
  )
  static let actionLabel = Font.system(
    size: CardImpactTypeSize.actionLabel,
    weight: .bold,
    design: .default
  )
  static let bodyEmphasis = Font.system(
    size: CardImpactTypeSize.bodyEmphasis,
    weight: .semibold,
    design: .default
  )
  static let body = Font.system(
    size: CardImpactTypeSize.body,
    weight: .regular,
    design: .default
  )
  static let bodySmall = Font.system(
    size: CardImpactTypeSize.bodySmall,
    weight: .regular,
    design: .default
  )
  static let caption = Font.system(
    size: CardImpactTypeSize.caption,
    weight: .medium,
    design: .default
  )

  static var isDisplayFontAvailable: Bool {
    UIFont(name: displayPostScriptName, size: CardImpactTypeSize.screenTitle) != nil
  }

  private static func display(size: CGFloat) -> Font {
    guard isDisplayFontAvailable else {
      return .system(size: size, weight: .black, design: .default)
        .width(.condensed)
    }

    return .custom(displayPostScriptName, fixedSize: size)
  }
}
