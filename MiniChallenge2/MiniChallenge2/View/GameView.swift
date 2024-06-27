//
//  GameView.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 13/06/24.
//

import SwiftUI
import SpriteKit
import Combine

struct GameView: View {
    @EnvironmentObject var gameScene: GameScene
    @EnvironmentObject var mpManager: MultipeerConnectionManager
    @Environment (\.dismiss) var dismiss
    
    @State private var isGameFinished: Bool = false
    
    var body: some View {
        NavigationStack{
            SpriteView(gameScene: gameScene)
                .environmentObject(gameScene)
                .environmentObject(mpManager)
                .ignoresSafeArea()
                .onAppear(){
                    // gameScene.playerPeerId = mpManager.myConnectionId.displayName
                    print("DEBUG: this player id \(gameScene.playerPeerId ?? "none")")
                }
                .onReceive(mpManager.$paired, perform: { _ in
                    if mpManager.paired == false {
                        dismiss()
                    }
                })
//                .onAppear(){
//                    isGameFinished = gameScene.isGameFinished
//                    print("DEBUG isGameFinished : \(isGameFinished)")
//                }
                .onAppear(){
                    // Stop Background Music
                     AudioManager.shared.stopMusic()
                    // Game Music
                    // AudioManager.shared.playGameMusic()

                }
//                .onReceive(gameScene.$isGameFinished, perform: { _ in
//                    if gameScene.isGameFinished == true {
//                        self.isGameFinished = true
//                    }
//                    print("DEBUG isGameFinished : \(self.isGameFinished)")
//                })
                .onReceive(gameScene.$isGameFinished) { value in
                    isGameFinished = value
                }
                .navigationDestination(isPresented: $isGameFinished) {
                    // GameOverView()
                    if gameScene.statementGameOver == "FBI_WIN"{
                        FBIWinningView()
                    } else if gameScene.statementGameOver == "TERRORIST_WIN"{
                        TerroristWinningView()
                    } else{
                        GameOverView()
                    }
                }
            
//                .navigationDestination(isPresented: $isGameFinished) {
//                    GameOverView(statementGameOver: $statementGameOver, imageGameOver: $imageGameOver)
//                }
        }
    }
}

#Preview{
//    GameView(statementGameOver: "You Win", imageGameOver: "fbi-borgol-right-1")
//        .environmentObject(MultipeerConnectionManager(playerId: UUID()))
//        .environmentObject(GameScene())
    
    GameView()
        .environmentObject(MultipeerConnectionManager(playerId: UUID()))
        .environmentObject(GameScene())
}
