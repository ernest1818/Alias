import SwiftUI

struct TeamIdentityDisplayModel: Identifiable, Equatable {
  let id: Team.ID
  let name: String
  let style: TeamVisualStyle
}

enum TeamVisualStyle: Int, CaseIterable {
  case violetStripe
  case tealSplitCircle
  case orangeCross
  case pinkDots
  case greenChevron

  var color: Color {
    switch self {
    case .violetStripe: Color(red: 131.0 / 255, green: 101.0 / 255, blue: 1)
    case .tealSplitCircle: Color(red: 35.0 / 255, green: 185.0 / 255, blue: 169.0 / 255)
    case .orangeCross: Color(red: 242.0 / 255, green: 140.0 / 255, blue: 40.0 / 255)
    case .pinkDots: Color(red: 230.0 / 255, green: 83.0 / 255, blue: 138.0 / 255)
    case .greenChevron: Color(red: 114.0 / 255, green: 164.0 / 255, blue: 71.0 / 255)
    }
  }

  var accessibilityName: LocalizedStringKey {
    switch self {
    case .violetStripe: "Фиолетовая диагональная полоса"
    case .tealSplitCircle: "Бирюзовый разделённый круг"
    case .orangeCross: "Оранжевый крест"
    case .pinkDots: "Розовые точки"
    case .greenChevron: "Зелёный шеврон"
    }
  }
}

struct ChallengeDisplayModel: Equatable {
  let title: String
  let instruction: String
  let symbolName: String
}

enum CategoryAvailability: Equatable {
  case available
  case unavailable
}

enum AddTeamSlotState: Equatable {
  case enabled
  case maximum
}
