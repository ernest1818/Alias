//
//  AliasApp.swift
//  Alias
//
//  Created by Ernest Avagovich on 16.01.2025.
//

import SwiftUI

@main
struct AliasApp: App {
    
    @ObservedObject var router = Router.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                EntranceView(viewModel: EntranceViewModel())
                    .navigationDestination(for: Route.self) { item in
                        switch item {
                        case .continueGame:
                            Text("need SwiftData")
                        case .showCommand:
                            MakeCommandView(viewModel: .init())
                        case .showCategoryList(let configuration):
                            WordsListView(viewModel: .init(gameConfig: configuration))
                        case .showSettings(let teams):
                            SettingsView(viewModel: .init(teams: teams))
                        case .showStartGame(let gameConfig):
                            GameView(viewModel: GameViewModel(gameConfig: gameConfig))
                                .navigationBarBackButtonHidden(true) // Скрываем системную кнопку "Назад"
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarLeading) {
                                        Button(action: {
                                            router.backToRoot()
                                        }) {
                                            HStack {
                                                Image(systemName: "chevron.left")
                                                    .foregroundColor(.blue)
                                                Text("Меню")
                                                    .font(.title3)
                                                    .padding(.leading, 5)
                                            }
                                        }
                                    }
                                }
                        }
                    }
            }
        }
    }
}
