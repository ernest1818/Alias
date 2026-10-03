import SwiftUI

struct SetupHeader: View {
  let title: String
  let step: Int
  let totalSteps: Int

  init(title: String, step: Int, totalSteps: Int = 3) {
    self.title = title
    self.step = step
    self.totalSteps = totalSteps
  }

  var body: some View {
    VStack(spacing: CardImpactSpacing.space2) {
      Text(title.uppercased())
        .font(CardImpactTypography.screenTitle)
        .foregroundStyle(CardImpactColor.textOnLight)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.8)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, CardImpactSpacing.space5)
        .padding(.vertical, CardImpactSpacing.space3)
        .frame(maxWidth: .infinity)
        .background(CardImpactColor.surfacePrimary)
        .clipShape(CutCornerRectangle(cornerRadius: CardImpactRadius.medium, cutSize: 14))
        .overlay {
          CutCornerRectangle(cornerRadius: CardImpactRadius.medium, cutSize: 14)
            .strokeBorder(CardImpactColor.borderStrong, lineWidth: CardImpactBorder.strong)
        }
        .rotationEffect(.degrees(-1))

      Text("ШАГ \(step) ИЗ \(totalSteps)")
        .font(CardImpactTypography.caption)
        .tracking(1.2)
        .foregroundStyle(CardImpactColor.textOnDark)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(title), шаг \(step) из \(totalSteps)")
  }
}
