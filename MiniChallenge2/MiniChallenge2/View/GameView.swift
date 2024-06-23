//
//  GameView.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 13/06/24.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject var gameScene: GameScene
    @EnvironmentObject var mpManager: MultipeerConnectionManager
    @Environment (\.dismiss) var dismiss
    
    @State private var isGameFinished: Bool = false
    
    var body: some View {
        NavigationStack{
            SpriteView(scene: gameScene)
                .environmentObject(gameScene)
                .environmentObject(mpManager)
                .ignoresSafeArea()
                .onAppear(){
                    gameScene.playerPeerId = mpManager.myConnectionId.displayName
                    print("DEBUG: this player id \(gameScene.playerPeerId ?? "none")")
                }
                .onReceive(mpManager.$paired, perform: { _ in
                    if mpManager.paired == false {
                        dismiss()
                    }
                })
                .onReceive(gameScene.$isGameFinished, perform: { _ in
                    if gameScene.isGameFinished == true {
                        isGameFinished = true
                    }
                })
                .navigationDestination(isPresented: $isGameFinished) {
                    GameOverView()
                }
        }
    }
}

#Preview{
    GameView()
        .environmentObject(MultipeerConnectionManager(playerId: UUID()))
        .environmentObject(GameScene())
}
