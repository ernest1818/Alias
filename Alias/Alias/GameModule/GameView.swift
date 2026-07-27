//
//  GameView.swift
//  Alias
//
//  Created by Ernest Avagovich on 17.02.2025.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.currentTeam.name)
                        .font(.headline)
                }
            }
            .gradientBackground()
    }
    
    @ViewBuilder
    private var content: some View {
        VStack {
            switch viewModel.currentState {
            case .preparing:
                preparingView
            case .playing:
                VStack {
                    playingView
                    playPauseView
                }
            case .paused:
                pausedView
            case .roundEnd:
                roundEndView
            case .gameEnd:
                gameEndView
            }
        }
    }
    
    private var preparingView: some View {
        StartGameView(viewModel: viewModel)
    }
    
    private var playingView: some View {
        VStack {
            gameInfoView
                .padding(.bottom)
            
            TimerView(
                timerViewModel: viewModel.timerViewModel,
                initialTime: viewModel.gameConfig.configuration.roundTimer
            )
            .padding()
            
            
            
            if let word = viewModel.currentWord {
                WordCardView(
                    word: word.word,
                    onCorrect: { viewModel.markWordAsGuessed() },
                    onSkip: { viewModel.skipWord() }
                )
            }
            
            HStack {
                GameSkipButton(action: viewModel.skipWord, title:  "xmark.circle.fill", color: .red)
                
                Spacer(minLength: 0)
                
                GameSkipButton(action: viewModel.markWordAsGuessed, title:  "checkmark.circle.fill", color: .green)
            }
            .padding(20)
        }
    }
    
    private var gameInfoView: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading) {
                Text("Игра #\(viewModel.gameInfo.gameNumber)")
                    .font(.headline)
                Text("Раунд \(viewModel.gameInfo.currentRound)/\(viewModel.gameConfig.teams.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var pausedView: some View {
        VStack {
            Text("Пауза")
                .font(.largeTitle)
            
            Button("Продолжить") {
                viewModel.resumeGame()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
    
    private var roundEndView: some View {
        VStack {
            Text("Раунд завершен!")
                .font(.largeTitle)
            
            if let result = viewModel.roundResults.last {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Угадано слов: \(result.correctWords.count)")
                    Text("Пропущено слов: \(result.skippedWords.count)")
                    Text("Штрафы: \(result.penalties)")
                    Text("Итоговые очки: \(viewModel.gameScores.first(where: { $0.teamId == viewModel.currentTeam.id })?.totalScore ?? 0)")
                }
                .padding()
            }
            
            Button("Следующий раунд") {
                viewModel.prepareForNextRound()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
    
    private var gameEndView: some View {
        VStack {
            Text("Игра окончена!")
                .font(.largeTitle)
            
            ForEach(viewModel.gameScores) { score in
                if let team = viewModel.gameConfig.teams.first(where: { $0.id == score.teamId }) {
                    HStack {
                        Text(team.name)
                        Spacer()
                        Text("\(score.totalScore)")
                            .bold()
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var playPauseView: some View {
        HStack {
            Spacer(minLength: 1)
            HStack {
                switch viewModel.currentState {
                case .playing:
                    Button(action: {
                        viewModel.pauseGame()
                    }) {
                        Image(systemName: "pause.circle")
                    }
                case .paused:
                    Button(action: {
                        viewModel.resumeGame()
                    }) {
                        Image(systemName: "play.circle")
                            
                    }
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

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
