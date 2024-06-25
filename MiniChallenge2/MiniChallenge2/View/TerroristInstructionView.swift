//
//  TerroristInstructionView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 23/06/24.
//

import SwiftUI

struct TerroristInstructionView: View {
    @EnvironmentObject var mpManager: MultipeerConnectionManager
    @EnvironmentObject var gameScene: GameScene
    
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
                    Image("text-terrorist")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 800)
                    Text("Beat FBI to win the game !")
                        .font(Font.custom("PixelifySans-Regular", size: 32))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Image("img-objective-terrorist")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 600, alignment: .topLeading)
                                .padding(.bottom, 72)
                        }
                        .padding(.leading, 72)
                        
                        Spacer()
                        
                        VStack {
                            Image("terrorist-none-left-1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 360)
                                .padding(.bottom, 60)
                                .padding(.trailing, 100)
                            
//                            Button {
//                                navigateToGameView = true
//                            } label: {
//                                Image("button-ready")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 300, height: 100)
//                            }
//                            .padding(.trailing, 96)
                        }
                    }
                    
                    Spacer()
                }
            }
            .onAppear(){
                mpManager.setupGame(gameScene: gameScene)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    navigateToGameView = true
                    print("DEBUG: heree!")
                }
            }
            .navigationDestination(isPresented: $navigateToGameView) {
                GameView()
                    .environmentObject(mpManager)
                    .environmentObject(gameScene)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TerroristInstructionView()
}
