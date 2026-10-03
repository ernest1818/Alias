import SwiftUI

struct FlatShadowSurface<SurfaceShape: Shape, Content: View>: View {
  private let shape: SurfaceShape
  private let faceColor: Color
  private let shadowColor: Color
  private let shadowOffset: CGSize
  private let borderColor: Color
  private let borderWidth: CGFloat
  private let content: Content

  init(
    shape: SurfaceShape,
    faceColor: Color,
    shadowColor: Color = CardImpactColor.borderStrong,
    shadowOffset: CGSize,
    borderColor: Color = .clear,
    borderWidth: CGFloat = 0,
    @ViewBuilder content: () -> Content
  ) {
    self.shape = shape
    self.faceColor = faceColor
    self.shadowColor = shadowColor
    self.shadowOffset = shadowOffset
    self.borderColor = borderColor
    self.borderWidth = borderWidth
    self.content = content()
  }

  var body: some View {
    ZStack {
      shape
        .fill(shadowColor)
        .offset(shadowOffset)

      shape.fill(faceColor)

      if borderWidth > 0 {
        shape.stroke(borderColor, lineWidth: borderWidth)
      }

      content
    }
  }
}
