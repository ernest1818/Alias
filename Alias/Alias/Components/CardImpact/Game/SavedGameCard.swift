import SwiftUI

struct SavedGameCard: View {
    let availability: SavedGameAvailability

    init(availability: SavedGameAvailability) {
        self.availability = availability
    }

    @ViewBuilder
    var body: some View {
        switch availability {
        case .available(let summary):
            savedCard(summary)
        case .invalid:
            statusCard(
                symbol: "exclamationmark.triangle.fill",
                title: "СОХРАНЕНИЕ НЕДОСТУПНО",
                message: "Начните новую игру.",
                showsProgress: false
            )
        case .checking:
            statusCard(
                symbol: "clock",
                title: "ПРОВЕРЯЕМ СОХРАНЕНИЕ",
                message: "Это займёт немного времени.",
                showsProgress: true
            )
        case .none, .loadFailed:
            EmptyView()
        }
    }

    private func savedCard(_ summary: SavedGameSummary) -> some View {
        cardSurface(faceColor: CardImpactColor.surfacePrimary, hasShadow: true) {
            HStack(spacing: CardImpactSpacing.space4) {
                ZStack {
                    CutCornerRectangle(cornerRadius: CardImpactRadius.small, cutSize: 8)
                        .fill(summary.team.style.color)

                    TeamIdentityMarker(style: summary.team.style)
                        .padding(CardImpactSpacing.space2)
                }
                .frame(width: 52, height: 52)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: CardImpactSpacing.space1) {
                    Text(summary.team.name.uppercased())
                        .font(CardImpactTypography.bodyEmphasis)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(summary.phaseLabel)
                        .font(CardImpactTypography.caption)
                        .fontWeight(.bold)

                    Text(summary.contextLabel)
                        .font(CardImpactTypography.caption)
                        .foregroundStyle(CardImpactColor.textOnLight.opacity(0.72))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(CardImpactColor.textOnLight)
            .padding(CardImpactSpacing.space4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Сохранённая игра")
        .accessibilityValue(
            "Команда \(summary.team.name). \(summary.phaseLabel). \(summary.contextLabel)."
        )
    }

    private func statusCard(
        symbol: String,
        title: String,
        message: String,
        showsProgress: Bool
    ) -> some View {
        cardSurface(faceColor: CardImpactColor.surfaceMuted, hasShadow: false) {
            HStack(spacing: CardImpactSpacing.space3) {
                if showsProgress {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(CardImpactColor.textOnLight)
                        .accessibilityHidden(true)
                } else {
                    Image(systemName: symbol)
                        .font(.system(size: 20, weight: .bold))
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: CardImpactSpacing.space1) {
                    Text(title)
                        .font(CardImpactTypography.bodyEmphasis)
                    Text(message)
                        .font(CardImpactTypography.bodySmall)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(CardImpactColor.textOnLight.opacity(0.78))
            .padding(CardImpactSpacing.space4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(message)
    }

    private func cardSurface<Content: View>(
        faceColor: Color,
        hasShadow: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let shape = CutCornerRectangle(cornerRadius: CardImpactRadius.medium, cutSize: 14)

        return ZStack {
            if hasShadow {
                shape
                    .fill(CardImpactColor.borderStrong)
                    .offset(y: CardImpactShadow.small)
            }

            shape.fill(faceColor)
            shape.strokeBorder(
                CardImpactColor.borderStrong.opacity(hasShadow ? 1 : 0.38),
                lineWidth: CardImpactBorder.strong
            )
            content()
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
