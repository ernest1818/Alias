import SwiftUI

struct EntranceView: View {
    @ObservedObject var viewModel: EntranceViewModel

    var body: some View {
        VStack(spacing: PartySpacing.standard) {
            ZStack {
                Circle().fill(Color.partyPrimaryAction)
                Circle()
                    .stroke(Color.partyLime, lineWidth: 4)
                    .padding(6)
                Text("Alias")
                    .foregroundStyle(Color.partyPrimaryText)
                    .font(PartyTypography.display)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 176, height: 176)
            .shadow(color: Color.partyPrimaryAction.opacity(0.5), radius: 24, y: 12)
            .padding(.top, PartySpacing.xxLarge)

            Spacer()

            ForEach(viewModel.menus) { item in
                Group {
                    if item.action == .rules {
                        menuButton(for: item)
                            .buttonStyle(PartySecondaryButtonStyle())
                    } else {
                        menuButton(for: item)
                            .buttonStyle(PartyPrimaryButtonStyle())
                    }
                }
                .disabled(item.action == .continueGame && !viewModel.hasSavedGame)
                .accessibilityIdentifier("entrance.\(item.id)")
            }
            .frame(maxWidth: PartyLayout.maximumContentWidth)
        }
        .padding(PartySpacing.large)
        .gradientBackground()
        .onAppear(perform: viewModel.refreshSaveAvailability)
        .alert(
            "Заменить сохранённую игру?",
            isPresented: Binding(
                get: { viewModel.isShowingReplacementConfirmation },
                set: { if !$0 { viewModel.cancelNewGameReplacement() } }
            )
        ) {
            Button("Отмена", role: .cancel, action: viewModel.cancelNewGameReplacement)
            Button("Заменить", role: .destructive, action: viewModel.confirmNewGameReplacement)
        } message: {
            Text("Текущая незавершённая игра будет удалена.")
        }
    }

    private func icon(for action: EntranceMenuAction) -> PartyIcon {
        switch action {
        case .continueGame: return .play
        case .newGame: return .add
        case .rules: return .rules
        }
    }

    private func menuButton(for item: EntranceGroup) -> some View {
        Button(action: { viewModel.select(item.action) }) {
            Label(item.name, systemImage: icon(for: item.action).systemName)
        }
    }
}

#if DEBUG
    #Preview {
        EntranceView(viewModel: EntranceViewModel())
    }
#endif
