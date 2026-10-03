import SwiftUI

struct SettingRow: View {
  let title: String
  let explanation: String?
  @Binding var isOn: Bool

  init(
    title: String,
    explanation: String? = nil,
    isOn: Binding<Bool>
  ) {
    self.title = title
    self.explanation = explanation
    _isOn = isOn
  }

  var body: some View {
    Toggle(isOn: $isOn) {
      VStack(alignment: .leading, spacing: CardImpactSpacing.space1) {
        Text(title)
          .font(CardImpactTypography.bodyEmphasis)
          .foregroundStyle(CardImpactColor.textOnDark)
          .lineLimit(2)
          .fixedSize(horizontal: false, vertical: true)

        if let explanation {
          Text(explanation)
            .font(CardImpactTypography.bodySmall)
            .foregroundStyle(CardImpactColor.textOnDark.opacity(0.72))
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
    }
    .toggleStyle(.switch)
    .tint(CardImpactColor.actionPrimary)
    .padding(.horizontal, CardImpactSpacing.space4)
    .padding(.vertical, CardImpactSpacing.space3)
    .frame(maxWidth: .infinity, minHeight: 56)
    .background(CardImpactColor.backgroundElevated)
    .clipShape(CutCornerRectangle(cornerRadius: CardImpactRadius.small, cutSize: 12))
  }
}
