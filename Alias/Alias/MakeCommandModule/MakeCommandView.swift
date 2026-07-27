//
//  MakeCommandView.swift
//  Alias
//
//  Created by Ernest Avagovich on 10.02.2025.
//

import SwiftUI

struct MakeCommandView: View {
    @ObservedObject var viewModel: MakeCommandViewModel

    var body: some View {
            VStack {
                HStack {
                    ScrollViewReader(content: { proxy in
                        ScrollView {
                                ForEach(viewModel.commandNames, id: \.name) { team in
                                    HStack(content: {
                                        Text(team.name)
                                            .font(.title2)
                                            .fontWeight(.medium)
                                        Spacer(minLength: 0)
                                        if viewModel.commandNames.count > 2 {
                                            Button {
                                                withAnimation {
                                                    viewModel.removeTeam(team: team)
                                                }
                                                
                                            } label: {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.loveRed)
                                            }
                                            
                                        }
                                        
                                    })
                                    .padding(20)
                                    .background(content: {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.blueGray.opacity(0.2))
                                    })
                                    .padding(.horizontal, 20)
                                    .id(team.id)
                                    //                            .listRowBackground(.red)
                                    
                                }
                                .onChange(of: viewModel.commandNames) { _ in
                                    if let lastMessage = viewModel.commandNames.last {
                                        withAnimation {
                                            proxy.scrollTo(lastMessage.id, anchor: .bottom) // Прокручиваем к последнему элементу
                                        }
                                    }
                                }
                            }
                    })
                    Spacer(minLength: 0)
                }
                
                AliasButton(action: {
                    withAnimation {
                        viewModel.addTeam()
                    }
                }, title: "+")
                .frame(alignment: .center)
                Spacer()
                AliasButton(action: {
                    viewModel.showNext()
                }, title: "NEXT")
                .padding(.bottom, 20)
            }
            .gradientBackground(gradient: .radial)
        }
}

#Preview {
    MakeCommandView(viewModel: .init())
}
