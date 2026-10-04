import SwiftUI

enum StatusPanelState: Equatable {
    case loading(message: String)
    case empty(title: String, message: String)
    case recoverableError(title: String, message: String)
    case blockingError(title: String, message: String, isStateSafe: Bool)
}

struct StatusPanel<ActionContent: View>: View {
    let state: StatusPanelState
    private let actions: ActionContent

    init(
        state: StatusPanelState,
        @ViewBuilder actions: () -> ActionContent
    ) {
        self.state = state
        self.actions = actions()
    }

    var body: some View {
        FlatShadowSurface(
            shape: CutCornerRectangle(cornerRadius: CardImpactRadius.medium, cutSize: 14),
            faceColor: CardImpactColor.surfacePrimary,
            shadowOffset: CGSize(width: 0, height: CardImpactShadow.small),
            borderColor: CardImpactColor.borderStrong,
            borderWidth: CardImpactBorder.strong
        ) {
            VStack(alignment: .leading, spacing: CardImpactSpacing.space3) {
                HStack(alignment: .top, spacing: CardImpactSpacing.space3) {
                    statusSymbol
                    VStack(alignment: .leading, spacing: CardImpactSpacing.space1) {
                        Text(title)
                            .font(CardImpactTypography.bodyEmphasis)
                        if !message.isEmpty {
                            Text(message)
                                .font(CardImpactTypography.bodySmall)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                actions
            }
            .foregroundStyle(CardImpactColor.textOnLight)
            .padding(CardImpactSpacing.space4)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var statusSymbol: some View {
        switch state {
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(CardImpactColor.textOnLight)
                .accessibilityLabel("Загрузка")
        case .empty:
            Image(systemName: "tray")
                .foregroundStyle(CardImpactColor.textOnLight.opacity(0.72))
                .accessibilityHidden(true)
        case .recoverableError:
            Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                .foregroundStyle(CardImpactColor.warning)
                .accessibilityHidden(true)
        case .blockingError(_, _, let isStateSafe):
            Image(systemName: isStateSafe ? "lock.shield.fill" : "exclamationmark.octagon.fill")
                .foregroundStyle(isStateSafe ? CardImpactColor.warning : CardImpactColor.danger)
                .accessibilityHidden(true)
        }
    }

    private var title: String {
        switch state {
        case .loading(let message):
            return message
        case .empty(let title, _),
             .recoverableError(let title, _),
             .blockingError(let title, _, _):
            return title
        }
    }

    private var message: String {
        switch state {
        case .loading:
            return ""
        case .empty(_, let message),
             .recoverableError(_, let message),
             .blockingError(_, let message, _):
            return message
        }
    }
}

extension StatusPanel where ActionContent == EmptyView {
    init(state: StatusPanelState) {
        self.init(state: state) { EmptyView() }
    }
}
