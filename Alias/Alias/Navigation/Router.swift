//
//  Router.swift
//  Alias
//
//  Created by Ernest Avagovich on 09.02.2025.
//

import Foundation
import Combine

enum Route: Hashable {
    case resumeGame(GameSessionSnapshot)
    case showRules
    case showCommand
    case showSettings([Team])
    case showCategoryList(GameConfigModel)
    case showStartGame(GameConfigModel)
}

@MainActor
protocol RouterProtocol {
    func add(route: Route)
    func back()
    func backToRoot()
}

@MainActor
final class Router: ObservableObject {
    
    static let shared = Router()
    
    private init() {}
    
    @Published var path: [Route] = []
}

extension Router: RouterProtocol {
    func add(route: Route) {
        path.append(route)
    }
    
    func back() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func backToRoot() {
        path.removeAll()
    }
}
