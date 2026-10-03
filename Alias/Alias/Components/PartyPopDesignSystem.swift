import SwiftUI

enum PartyColorToken: CaseIterable {
    case background
    case elevated
    case spotlight
    case primaryAction
    case coral
    case lime
    case yellow
    case success
    case danger
    case info
    case primaryText
    case secondaryText

    var hex: String {
        switch self {
        case .background: return "193564"
        case .elevated: return "244777"
        case .spotlight, .info: return "5182BC"
        case .primaryAction, .coral, .danger: return "DC3C24"
        case .lime, .yellow, .success, .secondaryText: return "E6BF98"
        case .primaryText: return "F6E8DD"
        }
    }

    var color: Color {
        let value = UInt64(hex, radix: 16) ?? 0
        return Color(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: 1
        )
    }
}

enum PartySpacing {
    static let xSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let standard: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
    static let xxLarge: CGFloat = 40

    static let all: [CGFloat] = [xSmall, small, medium, standard, large, xLarge, xxLarge]
}

enum PartyRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 20
    static let large: CGFloat = 28
    static let full: CGFloat = 1_000

    static let all: [CGFloat] = [small, medium, large, full]
}

enum PartyLayout {
    static let minimumTouchTarget: CGFloat = 44
    static let maximumContentWidth: CGFloat = 560
}

enum PartyTypography {
    static let timer = Font.system(size: 64, weight: .heavy, design: .rounded)
    static let display = Font.system(size: 48, weight: .bold, design: .rounded)
    static let screenTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let section = Font.system(size: 24, weight: .bold, design: .rounded)
    static let button = Font.system(size: 20, weight: .bold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let caption = Font.system(size: 13, weight: .regular, design: .default)
}

enum PartyIcon: CaseIterable {
    case play
    case pause
    case add
    case delete
    case back
    case forward
    case settings
    case rules
    case correct
    case skip
    case trophy
    case team
    case timer
    case challenge
    case whisper
    case robotVoice
    case commentator
    case scaryStory
    case slowly
    case noGestures
    case noFillerWords
    case shortSentences
    case firstPerson
    case imagineOpening

    var systemName: String {
        switch self {
        case .play: return "play.fill"
        case .pause: return "pause.fill"
        case .add: return "plus"
        case .delete: return "trash.fill"
        case .back: return "chevron.left"
        case .forward: return "chevron.right"
        case .settings: return "gearshape.fill"
        case .rules: return "book.closed.fill"
        case .correct: return "checkmark"
        case .skip: return "xmark"
        case .trophy: return "trophy.fill"
        case .team: return "person.3.fill"
        case .timer: return "timer"
        case .challenge, .imagineOpening: return "sparkles"
        case .whisper: return "speaker.wave.1"
        case .robotVoice: return "cpu"
        case .commentator: return "mic"
        case .scaryStory: return "moon.stars"
        case .slowly: return "tortoise"
        case .noGestures: return "hand.raised.slash"
        case .noFillerWords: return "text.bubble"
        case .shortSentences: return "text.line.first.and.arrowtriangle.forward"
        case .firstPerson: return "person.fill"
        }
    }
}

extension Color {
    static let partyBackground = PartyColorToken.background.color
    static let partyElevated = PartyColorToken.elevated.color
    static let partySpotlight = PartyColorToken.spotlight.color
    static let partyPrimaryAction = PartyColorToken.primaryAction.color
    static let partyCoral = PartyColorToken.coral.color
    static let partyLime = PartyColorToken.lime.color
    static let partyYellow = PartyColorToken.yellow.color
    static let partySuccess = PartyColorToken.success.color
    static let partyDanger = PartyColorToken.danger.color
    static let partyInfo = PartyColorToken.info.color
    static let partyPrimaryText = PartyColorToken.primaryText.color
    static let partySecondaryText = PartyColorToken.secondaryText.color
}

struct PartyCardModifier: ViewModifier {
    var accent: Color?

    func body(content: Content) -> some View {
        content
            .padding(PartySpacing.standard)
            .background(Color.partyElevated)
            .clipShape(RoundedRectangle(cornerRadius: PartyRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PartyRadius.medium, style: .continuous)
                    .stroke(accent?.opacity(0.7) ?? Color.white.opacity(0.1), lineWidth: accent == nil ? 1 : 2)
            }
            .shadow(color: .black.opacity(0.22), radius: 12, y: 8)
    }
}

extension View {
    func partyCard(accent: Color? = nil) -> some View {
        modifier(PartyCardModifier(accent: accent))
    }
}

struct PartyPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(PartyTypography.button)
            .foregroundStyle(Color.partyPrimaryText)
            .frame(maxWidth: .infinity, minHeight: PartyLayout.minimumTouchTarget)
            .padding(.horizontal, PartySpacing.large)
            .padding(.vertical, PartySpacing.small)
            .background(isEnabled ? Color.partyPrimaryAction : Color.partySpotlight)
            .clipShape(RoundedRectangle(cornerRadius: PartyRadius.full, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PartyRadius.full, style: .continuous)
                    .stroke(Color.white.opacity(isEnabled ? 0.18 : 0.08), lineWidth: 1)
            }
            .shadow(color: isEnabled ? Color.partyPrimaryAction.opacity(0.38) : .clear, radius: 12, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(isEnabled ? 1 : 0.48)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

struct PartySecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let tint: Color

    init(tint: Color = .partyPrimaryAction) {
        self.tint = tint
    }

    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(PartyTypography.button)
            .foregroundStyle(isEnabled ? Color.partyPrimaryText : Color.partySecondaryText)
            .frame(maxWidth: .infinity, minHeight: PartyLayout.minimumTouchTarget)
            .padding(.horizontal, PartySpacing.large)
            .padding(.vertical, PartySpacing.small)
            .background(Color.partyElevated)
            .clipShape(RoundedRectangle(cornerRadius: PartyRadius.full, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PartyRadius.full, style: .continuous)
                    .stroke(tint.opacity(isEnabled ? 0.8 : 0.25), lineWidth: 2)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(isEnabled ? 1 : 0.48)
    }
}

struct PartyIconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let tint: Color

    init(tint: Color = .partyPrimaryAction) {
        self.tint = tint
    }

    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundStyle(isEnabled ? tint : Color.partySecondaryText)
            .frame(minWidth: PartyLayout.minimumTouchTarget, minHeight: PartyLayout.minimumTouchTarget)
            .background(Color.partyElevated)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(tint.opacity(isEnabled ? 0.45 : 0.15), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(isEnabled ? 1 : 0.48)
    }
}
