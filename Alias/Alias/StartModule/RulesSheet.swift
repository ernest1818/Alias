import SwiftUI

struct RulesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var isTitleFocused: Bool
    @State private var selectedDetent: PresentationDetent = .fraction(0.64)

    private let rules: [RuleItem] = [
        RuleItem(
            number: 1,
            title: "ОБЪЯСНЯЙТЕ СЛОВО",
            detail: "Используйте синонимы, жесты и описания, чтобы команда угадала слово."
        ),
        RuleItem(
            number: 2,
            title: "НЕ НАЗЫВАЙТЕ ОДНОКОРЕННЫЕ",
            detail: "Нельзя говорить само слово, его части или однокоренные слова."
        ),
        RuleItem(
            number: 3,
            title: "УГАДАНО — ВПРАВО",
            detail: "Если команда угадала слово, отметьте его как правильный ответ."
        ),
        RuleItem(
            number: 4,
            title: "ПРОПУСК — ВЛЕВО",
            detail: "Если пропускаете слово, используйте действие пропуска."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CardImpactSpacing.space4) {
                HStack(alignment: .center, spacing: CardImpactSpacing.space4) {
                    Text("КАК ИГРАТЬ")
                        .font(CardImpactTypography.screenTitle)
                        .foregroundStyle(CardImpactColor.textOnLight)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityFocused($isTitleFocused)

                    Spacer(minLength: CardImpactSpacing.space3)

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(CardImpactColor.textOnLight)
                            .frame(width: 44, height: 44)
                            .background {
                                Circle()
                                    .fill(CardImpactColor.surfaceMuted)
                                    .overlay {
                                        Circle()
                                            .strokeBorder(
                                                CardImpactColor.borderStrong.opacity(0.18),
                                                lineWidth: CardImpactBorder.subtle
                                            )
                                    }
                                    .shadow(
                                        color: CardImpactColor.borderStrong.opacity(0.18),
                                        radius: 0,
                                        y: CardImpactShadow.small
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Закрыть правила")
                }

                VStack(spacing: CardImpactSpacing.space2) {
                    ForEach(rules) { rule in
                        RuleRow(item: rule)

                        if rule.id != rules.last?.id {
                            Rectangle()
                                .fill(CardImpactColor.borderStrong.opacity(0.14))
                                .frame(height: CardImpactBorder.subtle)
                                .accessibilityHidden(true)
                        }
                    }
                }
            }
            .frame(maxWidth: CardImpactLayout.maximumContentWidth, alignment: .leading)
            .padding(.horizontal, CardImpactSpacing.space5)
            .padding(.top, CardImpactSpacing.space2)
            .padding(.bottom, CardImpactSpacing.space6)
            .frame(maxWidth: .infinity)
        }
        .background(CardImpactColor.surfacePrimary)
        .preferredColorScheme(.light)
        .presentationBackground(CardImpactColor.surfacePrimary)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(CardImpactRadius.card)
        .presentationDetents([.fraction(0.64), .large], selection: $selectedDetent)
        .presentationContentInteraction(.scrolls)
        .task {
            isTitleFocused = true
        }
    }
}

private struct RuleItem: Identifiable {
    let number: Int
    let title: String
    let detail: String

    var id: Int { number }
}

private struct RuleRow: View {
    let item: RuleItem

    var body: some View {
        HStack(alignment: .center, spacing: CardImpactSpacing.space3) {
            Text("\(item.number)")
                .font(CardImpactTypography.screenTitle)
                .foregroundStyle(CardImpactColor.textOnLight)
                .frame(width: 52, height: 52)
                .background(numberColor)
                .clipShape(CutCornerRectangle(cornerRadius: CardImpactRadius.small, cutSize: 8))

            VStack(alignment: .leading, spacing: CardImpactSpacing.space1) {
                Text(item.title)
                    .font(CardImpactTypography.rulesItemTitle)
                    .foregroundStyle(CardImpactColor.textOnLight)
                Text(item.detail)
                    .font(CardImpactTypography.bodySmall)
                    .foregroundStyle(CardImpactColor.textOnLight.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ImpactMark(kind: .snap, color: numberColor, lineWidth: 2)
                .frame(width: 24, height: 32)
        }
        .padding(.vertical, CardImpactSpacing.space1)
        .accessibilityElement(children: .combine)
    }

    private var numberColor: Color {
        switch item.number {
        case 1: CardImpactColor.success
        case 2: CardImpactColor.actionPrimary
        case 3: CardImpactColor.danger
        default: CardImpactColor.warning
        }
    }
}

#if DEBUG
private struct RulesSheetPreviewHost: View {
    @State private var isPresented = true

    var body: some View {
        CardImpactColor.backgroundPrimary
            .ignoresSafeArea()
            .sheet(isPresented: $isPresented) {
                RulesSheet()
            }
    }
}

#Preview("Rules sheet · Stage Door") {
    RulesSheetPreviewHost()
}
#endif
