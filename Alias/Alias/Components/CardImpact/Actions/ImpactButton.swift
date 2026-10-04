import SwiftUI

enum ImpactButtonRole {
  case primary
  case secondary
  case destructive

  fileprivate var faceColor: Color {
    switch self {
    case .primary: CardImpactColor.actionPrimary
    case .secondary: CardImpactColor.surfacePrimary
    case .destructive: CardImpactColor.danger
    }
  }

  fileprivate var contentColor: Color {
    switch self {
    case .primary: CardImpactColor.textOnDark
    case .secondary, .destructive: CardImpactColor.textOnLight
    }
  }

  fileprivate var shadowColor: Color {
    switch self {
    case .secondary: CardImpactColor.borderStrong
    case .primary, .destructive: CardImpactColor.surfacePrimary
    }
  }

  fileprivate var borderWidth: CGFloat {
    switch self {
    case .primary: 0
    case .secondary, .destructive: CardImpactBorder.strong
    }
  }
}

enum ImpactButtonPresentation {
  case standard
  case stageDoor

  fileprivate var labelFont: Font {
    switch self {
    case .standard:
      CardImpactTypography.actionLabel
    case .stageDoor:
      CardImpactTypography.stageDoorActionLabel
    }
  }

  fileprivate var iconSize: CGFloat {
    switch self {
    case .standard: 24
    case .stageDoor: 28
    }
  }

  fileprivate func minimumHeight(verticalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
    switch self {
    case .standard:
      verticalSizeClass == .compact ? 56 : 60
    case .stageDoor:
      verticalSizeClass == .compact ? 60 : 72
    }
  }
}

struct ImpactButton: View {
  let title: LocalizedStringKey
  let systemImage: String?
  let role: ImpactButtonRole
  let isLoading: Bool
  let presentation: ImpactButtonPresentation
  let action: () -> Void

  @Environment(\.verticalSizeClass) private var verticalSizeClass

  init(
    title: LocalizedStringKey,
    systemImage: String? = nil,
    role: ImpactButtonRole,
    isLoading: Bool = false,
    presentation: ImpactButtonPresentation = .standard,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.systemImage = systemImage
    self.role = role
    self.isLoading = isLoading
    self.presentation = presentation
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      HStack(spacing: CardImpactSpacing.space3) {
        if isLoading {
          ProgressView()
            .progressViewStyle(.circular)
            .tint(role.contentColor)
            .controlSize(.small)
            .accessibilityHidden(true)
        } else if let systemImage {
          Image(systemName: systemImage)
            .font(.system(size: presentation.iconSize, weight: .black))
            .accessibilityHidden(true)
        }

        Text(title)
          .font(presentation.labelFont)
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: .infinity)
    }
    .buttonStyle(
      CardImpactPhysicalButtonStyle(
        shape: CutCornerRectangle(cornerRadius: CardImpactRadius.action, cutSize: 14),
        faceColor: role.faceColor,
        contentColor: role.contentColor,
        shadowColor: role.shadowColor,
        shadowDepth: CardImpactShadow.action,
        borderColor: CardImpactColor.borderStrong,
        borderWidth: role.borderWidth,
        minimumHeight: presentation.minimumHeight(verticalSizeClass: verticalSizeClass),
        horizontalPadding: CardImpactSpacing.space5,
        keepsActiveAppearanceWhenDisabled: isLoading
      )
    )
    .disabled(isLoading)
    .accessibilityValue(isLoading ? Text("Загрузка") : Text(""))
  }
}
