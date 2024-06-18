//
//  TerroristInstructionView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 17/06/24.
//

import SwiftUI

struct TerroristInstructionView: View {
    @State private var navigateToGameView: Bool = false
    let role: String // Receive the role data from RandomRoleView
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("instruction-bg-img")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Text("Playing as Terrorist")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .top)
                        .padding(.top, 48)
                    Spacer()
                    HStack {
                        VStack {
                            Text("Objectives :")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 552, alignment: .topLeading)
                                .padding()
                            Text("""
                                1. Torem ipsum dolor sit amet, consectetur adipiscing elit.
                                
                                2. Etiam eu turpis molestie, dictum est a, mattis tellus.
                                
                                3. Sed dignissim, metus nec fringilla accumsan, risus sem sollicitudin lacus, ut interdum tellus elit sed risus.
                                """)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 552, alignment: .topLeading)
                            .padding(.bottom, 72)

                        }
                        .padding(.leading, 72)
                        Spacer()
                        VStack {
                            Image("terrorist-img")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .padding(.bottom, 16)
                            .padding(.trailing, 96)
                            Button {
                                navigateToGameView = true
                            } label: {
                                Image("playbutton-img")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300, height: 100)
                            }.padding (.trailing,96)
                        }
                    }
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $navigateToGameView) {
                GameView(role: role) // Pass the role data to GameView
            }
        }
        .navigationBarBackButtonHidden(true) // Hide the back button
    }
}

#Preview {
    TerroristInstructionView(role: "terrorist")
}
