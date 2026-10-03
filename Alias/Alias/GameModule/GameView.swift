import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var countdownScale = 0.55
    @State private var countdownOpacity = 0.25

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: viewModel.returnToMenu) {
                        Label("Меню", systemImage: PartyIcon.back.systemName)
                            .font(PartyTypography.body.weight(.semibold))
                    }
                    .foregroundStyle(Color.partyPrimaryText)
                    .accessibilityLabel("Вернуться в меню")
                }
                ToolbarItem(placement: .principal) {
                    Text(viewModel.currentTeam.name)
                        .font(PartyTypography.body.weight(.semibold))
                        .foregroundStyle(Color.partyPrimaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .toolbarBackground(Color.partyBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .gradientBackground()
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    viewModel.applicationDidBecomeInactive()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.currentState {
        case .preparing:
            StartGameView(viewModel: viewModel)
        case .playing:
            playingView
        case .paused:
            pausedView
        case .resumeCountdown:
            resumeCountdownView
        case .roundEnd:
            roundEndView
        case .gameEnd:
            gameEndView
        }
    }

    private var playingView: some View {
        ScrollView {
            VStack(spacing: PartySpacing.standard) {
                gameInfoView

                HStack {
                    Spacer()
                    TimerView(
                        timerViewModel: viewModel.timerViewModel,
                        initialTime: viewModel.gameConfig.configuration.roundTimer
                    )
                    Spacer()

                    Button(action: viewModel.pauseGame) {
                        Image(systemName: PartyIcon.pause.systemName)
                    }
                    .buttonStyle(PartyIconButtonStyle(tint: .partyYellow))
                    .accessibilityLabel("Пауза")
                }

                if let word = viewModel.currentWord {
                    WordCardView(
                        word: word.word,
                        onCorrect: viewModel.markWordAsGuessed,
                        onSkip: viewModel.skipWord
                    )
                }

                HStack(spacing: PartySpacing.medium) {
                    Button(action: viewModel.skipWord) {
                        Label("Пропустить", systemImage: PartyIcon.skip.systemName)
                    }
                    .buttonStyle(PartySecondaryButtonStyle(tint: .partyDanger))

                    Button(action: viewModel.markWordAsGuessed) {
                        Label("Угадано", systemImage: PartyIcon.correct.systemName)
                    }
                    .buttonStyle(PartySecondaryButtonStyle(tint: .partySuccess))
                }
            }
            .frame(maxWidth: PartyLayout.maximumContentWidth)
            .padding(PartySpacing.large)
        }
    }

    private var gameInfoView: some View {
        HStack {
            VStack(alignment: .leading, spacing: PartySpacing.xSmall) {
                Text("Игра #\(viewModel.gameInfo.gameNumber)")
                    .font(PartyTypography.body.weight(.semibold))
                Text("Раунд \(viewModel.gameInfo.currentRound)/\(viewModel.gameConfig.teams.count)")
                    .font(PartyTypography.caption)
                    .foregroundStyle(Color.partySecondaryText)
            }
            Spacer()
            Image(systemName: PartyIcon.trophy.systemName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.partyYellow)
        }
        .partyCard()
    }

    private var pausedView: some View {
        VStack(spacing: PartySpacing.large) {
            Image(systemName: PartyIcon.pause.systemName)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Color.partyYellow)
            Text("Пауза")
                .font(PartyTypography.screenTitle)
            AliasButton(action: viewModel.resumeGame, title: "Продолжить")
        }
        .frame(maxWidth: PartyLayout.maximumContentWidth)
        .partyCard(accent: .partyYellow)
        .padding(PartySpacing.large)
    }

    @ViewBuilder
    private var resumeCountdownView: some View {
        if let step = viewModel.resumeCountdownStep {
            VStack(spacing: PartySpacing.large) {
                Image(systemName: PartyIcon.play.systemName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.partyLime)

                Text(step.title)
                    .font(step == .started ? PartyTypography.timer : .system(size: 112, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.partyPrimaryText)
                    .minimumScaleFactor(0.6)
            }
            .scaleEffect(countdownScale)
            .opacity(countdownOpacity)
            .id(step)
            .onAppear {
                countdownScale = 0.55
                countdownOpacity = 0.25
                withAnimation(.spring(response: 0.45, dampingFraction: 0.58)) {
                    countdownScale = 1
                    countdownOpacity = 1
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("game.resumeCountdown")
        }
    }

    private var roundEndView: some View {
        ScrollView {
            VStack(spacing: PartySpacing.large) {
                Image(systemName: PartyIcon.correct.systemName)
                    .font(.system(size: 38, weight: .heavy))
                    .foregroundStyle(Color.partySuccess)
                    .frame(width: 76, height: 76)
                    .background(Color.partySuccess.opacity(0.15))
                    .clipShape(Circle())

                Text("Раунд завершен!")
                    .font(PartyTypography.screenTitle)
                    .multilineTextAlignment(.center)

                if let result = viewModel.roundResults.last {
                    VStack(alignment: .leading, spacing: PartySpacing.medium) {
                        resultRow("Угадано слов", value: result.correctWords.count, color: .partySuccess)
                        resultRow("Пропущено слов", value: result.skippedWords.count, color: .partyCoral)
                        resultRow("Штрафы", value: result.penalties, color: .partyDanger)
                        Divider().overlay(Color.white.opacity(0.12))
                        resultRow(
                            "Итоговые очки",
                            value: viewModel.gameScores.first(where: { $0.teamId == viewModel.currentTeam.id })?.totalScore ?? 0,
                            color: .partyYellow
                        )
                    }
                    .partyCard()
                }

                Button(action: viewModel.prepareForNextRound) {
                    Label("Следующий раунд", systemImage: PartyIcon.forward.systemName)
                }
                .buttonStyle(PartyPrimaryButtonStyle())
            }
            .frame(maxWidth: PartyLayout.maximumContentWidth)
            .padding(PartySpacing.large)
        }
    }

    private var gameEndView: some View {
        ScrollView {
            VStack(spacing: PartySpacing.large) {
                Image(systemName: PartyIcon.trophy.systemName)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(Color.partyYellow)
                    .shadow(color: Color.partyYellow.opacity(0.35), radius: 18)

                Text("Игра окончена!")
                    .font(PartyTypography.screenTitle)
                    .multilineTextAlignment(.center)

                VStack(spacing: PartySpacing.medium) {
                    ForEach(viewModel.gameScores) { score in
                        if let team = viewModel.gameConfig.teams.first(where: { $0.id == score.teamId }) {
                            HStack(spacing: PartySpacing.medium) {
                                Image(systemName: PartyIcon.team.systemName)
                                    .foregroundStyle(Color.partyLime)
                                Text(team.name)
                                    .font(PartyTypography.body.weight(.semibold))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.75)
                                Spacer(minLength: PartySpacing.small)
                                Text("\(score.totalScore)")
                                    .font(PartyTypography.section)
                                    .foregroundStyle(Color.partyYellow)
                            }
                            .partyCard()
                        }
                    }
                }
            }
            .frame(maxWidth: PartyLayout.maximumContentWidth)
            .padding(PartySpacing.large)
        }
    }

    private func resultRow(_ title: String, value: Int, color: Color) -> some View {
        HStack {
            Text("\(title):")
                .font(PartyTypography.body)
                .foregroundStyle(Color.partySecondaryText)
            Spacer()
            Text("\(value)")
                .font(PartyTypography.section)
                .foregroundStyle(color)
        }
    }
}

#if DEBUG
    #Preview {
        GameView(
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
