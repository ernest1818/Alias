import SwiftUI

struct TimerView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    let initialTime: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.partySpotlight, lineWidth: 12)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    timerViewModel.timeRemaining <= 10 ? Color.partyDanger : Color.partyInfo,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            Text("\(timerViewModel.timeRemaining)")
                .font(PartyTypography.timer)
                .foregroundStyle(timerViewModel.timeRemaining <= 10 ? Color.partyDanger : Color.partyPrimaryText)
                .minimumScaleFactor(0.65)
        }
        .frame(width: 132, height: 132)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Осталось времени")
        .accessibilityValue("\(timerViewModel.timeRemaining) секунд")
    }

    private var progress: Double {
        guard initialTime > 0 else { return 0 }
        return Double(timerViewModel.timeRemaining) / Double(initialTime)
    }
}
