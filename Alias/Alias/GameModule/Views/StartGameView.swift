//
//  StartGameView.swift
//  Alias
//
//  Created by Ernest Avagovich on 13.04.2025.
//

import SwiftUI

struct StartGameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        
        VStack(spacing: 20) {
            // Заголовок
            Text("Раунд #\(viewModel.gameInfo.gameNumber)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.pink)
                .padding(.vertical, 15)
            Text("Раунд \(viewModel.gameInfo.currentRound)/\(viewModel.gameConfig.teams.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            teamListView

            if let challenge = viewModel.currentChallenge {
                challengeView(challenge)
            }

            Spacer()
            
            
            AliasButton(action: viewModel.startGame, title: "Играть")
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
    }

    private func challengeView(_ challenge: GameChallenge) -> some View {
        VStack(spacing: 8) {
            Label("Задание раунда", systemImage: challenge.symbolName)
                .font(.headline)
                .foregroundStyle(.pink)

            Text(challenge.title)
                .font(.title3.weight(.semibold))

            Text(challenge.instruction)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal)
    }
    
    private var teamListView: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.gameScores, id: \.id) { item in
                TeamRowView(
                    icon: "",
                    name: viewModel.gameInfo.teamsMap[item.teamId]?.name ?? "",
                    score: item.totalScore,
                    isActive: viewModel.currentTeam.id == item.teamId
                )
            }
        }
        .padding(.horizontal)
    }
}

struct TeamRowView: View {
    let icon: String
    let name: String
    let score: Int
    let isActive: Bool

    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .frame(width: 50, height: 50)
                .background(Circle().fill(isActive ? Color.red.opacity(0.2) : Color.blue.opacity(0.2)))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isActive ? .black : .gray)
                if isActive {
                    Text("Ваша очередь")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                }
            }

            Spacer()

            Text("\(score)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.pink)
        }
    }
}
