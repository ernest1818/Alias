//
//  SettingsView.swift
//  Alias
//
//  Created by Ernest Avagovich on 16.02.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    @State private var isChallengePickerExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 40) {
                    sliderView(
                        title: "Количество слов",
                        subtitle: "необходимое для достижения победы",
                        slideRange: 20...200,
                        slideValue: $viewModel.wordsCount,
                        step: 5.0
                    )
                    
                    sliderView(
                        title: "Время раунда",
                        subtitle: "в секундах",
                        slideRange: 10...120,
                        slideValue: $viewModel.roundTimer,
                        step: 5
                    )
                    
                    someSwitchView(
                        title: "Штраф за пропуск",
                        subtitle: "минус 1 очко",
                        switchValue: $viewModel.isSkipPenalty
                    )
                    
                    someSwitchView(
                        title: "Общее последнее слово",
                        subtitle: "последнее слово могут отгадывать все команды",
                        switchValue: $viewModel.islastWordForAllTeam
                    )
                    
                    challengeFrequencyView

                    challengeSelectionView
                    
                    someSwitchView(
                        title: "Звук в игре",
                        subtitle: "включить эффекты",
                        switchValue: $viewModel.isSoundOn
                    )
                }
                .padding(.horizontal)
                .padding(.vertical)
            }

            AliasButton(action: {
                viewModel.showNext()
            }, title: "Next")
                .disabled(!viewModel.canContinue)
                .opacity(viewModel.canContinue ? 1 : 0.5)
                .padding(.top, 12)
                .padding(.bottom, 20)
        }
        .gradientBackground()
    }
    
    private func sliderView(
        title: String,
        subtitle: String,
        slideRange: ClosedRange<Double>,
        slideValue: Binding<Double>,
        step: Double = 1
    ) -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title3)
                    Text(subtitle)
                        .font(.footnote)
                }
                Spacer(minLength: 0)
                
                Text("\(Int(slideValue.wrappedValue))")
                    .font(.largeTitle)
            }
            Slider(value: slideValue, in: slideRange, step: step)
                .padding(.horizontal, 30)

        }
    }

    private var challengeFrequencyView: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Задания")
                        .font(.title3)
                    Text("при объяснении слов")
                        .font(.footnote)
                }
                Spacer(minLength: 0)
                VStack {
                    Text(viewModel.challenge.smile)
                        .font(.largeTitle)
                    Text(viewModel.challenge.title)
                        .font(.footnote)
                }
            }

            Slider(
                value: Binding(
                    get: { viewModel.challenge.rawValue },
                    set: { newValue in
                        viewModel.challenge = Challenge.from(newValue)
                    }
                ),
                in: Challenge.off.rawValue...Challenge.always.rawValue,
                step: 1
            )
            .padding(.horizontal, 30)
        }
    }

    private var challengeSelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            DisclosureGroup(isExpanded: $isChallengePickerExpanded) {
                VStack(spacing: 12) {
                    HStack {
                        Button("Выбрать все") {
                            viewModel.selectAllChallenges()
                        }
                        Spacer()
                        Button("Очистить") {
                            viewModel.clearChallenges()
                        }
                    }
                    .font(.footnote.weight(.semibold))

                    ForEach(viewModel.availableChallenges) { challenge in
                        challengeRow(challenge)
                    }
                }
                .padding(.top, 12)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Выбор заданий")
                            .font(.title3)
                        Text("Выбрано: \(viewModel.selectedChallenges.count) из \(viewModel.availableChallenges.count)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .tint(.veryPeri)
            .disabled(viewModel.challenge == .off)
            .opacity(viewModel.challenge == .off ? 0.5 : 1)

            if viewModel.challenge != .off && viewModel.selectedChallenges.isEmpty {
                Text("Выберите хотя бы одно задание")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }

    private func challengeRow(_ challenge: GameChallenge) -> some View {
        Button {
            viewModel.toggleChallenge(challenge)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: challenge.symbolName)
                    .frame(width: 28)
                    .foregroundStyle(.veryPeri)

                VStack(alignment: .leading, spacing: 3) {
                    Text(challenge.title)
                        .font(.body.weight(.medium))
                    Text(challenge.instruction)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: viewModel.isChallengeSelected(challenge) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(viewModel.isChallengeSelected(challenge) ? .veryPeri : .secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func someSwitchView(
        title: String,
        subtitle: String,
        switchValue: Binding<Bool>
    ) -> some View {
        HStack {
            Toggle(isOn: switchValue, label: {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title3)
                    Text(subtitle)
                        .font(.footnote)
                }
            })
            .tint(.veryPeri)
        }
    }
}

#Preview {
    SettingsView(viewModel: .init(teams: []))
}
