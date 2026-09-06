import SwiftUI

struct EntranceView: View {
    @ObservedObject var viewModel: EntranceViewModel

    var body: some View {
        VStack {
            Text("Alias")
                .foregroundStyle(.white)
                .font(.superCrownXXL)
                .padding(40)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 6)
                .background {
                    Circle().stroke(Color.white, lineWidth: 4)
                }
                .background {
                    ZStack {
                        Color.greenButtonBackground
                        Circle()
                            .fill(.greenRight)
                            .overlay {
                                Rectangle()
                                    .fill(Color(.greenLeft))
                                    .rotationEffect(.degrees(55))
                                    .frame(width: 200, height: 200)
                                    .offset(x: -90, y: 40)
                            }
                            .clipShape(Circle())
                            .offset(y: -10)
                    }
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 8)
                }

            Spacer()

            ForEach(viewModel.menus) { item in
                AliasButton(
                    action: { viewModel.select(item.action) },
                    title: item.name
                )
                .disabled(item.action == .continueGame && !viewModel.hasSavedGame)
                .opacity(item.action == .continueGame && !viewModel.hasSavedGame ? 0.45 : 1)
                .accessibilityIdentifier("entrance.\(item.id)")
                .padding(.top, 10)
            }
        }
        .padding()
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
}

#Preview {
    EntranceView(viewModel: EntranceViewModel())
}
