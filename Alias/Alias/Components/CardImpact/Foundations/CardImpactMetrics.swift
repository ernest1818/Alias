import SwiftUI

enum CardImpactSpacing {
  static let space1: CGFloat = 4
  static let space2: CGFloat = 8
  static let space3: CGFloat = 12
  static let space4: CGFloat = 16
  static let space5: CGFloat = 24
  static let space6: CGFloat = 32
  static let space7: CGFloat = 48
  static let space8: CGFloat = 64

  static let all = [space1, space2, space3, space4, space5, space6, space7, space8]
}

enum CardImpactRadius {
  static let small: CGFloat = 8
  static let medium: CGFloat = 14
  static let action: CGFloat = 18
  static let card: CGFloat = 24

  static let all = [small, medium, action, card]
}

enum CardImpactBorder {
  static let subtle: CGFloat = 1
  static let strong: CGFloat = 2
  static let focus: CGFloat = 3
}

enum CardImpactShadow {
  static let small: CGFloat = 3
  static let action: CGFloat = 5
  static let card: CGFloat = 8
  static let hero: CGFloat = 12
}

enum CardImpactOpacity {
  static let disabledContent = 0.38
  static let pauseScrim = 0.88
}

enum CardImpactSizeProfile: Equatable {
  case compact
  case standard
  case large

  init(width: CGFloat) {
    switch width {
    case ...375: self = .compact
    case 430...: self = .large
    default: self = .standard
    }
  }
}

enum CardImpactLayout {
  static let minimumTouchTarget: CGFloat = 44
  static let setupTouchTarget: CGFloat = 48
  static let maximumContentWidth: CGFloat = 600

  static func screenInset(for width: CGFloat) -> CGFloat {
    switch CardImpactSizeProfile(width: width) {
    case .compact: CardImpactSpacing.space5 - CardImpactSpacing.space1
    case .standard: CardImpactSpacing.space5
    case .large: CardImpactSpacing.space6
    }
  }
}
