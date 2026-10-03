import SwiftUI

#if DEBUG
  struct CardImpactControlsGallery: View {
    private let isScrollable: Bool

    @State private var targetScore = 60
    @State private var roundDuration = 20
    @State private var skipPenalty = true
    @State private var frequency = Challenge.rarely
    @State private var selectedChallenge = true

    private let challenge = ChallengeDisplayModel(
      title: "Объясняй жестами",
      instruction: "Используй только жесты и мимику.",
      symbolName: "figure.wave"
    )

    init(isScrollable: Bool = true) {
      self.isScrollable = isScrollable
    }

    var body: some View {
      GeometryReader { proxy in
        ZStack(alignment: .top) {
          CardImpactColor.backgroundPrimary

          if isScrollable {
            ScrollView {
              galleryContent(for: proxy.size.width)
            }
          } else {
            galleryContent(for: proxy.size.width)
          }
        }
        .preferredColorScheme(.dark)
      }
    }

    private func galleryContent(for width: CGFloat) -> some View {
      VStack(alignment: .leading, spacing: CardImpactSpacing.space7) {
        SetupHeader(title: "Настройки", step: 2)
        actions
        stepNavigation
        valueCards
        settings
        challengeControls
        categoryControls
        teamControls
      }
      .frame(maxWidth: CardImpactLayout.maximumContentWidth, alignment: .leading)
      .padding(.horizontal, CardImpactLayout.screenInset(for: width))
      .padding(.vertical, CardImpactSpacing.space6)
      .frame(maxWidth: .infinity, alignment: .top)
    }

    private var actions: some View {
      gallerySection("ACTIONS") {
        VStack(spacing: CardImpactSpacing.space4) {
          ImpactButton(title: "ИГРАТЬ", systemImage: "play.fill", role: .primary) {}
          ImpactButton(title: "ПРАВИЛА", role: .secondary) {}
          ImpactButton(title: "ВЫЙТИ", systemImage: "xmark", role: .destructive) {}
          ImpactButton(title: "ПРОДОЛЖИТЬ", role: .primary) {}
            .disabled(true)
          ImpactButton(title: "ПРОДОЛЖИТЬ", role: .primary, isLoading: true) {}
        }
      }
    }

    private var stepNavigation: some View {
      gallerySection("STEP NAVIGATION") {
        VStack(spacing: CardImpactSpacing.space5) {
          StepNavigationControl(
            canGoBack: true,
            canGoForward: true,
            forwardAccessibilityLabel: "Перейти к категориям",
            onBack: {},
            onForward: {}
          )
          StepNavigationControl(
            canGoBack: true,
            canGoForward: false,
            forwardAccessibilityLabel: "Перейти к категориям",
            onBack: {},
            onForward: {}
          )
          StepNavigationControl(
            canGoBack: true,
            canGoForward: true,
            isForwardLoading: true,
            forwardAccessibilityLabel: "Начать игру",
            onBack: {},
            onForward: {}
          )
        }
      }
    }

    private var valueCards: some View {
      gallerySection("VALUE CARDS") {
        HStack(alignment: .top, spacing: CardImpactSpacing.space3) {
          ValueStepperCard(
            kind: .targetScore,
            value: targetScore,
            range: 20...200,
            step: 5,
            onChange: { targetScore = $0 }
          )
          ValueStepperCard(
            kind: .roundDuration,
            value: roundDuration,
            range: 10...120,
            step: 5,
            onChange: { roundDuration = $0 }
          )
        }
      }
    }

    private var settings: some View {
      gallerySection("SETTINGS") {
        VStack(spacing: CardImpactSpacing.space2) {
          SettingRow(title: "Штраф за пропуск", isOn: $skipPenalty)
          SettingRow(
            title: "Общее последнее слово",
            explanation: "После сигнала обе команды могут отвечать.",
            isOn: .constant(false)
          )
          FrequencyPicker(selection: $frequency)
        }
      }
    }

    private var challengeControls: some View {
      gallerySection("CHALLENGES") {
        VStack(spacing: CardImpactSpacing.space3) {
          ChallengeSelectionRow(
            model: challenge,
            isSelected: selectedChallenge,
            isEnabled: true,
            action: { selectedChallenge.toggle() }
          )
          ChallengeSelectionRow(
            model: ChallengeDisplayModel(
              title: "Без однокоренных слов",
              instruction: "Не используй однокоренные подсказки.",
              symbolName: "nosign"
            ),
            isSelected: false,
            isEnabled: false,
            action: {}
          )
        }
      }
    }

    private var categoryControls: some View {
      gallerySection("CATEGORIES") {
        VStack(spacing: CardImpactSpacing.space3) {
          CategoryCard(
            title: "Лёгкое начинание",
            descriptor: "Для быстрого старта",
            isSelected: false,
            availability: .available,
            action: {}
          )
          CategoryCard(
            title: "Мозголомка",
            isSelected: true,
            availability: .available,
            action: {}
          )
          CategoryCard(
            title: "Все возможные уровни",
            isSelected: false,
            availability: .unavailable,
            action: {}
          )
        }
      }
    }

    private var teamControls: some View {
      gallerySection("TEAMS") {
        VStack(spacing: CardImpactSpacing.space3) {
          TeamCard(
            team: TeamIdentityDisplayModel(
              id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
              name: "Сверхзвуковые еноты",
              style: .violetStripe
            ),
            canRemove: true,
            onRemove: {}
          )
          TeamCard(
            team: TeamIdentityDisplayModel(
              id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
              name: "Гром",
              style: .tealSplitCircle
            ),
            canRemove: false,
            onRemove: {}
          )
          AddTeamSlot(state: .enabled, action: {})
          AddTeamSlot(state: .maximum, action: {})
        }
      }
    }

    private func gallerySection<Content: View>(
      _ title: String,
      @ViewBuilder content: () -> Content
    ) -> some View {
      VStack(alignment: .leading, spacing: CardImpactSpacing.space4) {
        Text(title)
          .font(CardImpactTypography.caption)
          .tracking(1.4)
          .foregroundStyle(CardImpactColor.textOnDark.opacity(0.72))
        content()
      }
    }
  }

  #Preview("Controls · Standard") {
    CardImpactControlsGallery()
      .frame(width: 393, height: 852)
  }

  #Preview("Controls · Accessibility 3") {
    CardImpactControlsGallery()
      .environment(\.dynamicTypeSize, .accessibility3)
      .frame(width: 393, height: 852)
  }

#endif
