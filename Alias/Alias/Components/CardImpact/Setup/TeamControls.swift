import SwiftUI

struct TeamCard: View {
  let team: TeamIdentityDisplayModel
  let canRemove: Bool
  let onRemove: () -> Void

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  init(
    team: TeamIdentityDisplayModel,
    canRemove: Bool,
    onRemove: @escaping () -> Void
  ) {
    self.team = team
    self.canRemove = canRemove
    self.onRemove = onRemove
  }

  var body: some View {
    Group {
      if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading, spacing: CardImpactSpacing.space3) {
          identity
          if canRemove { removeButton.frame(maxWidth: .infinity, alignment: .trailing) }
        }
      } else {
        HStack(spacing: CardImpactSpacing.space4) {
          identity
          if canRemove { removeButton }
        }
      }
    }
    .padding(CardImpactSpacing.space4)
    .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
    .background(team.style.color)
    .clipShape(CutCornerRectangle(cornerRadius: CardImpactRadius.medium, cutSize: 14))
    .overlay {
      CutCornerRectangle(cornerRadius: CardImpactRadius.medium, cutSize: 14)
        .strokeBorder(CardImpactColor.borderStrong, lineWidth: CardImpactBorder.strong)
    }
  }

  private var identity: some View {
    HStack(spacing: CardImpactSpacing.space4) {
      TeamMarker(style: team.style)
        .frame(width: 48, height: 48)
        .accessibilityHidden(true)

      Text(team.name.uppercased())
        .font(teamNameFont)
        .foregroundStyle(CardImpactColor.textOnLight)
        .lineLimit(2)
        .minimumScaleFactor(0.8)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Команда \(team.name)")
    .accessibilityValue(Text(team.style.accessibilityName))
  }

  private var removeButton: some View {
    Button(action: onRemove) {
      Image(systemName: "trash.fill")
        .font(.system(size: 18, weight: .bold))
        .frame(width: CardImpactLayout.setupTouchTarget, height: CardImpactLayout.setupTouchTarget)
        .accessibilityHidden(true)
    }
    .buttonStyle(
      CardImpactPhysicalButtonStyle(
        shape: Circle(),
        faceColor: CardImpactColor.danger,
        contentColor: CardImpactColor.textOnLight,
        shadowColor: CardImpactColor.borderStrong,
        shadowDepth: CardImpactShadow.small,
        borderColor: CardImpactColor.borderStrong,
        borderWidth: CardImpactBorder.strong,
        minimumHeight: CardImpactLayout.setupTouchTarget,
        horizontalPadding: 0
      )
    )
    .frame(width: CardImpactLayout.setupTouchTarget, height: CardImpactLayout.setupTouchTarget + CardImpactShadow.small)
    .accessibilityLabel("Удалить команду \(team.name)")
  }

  private var teamNameFont: Font {
    guard CardImpactTypography.isDisplayFontAvailable else {
      return .system(size: 40, weight: .black, design: .default).width(.condensed)
    }
    return .custom(CardImpactTypography.displayPostScriptName, size: 40, relativeTo: .title)
  }
}

struct AddTeamSlot: View {
  let state: AddTeamSlotState
  let action: () -> Void

  init(state: AddTeamSlotState, action: @escaping () -> Void) {
    self.state = state
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      HStack(spacing: CardImpactSpacing.space3) {
        Image(systemName: state == .enabled ? "plus" : "person.3.fill")
          .font(.system(size: 24, weight: .bold))
          .accessibilityHidden(true)

        Text(state == .enabled ? "ДОБАВИТЬ КОМАНДУ" : "МАКСИМУМ 5 КОМАНД")
          .font(CardImpactTypography.bodyEmphasis)
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .fixedSize(horizontal: false, vertical: true)
      }
      .foregroundStyle(
        state == .enabled
          ? CardImpactColor.textOnDark
          : CardImpactColor.textOnLight.opacity(CardImpactOpacity.disabledContent)
      )
      .padding(.horizontal, CardImpactSpacing.space4)
      .frame(maxWidth: .infinity, minHeight: 72)
      .background(state == .enabled ? Color.clear : CardImpactColor.surfaceMuted)
      .clipShape(CutCornerRectangle(cornerRadius: CardImpactRadius.medium, cutSize: 14))
      .overlay {
        CutCornerRectangle(cornerRadius: CardImpactRadius.medium, cutSize: 14)
          .stroke(
            state == .enabled ? CardImpactColor.surfacePrimary : CardImpactColor.borderStrong.opacity(0.38),
            style: StrokeStyle(
              lineWidth: CardImpactBorder.strong,
              dash: state == .enabled ? [8, 6] : []
            )
          )
      }
    }
    .buttonStyle(CardImpactOffsetPressButtonStyle())
    .disabled(state == .maximum)
    .accessibilityLabel(state == .enabled ? "Добавить команду" : "Максимум пять команд")
  }
}

private struct CardImpactOffsetPressButtonStyle: ButtonStyle {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  func makeBody(configuration: ButtonStyleConfiguration) -> some View {
    configuration.label
      .offset(y: configuration.isPressed ? CardImpactSpacing.space1 : 0)
      .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
      .animation(
        Animation.easeOut(duration: reduceMotion ? 0 : CardImpactMotion.Duration.press),
        value: configuration.isPressed
      )
  }
}

private struct TeamMarker: View {
  let style: TeamVisualStyle

  var body: some View {
    Canvas { context, size in
      let ink = GraphicsContext.Shading.color(CardImpactColor.textOnLight)
      let width = size.width
      let height = size.height

      switch style {
      case .violetStripe:
        var path = Path()
        path.move(to: CGPoint(x: width * 0.14, y: height * 0.78))
        path.addLine(to: CGPoint(x: width * 0.72, y: height * 0.14))
        path.addLine(to: CGPoint(x: width * 0.88, y: height * 0.28))
        path.addLine(to: CGPoint(x: width * 0.30, y: height * 0.92))
        path.closeSubpath()
        context.fill(path, with: ink)

      case .tealSplitCircle:
        let circle = CGRect(x: width * 0.12, y: height * 0.12, width: width * 0.76, height: height * 0.76)
        context.stroke(Path(ellipseIn: circle), with: ink, lineWidth: 5)
        var divider = Path()
        divider.move(to: CGPoint(x: width * 0.24, y: height * 0.76))
        divider.addLine(to: CGPoint(x: width * 0.76, y: height * 0.24))
        context.stroke(divider, with: ink, style: StrokeStyle(lineWidth: 5, lineCap: .round))

      case .orangeCross:
        var path = Path()
        path.move(to: CGPoint(x: width * 0.22, y: height * 0.12))
        path.addLine(to: CGPoint(x: width * 0.88, y: height * 0.78))
        path.move(to: CGPoint(x: width * 0.88, y: height * 0.12))
        path.addLine(to: CGPoint(x: width * 0.22, y: height * 0.78))
        context.stroke(path, with: ink, style: StrokeStyle(lineWidth: 7, lineCap: .round))

      case .pinkDots:
        context.fill(
          Path(ellipseIn: CGRect(x: width * 0.08, y: height * 0.24, width: width * 0.34, height: height * 0.34)),
          with: ink
        )
        context.fill(
          Path(ellipseIn: CGRect(x: width * 0.58, y: height * 0.42, width: width * 0.34, height: height * 0.34)),
          with: ink
        )

      case .greenChevron:
        var path = Path()
        path.move(to: CGPoint(x: width * 0.12, y: height * 0.26))
        path.addLine(to: CGPoint(x: width * 0.50, y: height * 0.68))
        path.addLine(to: CGPoint(x: width * 0.88, y: height * 0.26))
        context.stroke(path, with: ink, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
      }
    }
  }
}
