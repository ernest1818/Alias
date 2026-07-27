//
//  Router.swift
//  Alias
//
//  Created by Ernest Avagovich on 09.02.2025.
//

import Foundation

enum Route: Hashable {  
    case continueGame
    case showCommand
    case showSettings([Team])
    case showCategoryList(GameConfigModel)
    case showStartGame(GameConfigModel)
}

protocol RouterProtocol {
    func add(route: Route)
    func back()
    func backToRoot()
}

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
        path.removeLast()
    }
    
    func backToRoot() {
        path.removeAll()
    }
}
