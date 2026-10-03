import SwiftUI

#if DEBUG
  struct CardImpactFoundationGallery: View {
    private let columns = [GridItem(.adaptive(minimum: 120), spacing: CardImpactSpacing.space3)]

    var body: some View {
      GeometryReader { proxy in
        ScrollView {
          VStack(alignment: .leading, spacing: CardImpactSpacing.space7) {
            heading
            palette
            typography
            primitives
            spacingScale
          }
          .frame(maxWidth: CardImpactLayout.maximumContentWidth, alignment: .leading)
          .padding(.horizontal, CardImpactLayout.screenInset(for: proxy.size.width))
          .padding(.vertical, CardImpactSpacing.space6)
          .frame(maxWidth: .infinity, alignment: .center)
        }
        .background(CardImpactColor.backgroundPrimary)
        .preferredColorScheme(.dark)
      }
    }

    private var heading: some View {
      VStack(alignment: .leading, spacing: CardImpactSpacing.space2) {
        Text("CARD IMPACT")
          .font(CardImpactTypography.screenTitle)
          .foregroundStyle(CardImpactColor.textOnDark)
        Text(
          "Foundation gallery · \(CardImpactTypography.isDisplayFontAvailable ? "Sofia Sans" : "system fallback")"
        )
        .font(CardImpactTypography.bodySmall)
        .foregroundStyle(CardImpactColor.textOnDark.opacity(0.72))
      }
    }

    private var palette: some View {
      gallerySection("SEMANTIC COLORS") {
        LazyVGrid(columns: columns, alignment: .leading, spacing: CardImpactSpacing.space3) {
          colorSwatch("BACKGROUND", CardImpactColor.backgroundElevated, CardImpactColor.textOnDark)
          colorSwatch("SURFACE", CardImpactColor.surfacePrimary, CardImpactColor.textOnLight)
          colorSwatch("PRIMARY", CardImpactColor.actionPrimary, CardImpactColor.textOnDark)
          colorSwatch("SUCCESS", CardImpactColor.success, CardImpactColor.textOnLight)
          colorSwatch("DANGER", CardImpactColor.danger, CardImpactColor.textOnLight)
          colorSwatch("WARNING", CardImpactColor.warning, CardImpactColor.textOnLight)
        }
      }
    }

    private var typography: some View {
      gallerySection("TYPE") {
        VStack(alignment: .leading, spacing: CardImpactSpacing.space4) {
          Text("ПОБЕДА")
            .font(CardImpactTypography.displayHero)
          Text("ЭЛЕКТРОСТАНЦИЯ")
            .font(CardImpactTypography.gameWord)
            .lineLimit(2)
            .minimumScaleFactor(CardImpactTypeSize.minimumGameWord / CardImpactTypeSize.gameWord)
          Text("00:20")
            .font(CardImpactTypography.gameTimer)
          Text("Интерфейсный текст остаётся спокойным и читаемым.")
            .font(CardImpactTypography.body)
        }
        .foregroundStyle(CardImpactColor.textOnLight)
        .padding(CardImpactSpacing.space5)
        .background(CardImpactColor.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: CardImpactRadius.medium, style: .continuous))
      }
    }

    private var primitives: some View {
      gallerySection("PRIMITIVES") {
        VStack(spacing: CardImpactSpacing.space6) {
          CardStack(
            shape: CutCornerRectangle(),
            underlays: [
              CardStackLayer(
                color: CardImpactColor.actionPrimary,
                offset: CGSize(width: -8, height: 8),
                rotation: .degrees(-2)
              ),
              CardStackLayer(
                color: CardImpactColor.backgroundElevated,
                offset: CGSize(width: 8, height: 14),
                rotation: .degrees(1.5)
              ),
            ]
          ) {
            FlatShadowSurface(
              shape: CutCornerRectangle(),
              faceColor: CardImpactColor.surfacePrimary,
              shadowOffset: CGSize(width: 0, height: CardImpactShadow.card),
              borderColor: CardImpactColor.borderStrong,
              borderWidth: CardImpactBorder.strong
            ) {
              Text("ФИЗИЧНЫЙ ОБЪЕКТ")
                .font(CardImpactTypography.screenTitle)
                .foregroundStyle(CardImpactColor.textOnLight)
                .multilineTextAlignment(.center)
                .padding(CardImpactSpacing.space5)
                .frame(maxWidth: .infinity, minHeight: 184)
            }
          }
          .padding(.horizontal, CardImpactSpacing.space2)

          HStack(spacing: CardImpactSpacing.space6) {
            mark(.burst, CardImpactColor.success)
            mark(.speed, CardImpactColor.actionPrimary)
            mark(.snap, CardImpactColor.danger)
          }
          .frame(maxWidth: .infinity)
        }
      }
    }

    private var spacingScale: some View {
      gallerySection("4 PT RHYTHM") {
        VStack(alignment: .leading, spacing: CardImpactSpacing.space2) {
          ForEach(Array(CardImpactSpacing.all.enumerated()), id: \.offset) { index, value in
            HStack(spacing: CardImpactSpacing.space3) {
              Text("S\(index + 1)")
                .font(CardImpactTypography.caption)
                .frame(width: 24, alignment: .leading)
              Rectangle()
                .fill(CardImpactColor.actionPrimary)
                .frame(width: value * 2, height: CardImpactSpacing.space2)
              Text("\(Int(value))")
                .font(CardImpactTypography.caption)
            }
          }
        }
        .foregroundStyle(CardImpactColor.textOnDark)
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

    private func colorSwatch(_ title: String, _ color: Color, _ textColor: Color) -> some View {
      Text(title)
        .font(CardImpactTypography.caption)
        .foregroundStyle(textColor)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .bottomLeading)
        .padding(CardImpactSpacing.space3)
        .background(color)
        .clipShape(CutCornerRectangle(cornerRadius: CardImpactRadius.small, cutSize: 12))
    }

    private func mark(_ kind: ImpactMarkKind, _ color: Color) -> some View {
      ImpactMark(kind: kind, color: color, lineWidth: CardImpactBorder.focus)
        .frame(width: 48, height: 40)
    }
  }

  #Preview("Compact · 375") {
    CardImpactFoundationGallery()
      .frame(width: 375, height: 667)
  }

  #Preview("Standard · 393") {
    CardImpactFoundationGallery()
      .frame(width: 393, height: 852)
  }

  #Preview("Large · 430") {
    CardImpactFoundationGallery()
      .frame(width: 430, height: 932)
  }
#endif
