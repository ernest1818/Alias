import SwiftUI

struct TimerView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    let initialTime: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: 15
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    timerViewModel.timeRemaining <= 10 ? Color.red : Color.blue,
                    style: StrokeStyle(
                        lineWidth: 15,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            
            Text("\(timerViewModel.timeRemaining)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(timerViewModel.timeRemaining <= 10 ? .red : .primary)
        }
        .frame(width: 100, height: 100)
    }
    
    private var progress: Double {
        Double(timerViewModel.timeRemaining) / Double(initialTime)
    }
} 
