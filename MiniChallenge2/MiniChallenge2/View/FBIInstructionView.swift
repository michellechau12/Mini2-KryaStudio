//
//  FBIInstructionView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 17/06/24.
//

import SwiftUI

struct FBIInstructionView: View {
    
    @EnvironmentObject var mpManager: MultipeerConnectionManager
    @EnvironmentObject var gameScene: GameScene
    
    @State private var progress = 0.0
    @State private var isAnimatingProgress = false
    
    
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
                            ZStack {
                                Image("fbi-none-1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 360)
                                    .padding(.bottom, 130)
                                    .padding(.trailing, 100)
                                
                                VStack {
                                    ProgressView(value: progress, total: 1.0)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(3)
                                    
                                    Text("Loading...")
                                        .font(Font.custom("PixelifySans-Regular", size: 18))
                                        .foregroundColor(.white)
                                        .offset(y: 30)
                                }
                                .offset(y:260)
                                .offset(x:140)
                                
                            }
                            
                        }
                    }
                    
                    Spacer()
                }
            }
            .onAppear(){
                mpManager.setupGame(gameScene: gameScene)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    navigateToGameView = true
                    print("DEBUG: here \(mpManager.myConnectionId.displayName)")
                    print("DEBUG: here \(String(describing: gameScene.player1Id))")
                    print("DEBUG: here \(String(describing: gameScene.player2Id))")
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
    FBIInstructionView()
}
