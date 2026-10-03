import SwiftUI

enum ValueStepperKind {
  case targetScore
  case roundDuration

  var title: LocalizedStringKey {
    switch self {
    case .targetScore: "ДО ПОБЕДЫ"
    case .roundDuration: "РАУНД"
    }
  }

  var unit: LocalizedStringKey {
    switch self {
    case .targetScore: "СЛОВ"
    case .roundDuration: "СЕК"
    }
  }

  var accessibilityTitle: String {
    switch self {
    case .targetScore: "Слов до победы"
    case .roundDuration: "Длительность раунда"
    }
  }

  fileprivate var faceColor: Color {
    switch self {
    case .targetScore: CardImpactColor.success
    case .roundDuration: CardImpactColor.danger
    }
  }
}

struct ValueStepperCard: View {
  let kind: ValueStepperKind
  let value: Int
  let range: ClosedRange<Int>
  let step: Int
  let onChange: (Int) -> Void

  init(
    kind: ValueStepperKind,
    value: Int,
    range: ClosedRange<Int>,
    step: Int,
    onChange: @escaping (Int) -> Void
  ) {
    self.kind = kind
    self.value = value
    self.range = range
    self.step = step
    self.onChange = onChange
  }

  var body: some View {
    VStack(spacing: CardImpactSpacing.space2) {
      Text(kind.title)
        .font(CardImpactTypography.sectionTitle)
        .foregroundStyle(CardImpactColor.textOnLight)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)

      VStack(spacing: 0) {
        Text(value, format: .number)
          .font(CardImpactTypography.displayHero)
          .monospacedDigit()
          .lineLimit(1)
          .minimumScaleFactor(0.72)

        Text(kind.unit)
          .font(CardImpactTypography.caption)
          .tracking(1.2)
      }
      .foregroundStyle(CardImpactColor.textOnLight)
      .frame(maxWidth: .infinity, minHeight: 88)
      .background(CardImpactColor.surfacePrimary)
      .clipShape(RoundedRectangle(cornerRadius: CardImpactRadius.small, style: .continuous))
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(kind.accessibilityTitle)
      .accessibilityValue(accessibilityValue)
      .accessibilityAdjustableAction(adjustValue)

      HStack(spacing: CardImpactSpacing.space2) {
        adjustmentButton(
          systemImage: "minus",
          accessibilityLabel: decrementLabel,
          isEnabled: value > range.lowerBound
        ) {
          change(by: -step)
        }

        adjustmentButton(
          systemImage: "plus",
          accessibilityLabel: incrementLabel,
          isEnabled: value < range.upperBound
        ) {
          change(by: step)
        }
      }
    }
    .padding(CardImpactSpacing.space3)
    .frame(maxWidth: .infinity, minHeight: 180, alignment: .top)
    .background(kind.faceColor)
    .clipShape(CutCornerRectangle(cornerRadius: CardImpactRadius.medium, cutSize: 14))
    .overlay {
      CutCornerRectangle(cornerRadius: CardImpactRadius.medium, cutSize: 14)
        .strokeBorder(CardImpactColor.borderStrong, lineWidth: CardImpactBorder.strong)
    }
  }

  private var accessibilityValue: Text {
    Text("\(value), минимум \(range.lowerBound), максимум \(range.upperBound)")
  }

  private var decrementLabel: Text {
    Text("Уменьшить \(kind.accessibilityTitle) на \(step)")
  }

  private var incrementLabel: Text {
    Text("Увеличить \(kind.accessibilityTitle) на \(step)")
  }

  private func adjustmentButton(
    systemImage: String,
    accessibilityLabel: Text,
    isEnabled: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Image(systemName: systemImage)
        .font(.system(size: 22, weight: .black))
        .frame(maxWidth: .infinity, minHeight: CardImpactLayout.setupTouchTarget)
        .accessibilityHidden(true)
    }
    .buttonRepeatBehavior(.enabled)
    .buttonStyle(
      CardImpactPhysicalButtonStyle(
        shape: RoundedRectangle(cornerRadius: CardImpactRadius.small, style: .continuous),
        faceColor: systemImage == "plus" ? CardImpactColor.actionPrimary : CardImpactColor.surfacePrimary,
        contentColor: systemImage == "plus" ? CardImpactColor.textOnDark : CardImpactColor.textOnLight,
        shadowColor: CardImpactColor.borderStrong,
        shadowDepth: CardImpactShadow.small,
        borderColor: CardImpactColor.borderStrong,
        borderWidth: 0,
        minimumHeight: CardImpactLayout.setupTouchTarget,
        horizontalPadding: CardImpactSpacing.space2
      )
    )
    .disabled(!isEnabled)
    .accessibilityLabel(accessibilityLabel)
  }

  private func change(by delta: Int) {
    onChange(Self.clampedValue(value, changingBy: delta, within: range))
  }

  static func clampedValue(
    _ value: Int,
    changingBy delta: Int,
    within range: ClosedRange<Int>
  ) -> Int {
    min(max(value + delta, range.lowerBound), range.upperBound)
  }

  private func adjustValue(_ direction: AccessibilityAdjustmentDirection) {
    switch direction {
    case .increment:
      guard value < range.upperBound else { return }
      change(by: step)
    case .decrement:
      guard value > range.lowerBound else { return }
      change(by: -step)
    @unknown default:
      break
    }
  }
}
