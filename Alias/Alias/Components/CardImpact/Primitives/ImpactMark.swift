import SwiftUI

enum ImpactMarkKind {
  case burst
  case speed
  case snap
}

struct ImpactMark: View {
  let kind: ImpactMarkKind
  let color: Color
  var lineWidth: CGFloat = CardImpactBorder.strong

  var body: some View {
    Canvas { context, size in
      switch kind {
      case .burst:
        drawBurst(in: &context, size: size)
      case .speed:
        drawSpeed(in: &context, size: size)
      case .snap:
        drawSnap(in: &context, size: size)
      }
    }
    .accessibilityHidden(true)
  }

  private func drawBurst(in context: inout GraphicsContext, size: CGSize) {
    let center = CGPoint(x: size.width / 2, y: size.height / 2)
    let rays: [(CGPoint, CGPoint)] = [
      (
        CGPoint(x: size.width * 0.08, y: size.height * 0.18),
        CGPoint(x: size.width * 0.36, y: size.height * 0.42)
      ),
      (CGPoint(x: size.width * 0.50, y: 0), CGPoint(x: size.width * 0.50, y: size.height * 0.34)),
      (
        CGPoint(x: size.width * 0.92, y: size.height * 0.18),
        CGPoint(x: size.width * 0.64, y: size.height * 0.42)
      ),
    ]
    var path = Path()
    for ray in rays {
      path.move(to: ray.0)
      path.addLine(to: ray.1)
    }
    context.stroke(
      path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    context.fill(
      Path(ellipseIn: CGRect(x: center.x - 2, y: center.y - 2, width: 4, height: 4)),
      with: .color(color))
  }

  private func drawSpeed(in context: inout GraphicsContext, size: CGSize) {
    var path = Path()
    path.move(to: CGPoint(x: 0, y: size.height * 0.34))
    path.addLine(to: CGPoint(x: size.width, y: size.height * 0.20))
    path.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.76))
    path.addLine(to: CGPoint(x: size.width, y: size.height * 0.62))
    context.stroke(
      path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
  }

  private func drawSnap(in context: inout GraphicsContext, size: CGSize) {
    var left = Path()
    left.move(to: CGPoint(x: 0, y: size.height * 0.50))
    left.addLine(to: CGPoint(x: size.width * 0.38, y: size.height * 0.24))
    left.addLine(to: CGPoint(x: size.width * 0.34, y: size.height * 0.64))
    left.closeSubpath()

    var right = Path()
    right.move(to: CGPoint(x: size.width, y: size.height * 0.50))
    right.addLine(to: CGPoint(x: size.width * 0.62, y: size.height * 0.24))
    right.addLine(to: CGPoint(x: size.width * 0.66, y: size.height * 0.64))
    right.closeSubpath()

    context.fill(left, with: .color(color))
    context.fill(right, with: .color(color))
  }
}
