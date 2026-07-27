//
//  WordsListView.swift
//  Alias
//
//  Created by Ernest Avagovich on 16.02.2025.
//

import SwiftUI

struct WordsListView: View {
    
    @ObservedObject var viewModel: WordsListViewModel
    
    var body: some View {
            VStack {
                ScrollView {
                    ForEach(viewModel.wordsList) { item in
                        Button(action: {
                            viewModel.showStartGame(item)
                        }, label: {
                            HStack {
                                Text(item.title)
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.darkSlate)
                                
                                Spacer(minLength: 1)
                                
                                Image(systemName: "chevron.right")
                                    .renderingMode(.template)
                                    .resizable()
                                    .fontWeight(.bold)
                                    .frame(width: 12, height: 18, alignment: .trailing)
                                    .foregroundColor(.lightBlack)
                                
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 40)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(item.backGroundColor.opacity(0.3))
                            }
                            .padding(.horizontal, 20)
                        })
                    }
                }
            }
            .gradientBackground()
    }
}

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
