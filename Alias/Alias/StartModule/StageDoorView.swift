import SwiftUI

struct StageDoorView: View {
    @ObservedObject var viewModel: StageDoorViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var isShowingRules = false
    @State private var isShowingReplacementConfirmation = false
    @State private var didEnter = false

    init(viewModel: StageDoorViewModel, startsEntered: Bool = false) {
        self.viewModel = viewModel
        _didEnter = State(initialValue: startsEntered)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let inset = CardImpactLayout.screenInset(for: size.width)

            Group {
                if size.width > size.height {
                    landscapeLayout(size: size, inset: inset)
                } else {
                    portraitLayout(size: size, inset: inset)
                }
            }
            .frame(width: size.width, height: size.height)
        }
        .background(CardImpactColor.backgroundPrimary.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isShowingRules) {
            RulesSheet()
        }
        .confirmationDialog(
            "НАЧАТЬ НОВУЮ ИГРУ?",
            isPresented: $isShowingReplacementConfirmation,
            titleVisibility: .visible
        ) {
            Button("НАЧАТЬ НОВУЮ", role: .destructive) {
                viewModel.confirmSaveReplacement()
            }
            Button("ОТМЕНА", role: .cancel) {}
        } message: {
            Text("ТЕКУЩАЯ ИГРА БУДЕТ УДАЛЕНА.")
        }
        .onAppear {
            guard !didEnter else { return }
            if reduceMotion {
                didEnter = true
            } else {
                withAnimation(CardImpactMotion.standard(reduceMotion: false)) {
                    didEnter = true
                }
            }
        }
    }

    private func portraitLayout(size: CGSize, inset: CGFloat) -> some View {
        ViewThatFits(in: .vertical) {
            VStack(spacing: 0) {
                brandLockup(
                    width: min(size.width - inset * 2, 360),
                    height: lockupHeight(for: size)
                )
                .padding(.top, CardImpactSpacing.space6)

                Spacer(minLength: CardImpactSpacing.space5)

                actionStack
                    .frame(maxWidth: 430)
            }
            .padding(.horizontal, inset)
            .padding(.bottom, CardImpactSpacing.space4)

            ScrollView {
                VStack(spacing: CardImpactSpacing.space5) {
                    brandLockup(
                        width: min(size.width - inset * 2, 280),
                        height: 180
                    )

                    actionStack
                        .frame(maxWidth: 430)
                }
                .padding(.horizontal, inset)
                .padding(.vertical, CardImpactSpacing.space4)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func landscapeLayout(size: CGSize, inset: CGFloat) -> some View {
        HStack(spacing: CardImpactSpacing.space6) {
            brandLockup(
                width: min((size.width - inset * 2) * 0.44, 300),
                height: min(size.height - CardImpactSpacing.space6, 230)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ScrollView {
                actionStack
                    .frame(maxWidth: 430)
                    .padding(.vertical, CardImpactSpacing.space4)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, inset)
    }

    private var actionStack: some View {
        VStack(spacing: CardImpactSpacing.space3) {
            statusContent

            if case .available = viewModel.availability {
                continueButton(role: .primary, order: 0)
                newGameButton(role: .secondary, order: 1)
            } else {
                newGameButton(role: .primary, order: 0)
                continueButton(role: .secondary, order: 1)
            }

            ImpactButton(
                title: "ПРАВИЛА",
                systemImage: "book.closed.fill",
                role: .secondary,
                presentation: .stageDoor
            ) {
                isShowingRules = true
            }
            .accessibilityIdentifier("stageDoor.rules")
            .modifier(ActionEntranceModifier(order: 2, didEnter: didEnter, reduceMotion: reduceMotion))
        }
    }

    @ViewBuilder
    private var statusContent: some View {
        if let operationErrorMessage = viewModel.operationErrorMessage {
            StatusPanel(
                state: .recoverableError(
                    title: "НЕ УДАЛОСЬ НАЧАТЬ",
                    message: operationErrorMessage
                )
            ) {
                ImpactButton(title: "ЗАКРЫТЬ", role: .secondary) {
                    viewModel.clearOperationError()
                }
            }
        } else if case .loadFailed(let message) = viewModel.availability {
            StatusPanel(
                state: .recoverableError(
                    title: "НЕ УДАЛОСЬ ЗАГРУЗИТЬ",
                    message: message
                )
            ) {
                ImpactButton(title: "ПОВТОРИТЬ", role: .secondary) {
                    Task { await viewModel.refreshSaveAvailability() }
                }
            }
        } else if case .available = viewModel.availability {
            SavedGameCard(availability: viewModel.availability)
        } else if case .invalid = viewModel.availability {
            SavedGameCard(availability: viewModel.availability)
                .transition(.opacity)
        } else if case .checking = viewModel.availability,
                  viewModel.isLoadingIndicatorVisible {
            SavedGameCard(availability: .checking)
        }
    }

    private func continueButton(role: ImpactButtonRole, order: Int) -> some View {
        ImpactButton(
            title: "ПРОДОЛЖИТЬ",
            systemImage: "play.fill",
            role: role,
            isLoading: viewModel.isLoadingIndicatorVisible,
            presentation: .stageDoor
        ) {
            viewModel.continueGame()
        }
        .disabled(!viewModel.canContinue)
        .accessibilityHint(viewModel.canContinue ? "Открывает сохранённую игру." : viewModel.continueDisabledHint)
        .accessibilityIdentifier("stageDoor.continue")
        .modifier(ActionEntranceModifier(order: order, didEnter: didEnter, reduceMotion: reduceMotion))
    }

    private func newGameButton(role: ImpactButtonRole, order: Int) -> some View {
        ImpactButton(
            title: "НОВАЯ ИГРА",
            systemImage: "plus",
            role: role,
            isLoading: viewModel.isReplacingSave,
            presentation: .stageDoor
        ) {
            if viewModel.requestNewGame() == .requiresReplacementConfirmation {
                isShowingReplacementConfirmation = true
            }
        }
        .disabled(!viewModel.canStartNewGame)
        .accessibilityHint(newGameAccessibilityHint)
        .accessibilityIdentifier("stageDoor.newGame")
        .modifier(ActionEntranceModifier(order: order, didEnter: didEnter, reduceMotion: reduceMotion))
    }

    private var newGameAccessibilityHint: String {
        switch viewModel.availability {
        case .available:
            return "Потребуется подтвердить удаление текущей игры."
        case .checking:
            return "Станет доступно после проверки сохранения."
        case .loadFailed:
            return "Повторите проверку сохранения."
        case .none, .invalid:
            return "Открывает настройку новой игры."
        }
    }

    private func brandLockup(width: CGFloat, height: CGFloat) -> some View {
        let shape = CutCornerRectangle(cornerRadius: CardImpactRadius.card, cutSize: 24)

        return CardStack(
            shape: shape,
            underlays: [
                CardStackLayer(
                    color: CardImpactColor.actionPrimary,
                    offset: CGSize(width: -12, height: 10),
                    rotation: .degrees(-2)
                ),
                CardStackLayer(
                    color: CardImpactColor.success,
                    offset: CGSize(width: 12, height: 16),
                    rotation: .degrees(2)
                )
            ]
        ) {
            ZStack(alignment: .topTrailing) {
                shape
                    .fill(CardImpactColor.surfacePrimary)
                    .overlay {
                        shape.strokeBorder(
                            CardImpactColor.borderStrong,
                            lineWidth: CardImpactBorder.strong
                        )
                    }

                Text("ALIAS")
                    .font(
                        CardImpactTypography.brandLockup(
                            size: min(width * 0.48, height * 0.78)
                        )
                    )
                    .foregroundStyle(CardImpactColor.textOnLight)
                    .kerning(-2)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .padding(.horizontal, CardImpactSpacing.space3)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                ImpactMark(kind: .snap, color: CardImpactColor.danger, lineWidth: 3)
                    .frame(width: 50, height: 50)
                    .offset(x: 18, y: -20)
            }
        }
        .frame(width: width, height: height)
        .rotationEffect(.degrees(-2))
        .opacity(didEnter ? 1 : 0)
        .offset(y: didEnter || reduceMotion ? 0 : 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Alias")
    }

    private func lockupHeight(for size: CGSize) -> CGFloat {
        let proposed = dynamicTypeSize.isAccessibilitySize ? size.height * 0.22 : size.height * 0.29
        return min(max(proposed, 176), 280)
    }
}

private struct ActionEntranceModifier: ViewModifier {
    let order: Int
    let didEnter: Bool
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(didEnter ? 1 : 0)
            .offset(y: didEnter || reduceMotion ? 0 : 12)
            .animation(
                reduceMotion
                    ? nil
                    : .easeOut(duration: CardImpactMotion.Duration.micro)
                        .delay(Double(order) * 0.04),
                value: didEnter
            )
    }
}

#if DEBUG
private enum StageDoorPreviewFixtures {
    @MainActor
    static func viewModel(_ availability: SavedGameAvailability) -> StageDoorViewModel {
        StageDoorViewModel(initialAvailability: availability)
    }

    static let validSummary = SavedGameSummary(
        team: TeamIdentityDisplayModel(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Искры",
            style: .violetStripe
        ),
        phaseLabel: "ПАУЗА",
        contextLabel: "Раунд 2 · осталось 00:12"
    )
}

#Preview("Stage Door · No save", traits: .fixedLayout(width: 375, height: 667)) {
    StageDoorView(viewModel: StageDoorPreviewFixtures.viewModel(.none), startsEntered: true)
}

#Preview("Stage Door · No save · iPhone 17 Pro Max", traits: .fixedLayout(width: 440, height: 956)) {
    StageDoorView(viewModel: StageDoorPreviewFixtures.viewModel(.none), startsEntered: true)
}

#Preview("Stage Door · Valid save", traits: .fixedLayout(width: 393, height: 852)) {
    StageDoorView(
        viewModel: StageDoorPreviewFixtures.viewModel(
            .available(StageDoorPreviewFixtures.validSummary)
        ),
        startsEntered: true
    )
}

#Preview("Stage Door · Invalid save", traits: .fixedLayout(width: 430, height: 932)) {
    StageDoorView(viewModel: StageDoorPreviewFixtures.viewModel(.invalid), startsEntered: true)
}
#endif
