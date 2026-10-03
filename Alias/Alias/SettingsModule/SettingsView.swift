import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var isChallengePickerExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: PartySpacing.standard) {
                    sliderView(
                        title: "Количество слов",
                        subtitle: "необходимое для достижения победы",
                        icon: .trophy,
                        slideRange: 20...200,
                        slideValue: $viewModel.wordsCount,
                        step: 5
                    )

                    sliderView(
                        title: "Время раунда",
                        subtitle: "в секундах",
                        icon: .timer,
                        slideRange: 10...120,
                        slideValue: $viewModel.roundTimer,
                        step: 5
                    )

                    switchView(
                        title: "Штраф за пропуск",
                        subtitle: "минус 1 очко",
                        switchValue: $viewModel.isSkipPenalty
                    )

                    switchView(
                        title: "Общее последнее слово",
                        subtitle: "последнее слово могут отгадывать все команды",
                        switchValue: $viewModel.islastWordForAllTeam
                    )

                    challengeFrequencyView
                    challengeSelectionView

                    switchView(
                        title: "Звук в игре",
                        subtitle: "включить эффекты",
                        switchValue: $viewModel.isSoundOn
                    )
                }
                .padding(.horizontal, PartySpacing.large)
                .padding(.vertical, PartySpacing.standard)
            }

            AliasButton(action: viewModel.showNext, title: "Next")
                .disabled(!viewModel.canContinue)
                .padding(.horizontal, PartySpacing.large)
                .padding(.top, PartySpacing.medium)
                .padding(.bottom, PartySpacing.large)
        }
        .gradientBackground()
    }

    private func sliderView(
        title: String,
        subtitle: String,
        icon: PartyIcon,
        slideRange: ClosedRange<Double>,
        slideValue: Binding<Double>,
        step: Double
    ) -> some View {
        VStack(spacing: PartySpacing.standard) {
            HStack(spacing: PartySpacing.medium) {
                Image(systemName: icon.systemName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.partyYellow)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: PartySpacing.xSmall) {
                    Text(title)
                        .font(PartyTypography.body.weight(.semibold))
                    Text(subtitle)
                        .font(PartyTypography.caption)
                        .foregroundStyle(Color.partySecondaryText)
                }

                Spacer(minLength: PartySpacing.small)

                Text("\(Int(slideValue.wrappedValue))")
                    .font(PartyTypography.section)
                    .foregroundStyle(Color.partyLime)
            }

            Slider(value: slideValue, in: slideRange, step: step)
                .tint(.partyPrimaryAction)
        }
        .partyCard()
    }

    private var challengeFrequencyView: some View {
        VStack(spacing: PartySpacing.standard) {
            HStack(spacing: PartySpacing.medium) {
                Image(systemName: PartyIcon.challenge.systemName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.partyCoral)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: PartySpacing.xSmall) {
                    Text("Задания")
                        .font(PartyTypography.body.weight(.semibold))
                    Text("при объяснении слов")
                        .font(PartyTypography.caption)
                        .foregroundStyle(Color.partySecondaryText)
                }

                Spacer()

                VStack(spacing: PartySpacing.xSmall) {
                    Text(viewModel.challenge.smile)
                        .font(PartyTypography.section)
                    Text(viewModel.challenge.title)
                        .font(PartyTypography.caption)
                        .foregroundStyle(Color.partySecondaryText)
                }
            }

            Slider(
                value: Binding(
                    get: { viewModel.challenge.rawValue },
                    set: { viewModel.challenge = Challenge.from($0) }
                ),
                in: Challenge.off.rawValue...Challenge.always.rawValue,
                step: 1
            )
            .tint(.partyCoral)
        }
        .partyCard()
    }

    private var challengeSelectionView: some View {
        VStack(alignment: .leading, spacing: PartySpacing.small) {
            DisclosureGroup(isExpanded: $isChallengePickerExpanded) {
                VStack(spacing: PartySpacing.medium) {
                    HStack {
                        Button("Выбрать все", action: viewModel.selectAllChallenges)
                        Spacer()
                        Button("Очистить", action: viewModel.clearChallenges)
                    }
                    .font(PartyTypography.caption.weight(.semibold))
                    .foregroundStyle(Color.partyLime)

                    ForEach(viewModel.availableChallenges) { challenge in
                        challengeRow(challenge)
                    }
                }
                .padding(.top, PartySpacing.medium)
            } label: {
                VStack(alignment: .leading, spacing: PartySpacing.xSmall) {
                    Text("Выбор заданий")
                        .font(PartyTypography.body.weight(.semibold))
                    Text("Выбрано: \(viewModel.selectedChallenges.count) из \(viewModel.availableChallenges.count)")
                        .font(PartyTypography.caption)
                        .foregroundStyle(Color.partySecondaryText)
                }
            }
            .tint(.partyPrimaryAction)
            .disabled(viewModel.challenge == .off)
            .opacity(viewModel.challenge == .off ? 0.48 : 1)

            if viewModel.challenge != .off && viewModel.selectedChallenges.isEmpty {
                Text("Выберите хотя бы одно задание")
                    .font(PartyTypography.caption)
                    .foregroundStyle(Color.partyDanger)
            }
        }
        .partyCard(accent: viewModel.canContinue ? nil : .partyDanger)
    }

    private func challengeRow(_ challenge: GameChallenge) -> some View {
        Button {
            viewModel.toggleChallenge(challenge)
        } label: {
            HStack(spacing: PartySpacing.medium) {
                Image(systemName: challenge.symbolName)
                    .frame(width: 28)
                    .foregroundStyle(Color.partyCoral)

                VStack(alignment: .leading, spacing: 3) {
                    Text(challenge.title)
                        .font(PartyTypography.body.weight(.medium))
                    Text(challenge.instruction)
                        .font(PartyTypography.caption)
                        .foregroundStyle(Color.partySecondaryText)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: PartySpacing.small)

                Image(systemName: viewModel.isChallengeSelected(challenge) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(viewModel.isChallengeSelected(challenge) ? Color.partyLime : Color.partySecondaryText)
            }
            .frame(minHeight: PartyLayout.minimumTouchTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func switchView(
        title: String,
        subtitle: String,
        switchValue: Binding<Bool>
    ) -> some View {
        Toggle(isOn: switchValue) {
            VStack(alignment: .leading, spacing: PartySpacing.xSmall) {
                Text(title)
                    .font(PartyTypography.body.weight(.semibold))
                Text(subtitle)
                    .font(PartyTypography.caption)
                    .foregroundStyle(Color.partySecondaryText)
            }
        }
        .tint(.partyLime)
        .partyCard()
    }
}

#if DEBUG
    #Preview {
        SettingsView(viewModel: .init(teams: []))
    }
#endif
