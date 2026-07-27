import SwiftUI
import AVFoundation
import AudioToolbox

struct WordCardView: View {
    let word: String
    var onCorrect: () -> Void
    var onSkip: () -> Void
    
    @State private var offset: CGSize = .zero
    @State private var color: Color = .white
    @State private var opacity: CGFloat = 1
    let generator = UIImpactFeedbackGenerator(style: .rigid)
    
    
    var body: some View {
        GeometryReader { geometry in
            let dragGesture = DragGesture()
                .onChanged { value in
                    offset = value.translation
                    
                    // Change color based on drag direction
                    let dragPercentage = offset.width / geometry.size.width
                    if dragPercentage > 0 {
                        color = .green.opacity(Double(dragPercentage))
                        print("___1")
                    } else {
                        color = .red.opacity(Double(-dragPercentage))
                        print("___2")
                    }
                }
                .onEnded { value in
                    
                    let dragPercentage = value.translation.width / geometry.size.width
                    
                    
                    if dragPercentage > 0.3 {
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset.width = geometry.size.width + 100
                            print("___3")
                        }
                        opacity = 0
                        offset = .zero
                        onCorrect()
                        Task {
                            await playHaptic()
                            await playSound()
                        }
                        color = .white
                        withAnimation(.easeOut(duration: 0.5)) {
                            opacity = 1
                        }
                    } else if dragPercentage < -0.3 {
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset.width = -geometry.size.width - 100
                            print("___4")
                        }
                        opacity = 0
                        offset = .zero
                        onSkip()
                        Task {
                            await playHaptic()
                            await playSound()
                        }
                        color = .white
                        withAnimation {
                            opacity = 1
                        }
                    } else {
                        withAnimation {
                            offset = .zero
                            color = .white
                        }
                    }
                }
            
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .shadow(color: .gray, radius: 7, x: 1, y: 2)
                .overlay(
                    Text(word)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.primary)
                )
                .offset(x: offset.width)
                .gesture(dragGesture)
                .opacity(opacity)
        }
        .aspectRatio(3/2, contentMode: .fit)
        .padding()
        .onAppear {
            generator.prepare()
        }
    }
    
    private func playHaptic() async {
        generator.impactOccurred()
    }
    
    private func playSound() async {
        AudioServicesPlaySystemSound(1104) // "tick" звук
    }
}
