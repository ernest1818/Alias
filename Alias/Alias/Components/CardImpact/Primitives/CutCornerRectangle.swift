import SwiftUI

struct CutCornerRectangle: InsettableShape {
  var cornerRadius: CGFloat
  var cutSize: CGFloat
  private var insetAmount: CGFloat = 0

  init(cornerRadius: CGFloat = CardImpactRadius.card, cutSize: CGFloat = 18) {
    self.cornerRadius = cornerRadius
    self.cutSize = cutSize
  }

  func path(in rect: CGRect) -> Path {
    let bounds = rect.insetBy(dx: insetAmount, dy: insetAmount)
    guard bounds.width > 0, bounds.height > 0 else { return Path() }

    let radius = min(cornerRadius, min(bounds.width, bounds.height) / 2)
    let cut = min(cutSize, min(bounds.width, bounds.height) / 2)

    var path = Path()
    path.move(to: CGPoint(x: bounds.minX + radius, y: bounds.minY))
    path.addLine(to: CGPoint(x: bounds.maxX - cut, y: bounds.minY))
    path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY + cut))
    path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - radius))
    path.addQuadCurve(
      to: CGPoint(x: bounds.maxX - radius, y: bounds.maxY),
      control: CGPoint(x: bounds.maxX, y: bounds.maxY)
    )
    path.addLine(to: CGPoint(x: bounds.minX + radius, y: bounds.maxY))
    path.addQuadCurve(
      to: CGPoint(x: bounds.minX, y: bounds.maxY - radius),
      control: CGPoint(x: bounds.minX, y: bounds.maxY)
    )
    path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + radius))
    path.addQuadCurve(
      to: CGPoint(x: bounds.minX + radius, y: bounds.minY),
      control: CGPoint(x: bounds.minX, y: bounds.minY)
    )
    path.closeSubpath()
    return path
  }

  func inset(by amount: CGFloat) -> CutCornerRectangle {
    var copy = self
    copy.insetAmount += amount
    return copy
  }
}
