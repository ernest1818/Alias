import SwiftUI

struct FrequencyPicker: View {
  @Binding var selection: Challenge

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  init(selection: Binding<Challenge>) {
    _selection = selection
  }

  var body: some View {
    Group {
      if dynamicTypeSize.isAccessibilitySize {
        VStack(spacing: CardImpactSpacing.space2) {
          ForEach(Challenge.allCases, id: \.self) { option in
            optionButton(option, isVertical: true)
          }
        }
      } else {
        HStack(spacing: CardImpactBorder.subtle) {
          ForEach(Challenge.allCases, id: \.self) { option in
            optionButton(option, isVertical: false)
          }
        }
        .padding(CardImpactBorder.strong)
        .background(CardImpactColor.borderStrong)
        .clipShape(CutCornerRectangle(cornerRadius: CardImpactRadius.small, cutSize: 12))
      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Частота появления заданий")
  }

  private func optionButton(_ option: Challenge, isVertical: Bool) -> some View {
    let isSelected = selection == option

    return Button {
      selection = option
    } label: {
      HStack(spacing: CardImpactSpacing.space1) {
        if isSelected {
          Image(systemName: "checkmark")
            .font(.caption.bold())
            .accessibilityHidden(true)
        }

        Text(option.cardImpactTitle)
          .font(CardImpactTypography.caption)
          .tracking(0.4)
          .lineLimit(1)

        if isVertical {
          Spacer(minLength: 0)
        }
      }
      .frame(maxWidth: .infinity, minHeight: isVertical ? 56 : 48)
      .padding(.horizontal, isVertical ? CardImpactSpacing.space4 : CardImpactSpacing.space1)
      .foregroundStyle(isSelected ? CardImpactColor.textOnDark : CardImpactColor.textOnLight)
      .background(isSelected ? CardImpactColor.actionPrimary : CardImpactColor.surfacePrimary)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .clipShape(
      CutCornerRectangle(
        cornerRadius: isVertical ? CardImpactRadius.small : 0,
        cutSize: isVertical ? 12 : 0
      )
    )
    .overlay {
      if isVertical {
        CutCornerRectangle(cornerRadius: CardImpactRadius.small, cutSize: 12)
          .strokeBorder(CardImpactColor.borderStrong, lineWidth: CardImpactBorder.strong)
      }
    }
    .accessibilityLabel(option.title)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

extension Challenge {
  var cardImpactTitle: String {
    switch self {
    case .off: "ВЫКЛ"
    case .rarely: "РЕДКО"
    case .often: "ЧАСТО"
    case .always: "ВСЕГДА"
    }
  }
}
