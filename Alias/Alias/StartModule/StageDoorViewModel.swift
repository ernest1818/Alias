import Combine
import Foundation

struct SavedGameSummary: Equatable {
    let team: TeamIdentityDisplayModel
    let phaseLabel: String
    let contextLabel: String
}

enum SavedGameAvailability: Equatable {
    case checking
    case none
    case available(SavedGameSummary)
    case invalid
    case loadFailed(message: String)
}

enum StageDoorNewGameRequest: Equatable {
    case started
    case requiresReplacementConfirmation
    case blocked
}

struct SavedGameSummaryAdapter {
    func makeSummary(from snapshot: GameSessionSnapshot) -> SavedGameSummary {
        let teamIndex = snapshot.teams.firstIndex { $0.id == snapshot.currentTeam.id } ?? 0
        let styles = TeamVisualStyle.allCases
        let style = styles[teamIndex % styles.count]
        let phase: (label: String, context: String)

        switch snapshot.phase {
        case .preparing:
            phase = ("ПОДГОТОВКА", "Раунд \(snapshot.currentRound)")
        case .playing, .paused:
            phase = (
                "ПАУЗА",
                "Раунд \(snapshot.currentRound) · осталось \(Self.timeLabel(snapshot.remainingTime))"
            )
        case .roundEnd:
            phase = ("ИТОГИ РАУНДА", "Раунд \(snapshot.currentRound)")
        }

        return SavedGameSummary(
            team: TeamIdentityDisplayModel(
                id: snapshot.currentTeam.id,
                name: snapshot.currentTeam.name,
                style: style
            ),
            phaseLabel: phase.label,
            contextLabel: phase.context
        )
    }

    private static func timeLabel(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

@MainActor
protocol StageDoorSaveInspecting: AnyObject {
    func inspectActive() async throws -> GameSessionInspection
}

@MainActor
final class GameSessionStoreInspector: StageDoorSaveInspecting {
    private let store: GameSessionStore

    init(store: GameSessionStore) {
        self.store = store
    }

    func inspectActive() async throws -> GameSessionInspection {
        try store.inspectActive()
    }
}

@MainActor
protocol StageDoorLoadingCancellable: AnyObject {
    func cancel()
}

@MainActor
protocol StageDoorLoadingScheduling: AnyObject {
    func schedule(
        after delay: TimeInterval,
        action: @escaping @MainActor () -> Void
    ) -> StageDoorLoadingCancellable
}

@MainActor
final class TaskStageDoorLoadingScheduler: StageDoorLoadingScheduling {
    func schedule(
        after delay: TimeInterval,
        action: @escaping @MainActor () -> Void
    ) -> StageDoorLoadingCancellable {
        TaskStageDoorLoadingCancellation(delay: delay, action: action)
    }
}

@MainActor
private final class TaskStageDoorLoadingCancellation: StageDoorLoadingCancellable {
    private var task: Task<Void, Never>?

    init(delay: TimeInterval, action: @escaping @MainActor () -> Void) {
        task = Task { @MainActor in
            let nanoseconds = UInt64(max(0, delay) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            action()
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}

@MainActor
final class StageDoorViewModel: ObservableObject {
    static let loadingThreshold: TimeInterval = 0.25

    @Published private(set) var availability: SavedGameAvailability
    @Published private(set) var isLoadingIndicatorVisible = false
    @Published private(set) var isReplacingSave = false
    @Published private(set) var operationErrorMessage: String?

    private let router: RouterProtocol
    private let store: GameSessionStore
    private let inspector: StageDoorSaveInspecting
    private let summaryAdapter: SavedGameSummaryAdapter
    private let loadingScheduler: StageDoorLoadingScheduling

    private var activeSnapshot: GameSessionSnapshot?
    private var activeRequestID: UUID?
    private var loadingCancellation: StageDoorLoadingCancellable?

    init(
        router: RouterProtocol? = nil,
        store: GameSessionStore? = nil,
        inspector: StageDoorSaveInspecting? = nil,
        summaryAdapter: SavedGameSummaryAdapter = SavedGameSummaryAdapter(),
        loadingScheduler: StageDoorLoadingScheduling? = nil,
        initialAvailability: SavedGameAvailability = .checking
    ) {
        let resolvedStore = store ?? UnavailableGameSessionStore.shared
        self.router = router ?? Router.shared
        self.store = resolvedStore
        self.inspector = inspector ?? GameSessionStoreInspector(store: resolvedStore)
        self.summaryAdapter = summaryAdapter
        self.loadingScheduler = loadingScheduler ?? TaskStageDoorLoadingScheduler()
        availability = initialAvailability
    }

    var canContinue: Bool {
        if case .available = availability { return true }
        return false
    }

    var canStartNewGame: Bool {
        switch availability {
        case .none, .available, .invalid:
            return !isReplacingSave
        case .checking, .loadFailed:
            return false
        }
    }

    var continueDisabledHint: String {
        switch availability {
        case .checking:
            return "Сохранение ещё проверяется."
        case .none:
            return "Нет сохранённой игры."
        case .invalid:
            return "Сохранение недоступно. Начните новую игру."
        case .loadFailed:
            return "Не удалось проверить сохранение."
        case .available:
            return ""
        }
    }

    func refreshSaveAvailability() async {
        let requestID = UUID()
        activeRequestID = requestID
        loadingCancellation?.cancel()
        activeSnapshot = nil
        operationErrorMessage = nil
        availability = .checking
        isLoadingIndicatorVisible = false

        loadingCancellation = loadingScheduler.schedule(after: Self.loadingThreshold) { [weak self] in
            guard let self,
                  self.activeRequestID == requestID,
                  case .checking = self.availability
            else { return }
            self.isLoadingIndicatorVisible = true
        }

        defer {
            if activeRequestID == requestID {
                loadingCancellation?.cancel()
                loadingCancellation = nil
                isLoadingIndicatorVisible = false
            }
        }

        do {
            let inspection = try await inspector.inspectActive()
            guard !Task.isCancelled, activeRequestID == requestID else { return }
            apply(inspection)
        } catch is CancellationError {
            return
        } catch {
            guard activeRequestID == requestID else { return }
            availability = .loadFailed(
                message: "Не удалось проверить сохранение. Попробуйте ещё раз."
            )
        }

    }

    func continueGame() {
        guard canContinue, let activeSnapshot else { return }
        router.add(route: .resumeGame(activeSnapshot))
    }

    @discardableResult
    func requestNewGame() -> StageDoorNewGameRequest {
        guard canStartNewGame else { return .blocked }

        if case .available = availability {
            return .requiresReplacementConfirmation
        }

        router.add(route: .showCommand)
        return .started
    }

    func confirmSaveReplacement() {
        guard case .available = availability, !isReplacingSave else { return }

        isReplacingSave = true
        operationErrorMessage = nil
        defer { isReplacingSave = false }

        do {
            try store.deleteActive()
            activeSnapshot = nil
            availability = .none
            router.add(route: .showCommand)
        } catch {
            operationErrorMessage = "Не удалось удалить текущую игру. Сохранение осталось без изменений."
        }
    }

    func clearOperationError() {
        operationErrorMessage = nil
    }

    private func apply(_ inspection: GameSessionInspection) {
        switch inspection {
        case .none:
            activeSnapshot = nil
            availability = .none
        case .available(let snapshot):
            activeSnapshot = snapshot
            availability = .available(summaryAdapter.makeSummary(from: snapshot))
        case .invalid:
            activeSnapshot = nil
            availability = .invalid
        }
    }
}
