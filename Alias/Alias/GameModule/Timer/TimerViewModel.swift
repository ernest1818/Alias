import Foundation
import Combine

public final class TimerViewModel: ObservableObject {
    @Published private(set) var timeRemaining: Int
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isEndTime: Bool = false
    
    private var timer: Timer?
    private let initialTime: Int
    
    public init(initialTime: Int) {
        self.initialTime = initialTime
        self.timeRemaining = initialTime
    }
    
    func start() {
        guard !isRunning else { return }
        
        self.isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        guard !isRunning, timeRemaining > 0 else { return }
        start()
    }
    
    func reset() {
        pause()
        timeRemaining = initialTime
    }
    
    private func timerTick() {
        guard timeRemaining > 0 else {
            isEndTime = true
            return
        }
        
        timeRemaining -= 1
    }
    
    deinit {
        timer?.invalidate()
    }
} 
