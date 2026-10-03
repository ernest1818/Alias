import SwiftUI

struct ChallengeSelectionRow: View {
  let model: ChallengeDisplayModel
  let isSelected: Bool
  let isEnabled: Bool
  let action: () -> Void

  init(
    model: ChallengeDisplayModel,
    isSelected: Bool,
    isEnabled: Bool,
    action: @escaping () -> Void
  ) {
    self.model = model
    self.isSelected = isSelected
    self.isEnabled = isEnabled
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      HStack(spacing: CardImpactSpacing.space3) {
        Image(systemName: model.symbolName)
          .font(.system(size: 24, weight: .bold))
          .frame(width: CardImpactLayout.minimumTouchTarget)
          .accessibilityHidden(true)

        Text(model.title)
          .font(CardImpactTypography.bodyEmphasis)
          .lineLimit(2)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, alignment: .leading)

        checkbox
      }
      .frame(maxWidth: .infinity, minHeight: 56)
    }
    .buttonStyle(
      CardImpactPhysicalButtonStyle(
        shape: CutCornerRectangle(cornerRadius: CardImpactRadius.small, cutSize: 12),
        faceColor: CardImpactColor.backgroundElevated,
        contentColor: CardImpactColor.textOnDark,
        shadowColor: CardImpactColor.surfacePrimary,
        shadowDepth: CardImpactShadow.small,
        borderColor: isSelected ? CardImpactColor.actionPrimary : CardImpactColor.surfacePrimary.opacity(0.18),
        borderWidth: isSelected ? CardImpactBorder.strong : CardImpactBorder.subtle,
        minimumHeight: 56,
        horizontalPadding: CardImpactSpacing.space3
      )
    )
    .disabled(!isEnabled)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(model.title)
    .accessibilityValue(isSelected ? "Выбрано" : "Не выбрано")
    .accessibilityHint(model.instruction)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }

  private var checkbox: some View {
    RoundedRectangle(cornerRadius: CardImpactSpacing.space1, style: .continuous)
      .fill(isSelected ? CardImpactColor.actionPrimary : Color.clear)
      .overlay {
        RoundedRectangle(cornerRadius: CardImpactSpacing.space1, style: .continuous)
          .strokeBorder(
            isSelected ? CardImpactColor.actionPrimary : CardImpactColor.surfacePrimary,
            lineWidth: CardImpactBorder.strong
          )
      }
      .overlay {
        if isSelected {
          Image(systemName: "checkmark")
            .font(.system(size: 17, weight: .black))
            .foregroundStyle(CardImpactColor.textOnDark)
        }
      }
      .frame(width: 32, height: 32)
      .accessibilityHidden(true)
  }
}
