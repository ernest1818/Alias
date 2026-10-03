import SwiftData
import SwiftUI

@main
@MainActor
struct AliasApp: App {
    @ObservedObject private var router = Router.shared

    private let modelContainer: ModelContainer
    private let gameSessionStore: SwiftDataGameSessionStore

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: SavedGameRecord.self)
        } catch {
            let fallback = ModelConfiguration(isStoredInMemoryOnly: true)
            container = try! ModelContainer(
                for: SavedGameRecord.self,
                configurations: fallback
            )
        }
        modelContainer = container
        let store = SwiftDataGameSessionStore(modelContext: container.mainContext)
        if ProcessInfo.processInfo.arguments.contains("-uiTestResetSavedGame") {
            try? store.deleteActive()
        }
        gameSessionStore = store
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                EntranceView(
                    viewModel: EntranceViewModel(
                        router: router,
                        store: gameSessionStore
                    )
                )
                .navigationDestination(for: Route.self) { route in
                    destination(for: route)
                }
            }
            .modelContainer(modelContainer)
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .resumeGame(let snapshot):
            GameView(
                viewModel: GameViewModel(
                    restoring: snapshot,
                    store: gameSessionStore,
                    router: router
                )
            )
            .navigationBarBackButtonHidden(true)
        case .showRules:
            VStack(spacing: PartySpacing.large) {
                Image(systemName: PartyIcon.rules.systemName)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.partyYellow)
                Text("Rules")
                    .font(PartyTypography.screenTitle)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gradientBackground()
        case .showCommand:
            MakeCommandView(viewModel: .init())
        case .showCategoryList(let configuration):
            WordsListView(viewModel: .init(gameConfig: configuration))
        case .showSettings(let teams):
            SettingsView(viewModel: .init(teams: teams))
        case .showStartGame(let gameConfig):
            GameView(
                viewModel: GameViewModel(
                    gameConfig: gameConfig,
                    store: gameSessionStore,
                    router: router
                )
            )
            .navigationBarBackButtonHidden(true)
        }
    }
}
