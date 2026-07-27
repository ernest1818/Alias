//
//  EntranceViewModel.swift
//  Alias
//
//  Created by Ernest Avagovich on 17.01.2025.
//

import Foundation
import UIKit

final class EntranceViewModel: ObservableObject {
    let router: RouterProtocol
    
    init() {
        self.router = Router.shared
    }
    
    @Published var menus: [EntranceGroup] = [
        EntranceGroup(id: 1, name: "Continue Game", route: .continueGame),
        EntranceGroup(id: 2, name: "New Game", route: .showCommand),
        EntranceGroup(id: 3, name: "Rules", route: .continueGame)
    ]
}
