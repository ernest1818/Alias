import SwiftUI

enum CardImpactMotion {
  enum Duration {
    static let instant: TimeInterval = 0.08
    static let press: TimeInterval = 0.12
    static let micro: TimeInterval = 0.16
    static let feedback: TimeInterval = 0.20
    static let transition: TimeInterval = 0.28
    static let cardExit: TimeInterval = 0.22
    static let cardEnter: TimeInterval = 0.16
    static let cardResolution: TimeInterval = cardExit + cardEnter
    static let result: TimeInterval = 0.52
    static let victory: TimeInterval = 0.72
  }

  static func impactOut(reduceMotion: Bool) -> Animation {
    .timingCurve(0.20, 0.80, 0.20, 1.00, duration: Duration.feedback)
  }

  static func exit(reduceMotion: Bool) -> Animation {
    .timingCurve(0.40, 0.00, 1.00, 1.00, duration: Duration.cardExit)
  }

  static func standard(reduceMotion: Bool) -> Animation {
    .timingCurve(0.40, 0.00, 0.20, 1.00, duration: Duration.transition)
  }

  static func returnSpring(reduceMotion: Bool) -> Animation {
    reduceMotion
      ? impactOut(reduceMotion: true)
      : .spring(response: 0.30, dampingFraction: 0.82)
  }

  static func enterSpring(reduceMotion: Bool) -> Animation {
    reduceMotion
      ? impactOut(reduceMotion: true)
      : .spring(response: 0.34, dampingFraction: 0.88)
  }

  static func impactSpring(reduceMotion: Bool) -> Animation {
    reduceMotion
      ? impactOut(reduceMotion: true)
      : .spring(response: 0.28, dampingFraction: 0.72)
  }
}
