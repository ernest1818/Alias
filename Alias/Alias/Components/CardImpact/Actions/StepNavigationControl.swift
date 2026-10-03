import SwiftUI

struct StepNavigationControl: View {
  let canGoBack: Bool
  let canGoForward: Bool
  let isForwardLoading: Bool
  let forwardAccessibilityLabel: LocalizedStringKey
  let onBack: () -> Void
  let onForward: () -> Void

  @State private var backFeedbackTrigger = 0
  @State private var forwardFeedbackTrigger = 0

  init(
    canGoBack: Bool,
    canGoForward: Bool,
    isForwardLoading: Bool = false,
    forwardAccessibilityLabel: LocalizedStringKey,
    onBack: @escaping () -> Void,
    onForward: @escaping () -> Void
  ) {
    self.canGoBack = canGoBack
    self.canGoForward = canGoForward
    self.isForwardLoading = isForwardLoading
    self.forwardAccessibilityLabel = forwardAccessibilityLabel
    self.onBack = onBack
    self.onForward = onForward
  }

  var body: some View {
    HStack(alignment: .bottom) {
      navigationButton(
        systemImage: "arrow.left",
        size: 64,
        symbolSize: 28,
        faceColor: CardImpactColor.surfacePrimary,
        contentColor: CardImpactColor.textOnLight,
        shadowDepth: CardImpactShadow.small,
        borderWidth: CardImpactBorder.strong,
        isEnabled: canGoBack,
        isLoading: false,
        accessibilityLabel: Text("Назад")
      ) {
        backFeedbackTrigger += 1
        onBack()
      }
      .sensoryFeedback(.impact(weight: .light), trigger: backFeedbackTrigger)

      Spacer(minLength: CardImpactSpacing.space5)

      navigationButton(
        systemImage: "arrow.right",
        size: 76,
        symbolSize: 32,
        faceColor: CardImpactColor.actionPrimary,
        contentColor: CardImpactColor.textOnDark,
        shadowDepth: CardImpactShadow.action,
        borderWidth: 0,
        isEnabled: canGoForward,
        isLoading: isForwardLoading,
        accessibilityLabel: Text(forwardAccessibilityLabel)
      ) {
        forwardFeedbackTrigger += 1
        onForward()
      }
      .sensoryFeedback(.impact(weight: .medium), trigger: forwardFeedbackTrigger)
    }
    .frame(maxWidth: .infinity)
  }

  private func navigationButton(
    systemImage: String,
    size: CGFloat,
    symbolSize: CGFloat,
    faceColor: Color,
    contentColor: Color,
    shadowDepth: CGFloat,
    borderWidth: CGFloat,
    isEnabled: Bool,
    isLoading: Bool,
    accessibilityLabel: Text,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Group {
        if isLoading {
          ProgressView()
            .progressViewStyle(.circular)
            .tint(contentColor)
            .accessibilityHidden(true)
        } else {
          Image(systemName: systemImage)
            .font(.system(size: symbolSize, weight: .black))
            .accessibilityHidden(true)
        }
      }
      .frame(width: size, height: size)
    }
    .buttonStyle(
      CardImpactPhysicalButtonStyle(
        shape: Circle(),
        faceColor: faceColor,
        contentColor: contentColor,
        shadowColor: CardImpactColor.surfacePrimary,
        shadowDepth: shadowDepth,
        borderColor: CardImpactColor.borderStrong,
        borderWidth: borderWidth,
        minimumHeight: size,
        horizontalPadding: 0,
        keepsActiveAppearanceWhenDisabled: isLoading
      )
    )
    .frame(width: size, height: size + shadowDepth)
    .disabled(!isEnabled || isLoading)
    .accessibilityLabel(accessibilityLabel)
    .accessibilityValue(isLoading ? Text("Загрузка") : Text(""))
  }
}
