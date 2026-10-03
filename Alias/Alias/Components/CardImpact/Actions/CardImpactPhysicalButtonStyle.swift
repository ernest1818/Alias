import SwiftUI

struct CardImpactPhysicalButtonStyle<ButtonShape: InsettableShape>: ButtonStyle {
  let shape: ButtonShape
  let faceColor: Color
  let contentColor: Color
  let shadowColor: Color
  let shadowDepth: CGFloat
  let borderColor: Color
  let borderWidth: CGFloat
  let minimumHeight: CGFloat
  let horizontalPadding: CGFloat
  var keepsActiveAppearanceWhenDisabled = false

  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.isFocused) private var isFocused

  func makeBody(configuration: ButtonStyleConfiguration) -> some View {
    let usesActiveAppearance = isEnabled || keepsActiveAppearanceWhenDisabled
    let isPressed = configuration.isPressed && isEnabled
    let currentShadowDepth = isPressed ? CardImpactSpacing.space1 / 4 : shadowDepth

    ZStack {
      if usesActiveAppearance {
        shape
          .fill(shadowColor)
          .offset(y: currentShadowDepth)
      }

      shape
        .fill(usesActiveAppearance ? faceColor : CardImpactColor.surfaceMuted)

      if borderWidth > 0 {
        shape
          .strokeBorder(
            usesActiveAppearance ? borderColor : CardImpactColor.borderStrong.opacity(0.38),
            lineWidth: borderWidth
          )
      }

      configuration.label
        .foregroundStyle(
          usesActiveAppearance
            ? contentColor
            : CardImpactColor.textOnLight.opacity(CardImpactOpacity.disabledContent)
        )
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, CardImpactSpacing.space2)
    }
    .frame(minHeight: minimumHeight)
    .fixedSize(horizontal: false, vertical: true)
    .contentShape(shape)
    .overlay {
      if isFocused {
        shape
          .strokeBorder(CardImpactColor.actionPrimary, lineWidth: CardImpactBorder.focus)
          .padding(-CardImpactSpacing.space1)
          .accessibilityHidden(true)
      }
    }
    .offset(y: isPressed ? max(0, shadowDepth - 1) : 0)
    .scaleEffect(isPressed && !reduceMotion ? 0.985 : 1)
    .animation(
      Animation.easeOut(duration: reduceMotion ? 0 : CardImpactMotion.Duration.press),
      value: isPressed
    )
  }
}
