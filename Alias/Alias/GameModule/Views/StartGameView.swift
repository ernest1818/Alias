import SwiftUI

struct StartGameView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: PartySpacing.large) {
                VStack(spacing: PartySpacing.small) {
                    Text("Раунд #\(viewModel.gameInfo.gameNumber)")
                        .font(PartyTypography.screenTitle)
                        .foregroundStyle(Color.partyYellow)
                    Text("Раунд \(viewModel.gameInfo.currentRound)/\(viewModel.gameConfig.teams.count)")
                        .font(PartyTypography.body)
                        .foregroundStyle(Color.partySecondaryText)
                }

                teamListView

                if let challenge = viewModel.currentChallenge {
                    challengeView(challenge)
                }

                AliasButton(action: viewModel.startGame, title: "Играть")
                    .padding(.top, PartySpacing.small)
            }
            .frame(maxWidth: PartyLayout.maximumContentWidth)
            .padding(PartySpacing.large)
        }
    }

    private func challengeView(_ challenge: GameChallenge) -> some View {
        VStack(spacing: PartySpacing.small) {
            Label("Задание раунда", systemImage: challenge.symbolName)
                .font(PartyTypography.body.weight(.semibold))
                .foregroundStyle(Color.partyCoral)

            Text(challenge.title)
                .font(PartyTypography.section)

            Text(challenge.instruction)
                .font(PartyTypography.body)
                .foregroundStyle(Color.partySecondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .partyCard(accent: .partyCoral)
    }

    private var teamListView: some View {
        VStack(spacing: PartySpacing.medium) {
            ForEach(viewModel.gameScores) { item in
                TeamRowView(
                    name: viewModel.gameInfo.teamsMap[item.teamId]?.name ?? "",
                    score: item.totalScore,
                    isActive: viewModel.currentTeam.id == item.teamId
                )
            }
        }
    }
}

struct TeamRowView: View {
    let name: String
    let score: Int
    let isActive: Bool

    var body: some View {
        HStack(spacing: PartySpacing.medium) {
            Image(systemName: PartyIcon.team.systemName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(isActive ? Color.partyLime : Color.partySecondaryText)
                .frame(width: PartyLayout.minimumTouchTarget, height: PartyLayout.minimumTouchTarget)
                .background(isActive ? Color.partyLime.opacity(0.13) : Color.partySpotlight)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: PartySpacing.xSmall) {
                Text(name)
                    .font(PartyTypography.body.weight(.semibold))
                    .foregroundStyle(Color.partyPrimaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                if isActive {
                    Text("Ваша очередь")
                        .font(PartyTypography.caption)
                        .foregroundStyle(Color.partyLime)
                }
            }

            Spacer(minLength: PartySpacing.small)

            Text("\(score)")
                .font(PartyTypography.section)
                .foregroundStyle(isActive ? Color.partyYellow : Color.partySecondaryText)
        }
        .partyCard(accent: isActive ? .partyLime : nil)
    }
}
