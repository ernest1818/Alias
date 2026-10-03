import SwiftUI

struct MakeCommandView: View {
    @ObservedObject var viewModel: MakeCommandViewModel

    var body: some View {
        VStack(spacing: PartySpacing.standard) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: PartySpacing.medium) {
                        ForEach(viewModel.commandNames) { team in
                            HStack(spacing: PartySpacing.medium) {
                                Image(systemName: PartyIcon.team.systemName)
                                    .foregroundStyle(Color.partyLime)
                                    .frame(width: 32)

                                Text(team.name)
                                    .font(PartyTypography.section)
                                    .foregroundStyle(Color.partyPrimaryText)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.75)

                                Spacer(minLength: PartySpacing.small)

                                if viewModel.commandNames.count > 2 {
                                    Button {
                                        withAnimation { viewModel.removeTeam(team: team) }
                                    } label: {
                                        Image(systemName: PartyIcon.delete.systemName)
                                    }
                                    .buttonStyle(PartyIconButtonStyle(tint: .partyDanger))
                                    .accessibilityLabel("Удалить \(team.name)")
                                }
                            }
                            .partyCard(accent: .partyPrimaryAction)
                            .id(team.id)
                        }
                    }
                    .padding(.horizontal, PartySpacing.large)
                    .padding(.vertical, PartySpacing.standard)
                }
                .onChange(of: viewModel.commandNames) { _ in
                    if let lastTeam = viewModel.commandNames.last {
                        withAnimation { proxy.scrollTo(lastTeam.id, anchor: .bottom) }
                    }
                }
            }

            Button(action: { withAnimation { viewModel.addTeam() } }) {
                Image(systemName: PartyIcon.add.systemName)
            }
            .buttonStyle(PartyIconButtonStyle(tint: .partyLime))
            .disabled(viewModel.commandNames.count >= 5)
            .accessibilityLabel("Добавить команду")

            AliasButton(action: viewModel.showNext, title: "NEXT")
                .padding(.horizontal, PartySpacing.large)
                .padding(.bottom, PartySpacing.large)
        }
        .gradientBackground(gradient: .radial)
    }
}

#if DEBUG
    #Preview {
        MakeCommandView(viewModel: .init())
    }
#endif
