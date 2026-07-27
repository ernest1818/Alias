//
//  ContentView.swift
//  Alias
//
//  Created by Ernest Avagovich on 16.01.2025.
//

import SwiftUI
struct EntranceGroup: Identifiable {
    let id: Int
    let name: String
    let route: Route
}

struct EntranceView: View {
    
    @ObservedObject var viewModel: EntranceViewModel
    
    var body: some View {
            VStack {
                Text("Alias")
                    .foregroundStyle(.white)
                    .font(.superCrownXXL)
                    .padding(40)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 6)
                    .background {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                        
                            
//                            .clipShape(Circle())
                        
                    }
                    .background{
                        ZStack {
                            Color.greenButtonBackground
                            Group {
                                Circle()
                                    .fill(.greenRight)
                                    .overlay(content: {
                                        Rectangle()
                                            .fill(Color(.greenLeft))
                                            .rotationEffect(.degrees(55))
                                            .frame(width: 200, height: 200)
                                            .offset(x: -90, y: 40)
                                    })
                                    
                                    .clipShape(Circle())
                            }
                                    .offset(y: -10)
                        }
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 8)
                        
                    }
                    
                
                
                Spacer()
                ForEach(viewModel.menus, id: \.name) { name in
                    AliasButton(action: {
                        viewModel.router.add(route: name.route)
                    }, title: name.name)
                    .padding(.top, 10)
                }
                
            }
            .padding()
            .gradientBackground()
        }
}

#Preview {
    EntranceView(viewModel: EntranceViewModel())
}
