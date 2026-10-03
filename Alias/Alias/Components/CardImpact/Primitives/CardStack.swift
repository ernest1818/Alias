import SwiftUI

struct CardStackLayer {
  let color: Color
  let offset: CGSize
  let rotation: Angle

  init(color: Color, offset: CGSize, rotation: Angle = .zero) {
    self.color = color
    self.offset = offset
    self.rotation = rotation
  }
}

struct CardStack<StackShape: Shape, Content: View>: View {
  private let shape: StackShape
  private let underlays: [CardStackLayer]
  private let content: Content

  init(
    shape: StackShape,
    underlays: [CardStackLayer],
    @ViewBuilder content: () -> Content
  ) {
    self.shape = shape
    self.underlays = Array(underlays.prefix(2))
    self.content = content()
  }

  var body: some View {
    ZStack {
      ForEach(Array(underlays.enumerated()), id: \.offset) { _, layer in
        shape
          .fill(layer.color)
          .offset(layer.offset)
          .rotationEffect(layer.rotation)
      }

      content
    }
  }
}
