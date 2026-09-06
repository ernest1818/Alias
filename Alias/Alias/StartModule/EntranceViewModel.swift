import Foundation
import Combine

enum EntranceMenuAction: Hashable {
    case continueGame
    case newGame
    case rules
}

struct EntranceGroup: Identifiable, Hashable {
    let id: Int
    let name: String
    let action: EntranceMenuAction
}

@MainActor
final class EntranceViewModel: ObservableObject {
    @Published private(set) var hasSavedGame = false
    @Published private(set) var isShowingReplacementConfirmation = false
    @Published private(set) var lastPersistenceError: String?

    let menus: [EntranceGroup] = [
        EntranceGroup(id: 1, name: "Continue Game", action: .continueGame),
        EntranceGroup(id: 2, name: "New Game", action: .newGame),
        EntranceGroup(id: 3, name: "Rules", action: .rules)
    ]

    private let router: RouterProtocol
    private let store: GameSessionStore

    init(
        router: RouterProtocol = Router.shared,
        store: GameSessionStore = UnavailableGameSessionStore.shared
    ) {
        self.router = router
        self.store = store
    }

    func refreshSaveAvailability() {
        hasSavedGame = store.loadActive() != nil
    }

    func select(_ action: EntranceMenuAction) {
        switch action {
        case .continueGame:
            continueSavedGame()
        case .newGame:
            requestNewGame()
        case .rules:
            router.add(route: .showRules)
        }
    }

    func cancelNewGameReplacement() {
        isShowingReplacementConfirmation = false
    }

    func confirmNewGameReplacement() {
        guard isShowingReplacementConfirmation else { return }

        do {
            try store.deleteActive()
            hasSavedGame = false
            isShowingReplacementConfirmation = false
            lastPersistenceError = nil
            router.add(route: .showCommand)
        } catch {
            lastPersistenceError = String(describing: error)
        }
    }

    private func continueSavedGame() {
        guard let snapshot = store.loadActive() else {
            hasSavedGame = false
            return
        }
        hasSavedGame = true
        router.add(route: .resumeGame(snapshot))
    }

    private func requestNewGame() {
        if store.loadActive() != nil {
            hasSavedGame = true
            isShowingReplacementConfirmation = true
        } else {
            hasSavedGame = false
            router.add(route: .showCommand)
        }
    }
}
