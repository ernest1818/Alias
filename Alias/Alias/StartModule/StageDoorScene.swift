import SwiftUI

struct StageDoorScene: View {
    @StateObject private var viewModel: StageDoorViewModel

    init(
        router: RouterProtocol,
        store: GameSessionStore
    ) {
        _viewModel = StateObject(
            wrappedValue: StageDoorViewModel(router: router, store: store)
        )
    }

    var body: some View {
        StageDoorView(viewModel: viewModel)
            .task {
                await viewModel.refreshSaveAvailability()
            }
    }
}
