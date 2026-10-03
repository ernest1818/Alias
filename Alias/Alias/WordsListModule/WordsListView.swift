import SwiftUI

struct WordsListView: View {
    @ObservedObject var viewModel: WordsListViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: PartySpacing.medium) {
                ForEach(viewModel.wordsList) { item in
                    Button(action: { viewModel.showStartGame(item) }) {
                        HStack(spacing: PartySpacing.standard) {
                            Circle()
                                .fill(item.partyAccent)
                                .frame(width: 12, height: 12)

                            Text(item.title)
                                .font(PartyTypography.section)
                                .foregroundStyle(Color.partyPrimaryText)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)

                            Spacer(minLength: PartySpacing.small)

                            Image(systemName: PartyIcon.forward.systemName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(item.partyAccent)
                        }
                        .contentShape(Rectangle())
                        .partyCard(accent: item.partyAccent)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Выбрать категорию")
                }
                .padding(.horizontal, PartySpacing.large)
            }
            .padding(.vertical, PartySpacing.large)
        }
        .gradientBackground()
    }
}

#if DEBUG
    #Preview {
        WordsListView(
            viewModel: .init(
                gameConfig: GameConfigModel(
                    teams: [],
                    configuration: Configuration(
                        wordsCount: 1,
                        roundTimer: 1,
                        isSkipPenalty: false,
                        islastWordForAllTeam: false,
                        challenges: .off,
                        selectedChallenges: [],
                        isSoundOn: false
                    )
                )
            )
        )
    }
#endif
