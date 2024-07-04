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
            GeometryReader { geometry in
                ZStack {
                    Image("instruction-bg-img2")
                        .resizable()
                        .scaledToFill()
                        .frame(height: geometry.size.height*1.06)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        Image("text-fbi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.7)
                        Text("Beat terrorist to win the game !")
                            .font(Font.custom("PixelifySans-Regular", size: geometry.size.width * 0.03))
                            .foregroundColor(.white)
                            .padding(.bottom, geometry.size.height * 0.01)
                        Spacer()
                        HStack {
                            VStack(alignment: .leading) {
                                Image("img-objective-fbi")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.5, alignment: .topLeading)
                                    .padding(.bottom, geometry.size.height * 0.1)
                            }
                            .padding(.leading, geometry.size.width * 0.07)
                            Spacer()
                            
                            VStack {
                                ZStack {
                                    VStack {
                                        ProgressView(value: progress, total: 1.0)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(geometry.size.width*0.002)

                                        Text("Loading...")
                                            .font(Font.custom("PixelifySans-Regular", size: geometry.size.width * 0.018))
                                            .foregroundColor(.white)
                                            .offset(y: geometry.size.height * 0.04)
                                    }
                                    .offset(y: geometry.size.height * 0.26)
                                    .offset(x: -geometry.size.width * 0.05)
                                }
                                
                            }
                        }
                        
                        Spacer()
                    }
                }
    //            .onAppear(){
    //                mpManager.setupGame(gameScene: gameScene)
    //
    //                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    //                    navigateToGameView = true
    //                    print("DEBUG: here \(mpManager.myConnectionId.displayName)")
    //                    print("DEBUG: here \(String(describing: gameScene.player1Id))")
    //                    print("DEBUG: here \(String(describing: gameScene.player2Id))")
    //                }
    //            }
                .navigationDestination(isPresented: $navigateToGameView) {
                    GameView()
    //                    .environmentObject(mpManager)
    //                    .environmentObject(gameScene)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    FBIInstructionView()
}
