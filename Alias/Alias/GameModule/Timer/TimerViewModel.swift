import Foundation
import Combine

@MainActor
protocol GameTicker: AnyObject {
    func start(_ tick: @escaping () -> Void)
    func stop()
}

@MainActor
final class FoundationGameTicker: GameTicker {
    private var timer: Timer?

    func start(_ tick: @escaping () -> Void) {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            tick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
    }
}

@MainActor
public final class TimerViewModel: ObservableObject {
    @Published private(set) var timeRemaining: Int
    @Published private(set) var isRunning = false
    @Published private(set) var isEndTime = false

    var onTick: ((Int) -> Void)?
    var onExpiration: (() -> Void)?

    private let ticker: GameTicker
    private let initialTime: Int
    private var didDeliverExpiration = false

    init(
        initialTime: Int,
        timeRemaining: Int? = nil,
        ticker: GameTicker? = nil
    ) {
        self.initialTime = initialTime
        self.timeRemaining = min(max(timeRemaining ?? initialTime, 0), initialTime)
        self.ticker = ticker ?? FoundationGameTicker()
    }

    func start() {
        guard !isRunning else { return }
        guard timeRemaining > 0 else {
            deliverExpirationIfNeeded()
            return
        }

        isRunning = true
        ticker.start { [weak self] in
            self?.timerTick()
        }
    }

    func pause() {
        isRunning = false
        ticker.stop()
    }

    func resume() {
        start()
    }

    func reset() {
        pause()
        timeRemaining = initialTime
        isEndTime = false
        didDeliverExpiration = false
    }

    private func timerTick() {
        guard isRunning, timeRemaining > 0 else { return }

        timeRemaining -= 1
        onTick?(timeRemaining)

        if timeRemaining == 0 {
            pause()
            deliverExpirationIfNeeded()
        }
    }

    private func deliverExpirationIfNeeded() {
        guard !didDeliverExpiration else { return }
        didDeliverExpiration = true
        isEndTime = true
        onExpiration?()
    }
}
