//
//  FBIInstructionView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 17/06/24.
//

import SwiftUI

struct FBIInstructionView: View {
    @State private var navigateToGameView: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image("instruction-bg-img")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    Image("text-fbi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 800)
                    Text("Beat terrorist to win the game !")
                        .font(Font.custom("PixelifySans-Regular", size: 32))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Image("img-objective-fbi")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 600, alignment: .topLeading)
                                .padding(.bottom, 72)
                        }
                        .padding(.leading, 72)
                        
                        Spacer()
                        
                        VStack {
                            Image("fbi-none-1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 360)
                                .padding(.bottom, 60)
                                .padding(.trailing, 100)
                            
                            Button {
                                navigateToGameView = true
                            } label: {
                                Image("button-ready")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300, height: 100)
                            }
                            .padding(.trailing, 96)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $navigateToGameView) {
                GameView()
                    .environmentObject(MultipeerConnectionManager(playerId: UUID()))
                    .environmentObject(GameScene())
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    FBIInstructionView()
}