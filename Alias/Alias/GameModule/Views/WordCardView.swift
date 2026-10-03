import AudioToolbox
import SwiftUI

struct WordCardView: View {
    let word: String
    var onCorrect: () -> Void
    var onSkip: () -> Void

    @State private var offset: CGSize = .zero
    @State private var dragColor: Color = .partyElevated
    @State private var opacity: CGFloat = 1
    private let generator = UIImpactFeedbackGenerator(style: .rigid)

    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: PartyRadius.large, style: .continuous)
                .fill(dragColor)
                .overlay {
                    RoundedRectangle(cornerRadius: PartyRadius.large, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 2)
                }
                .shadow(color: Color.partyPrimaryAction.opacity(0.24), radius: 18, y: 10)
                .overlay {
                    Text(word)
                        .font(PartyTypography.display)
                        .foregroundStyle(Color.partyPrimaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.55)
                        .padding(PartySpacing.large)
                }
                .offset(x: offset.width)
                .gesture(dragGesture(in: geometry))
                .opacity(opacity)
                .accessibilityLabel(word)
                .accessibilityHint("Смахните вправо, если слово угадано, или влево, чтобы пропустить")
        }
        .aspectRatio(3 / 2, contentMode: .fit)
        .padding(.horizontal, PartySpacing.large)
        .onAppear(perform: generator.prepare)
    }

    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
                let percentage = offset.width / max(geometry.size.width, 1)
                dragColor = percentage > 0
                    ? Color.partySuccess.opacity(0.45 + min(Double(percentage), 0.5))
                    : Color.partyDanger.opacity(0.45 + min(Double(-percentage), 0.5))
            }
            .onEnded { value in
                let percentage = value.translation.width / max(geometry.size.width, 1)
                if percentage > 0.3 {
                    resolveWord(targetOffset: geometry.size.width + 100, action: onCorrect)
                } else if percentage < -0.3 {
                    resolveWord(targetOffset: -geometry.size.width - 100, action: onSkip)
                } else {
                    withAnimation {
                        offset = .zero
                        dragColor = .partyElevated
                    }
                }
            }
    }

    private func resolveWord(targetOffset: CGFloat, action: () -> Void) {
        withAnimation(.easeOut(duration: 0.3)) { offset.width = targetOffset }
        opacity = 0
        offset = .zero
        action()
        generator.impactOccurred()
        AudioServicesPlaySystemSound(1104)
        dragColor = .partyElevated
        withAnimation(.easeOut(duration: 0.5)) { opacity = 1 }
    }
}
