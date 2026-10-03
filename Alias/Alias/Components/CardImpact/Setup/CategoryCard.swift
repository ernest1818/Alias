import SwiftUI

struct CategoryCard: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  let title: String
  let descriptor: String?
  let isSelected: Bool
  let availability: CategoryAvailability
  let action: () -> Void

  init(
    title: String,
    descriptor: String? = nil,
    isSelected: Bool,
    availability: CategoryAvailability,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.descriptor = descriptor
    self.isSelected = isSelected
    self.availability = availability
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      Group {
        if dynamicTypeSize.isAccessibilitySize {
          VStack(alignment: .leading, spacing: CardImpactSpacing.space3) {
            categoryCopy
            stateIndicator
          }
        } else {
          HStack(spacing: CardImpactSpacing.space3) {
            categoryCopy
            stateIndicator
          }
        }
      }
      .frame(maxWidth: .infinity, minHeight: 96)
    }
    .buttonStyle(
      CardImpactPhysicalButtonStyle(
        shape: CutCornerRectangle(cornerRadius: CardImpactRadius.medium, cutSize: 14),
        faceColor: isSelected ? CardImpactColor.success : CardImpactColor.surfacePrimary,
        contentColor: CardImpactColor.textOnLight,
        shadowColor: CardImpactColor.surfacePrimary,
        shadowDepth: CardImpactShadow.small,
        borderColor: isSelected ? CardImpactColor.success : CardImpactColor.borderStrong,
        borderWidth: isSelected ? CardImpactBorder.focus : CardImpactBorder.strong,
        minimumHeight: 96,
        horizontalPadding: CardImpactSpacing.space4
      )
    )
    .disabled(availability == .unavailable)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(title)
    .accessibilityValue(accessibilityValue)
    .accessibilityHint(descriptor ?? "")
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }

  private var categoryCopy: some View {
    VStack(alignment: .leading, spacing: CardImpactSpacing.space1) {
      Text(title.uppercased())
        .font(categoryTitleFont)
        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
        .minimumScaleFactor(0.86)
        .fixedSize(horizontal: false, vertical: true)

      if let descriptor {
        Text(descriptor)
          .font(CardImpactTypography.bodySmall)
          .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var categoryTitleFont: Font {
    guard CardImpactTypography.isDisplayFontAvailable else {
      return .system(size: 28, weight: .black, design: .default).width(.condensed)
    }
    return .custom(CardImpactTypography.displayPostScriptName, size: 28, relativeTo: .title2)
  }

  @ViewBuilder
  private var stateIndicator: some View {
    switch availability {
    case .unavailable:
      Text("НЕТ\nСЛОВ")
        .font(CardImpactTypography.caption)
        .multilineTextAlignment(.center)
        .accessibilityHidden(true)
    case .available where isSelected:
      VStack(spacing: CardImpactSpacing.space1) {
        Image(systemName: "checkmark")
          .font(.system(size: 22, weight: .black))
        Text("ВЫБРАНО")
          .font(CardImpactTypography.caption)
      }
      .accessibilityHidden(true)
    case .available:
      EmptyView()
    }
  }

  private var accessibilityValue: String {
    switch availability {
    case .unavailable: "Нет слов, недоступно"
    case .available where isSelected: "Выбрано"
    case .available: "Не выбрано"
    }
  }
}
