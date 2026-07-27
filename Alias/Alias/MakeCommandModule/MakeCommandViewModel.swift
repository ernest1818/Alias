//
//  MakeCommandViewModel.swift
//  Alias
//
//  Created by Ernest Avagovich on 12.02.2025.
//

import Foundation

final class MakeCommandViewModel: ObservableObject {
    private let router = Router.shared
    @Published var commandNames: [Team] = [
        Team(name: GameData.teamNames.randomElement() ?? "Без имени"),
        Team(name: GameData.teamNames.randomElement() ?? "Без имени")
        ]
    
    func addTeam() {
        let names = commandNames.map { $0.name } + GameData.teamNames
        let namesSet = Set(names)
        if
            let name = namesSet.randomElement(),
            commandNames.count < 5
        {
            commandNames.append(Team(name: name))
        }
    }
    
    func removeTeam(team: Team) {
        if let index = commandNames.firstIndex(where: { $0.id == team.id }) {
            commandNames.remove(at: index)
        }
    }
    
    func showNext() {
        router.add(route: .showSettings(commandNames))
    }
}
