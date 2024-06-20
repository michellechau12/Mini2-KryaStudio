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
    var gameSceneTest = GameSceneTest()
    
    let scene = GameSceneTest(fileNamed: "MazeScene")
        
    var body: some View {
        SpriteView(scene: scene!)
            .ignoresSafeArea()
            .onAppear(){
                gameScene.playerPeerId = mpManager.myConnectionId.displayName
                print("DEBUG: this player id \(String(describing: gameScene.playerPeerId))")
            }
            .onReceive(mpManager.$paired, perform: { _ in
                if mpManager.paired == false {
                    dismiss()
                }
            })
    }
}

#Preview{
    GameView()
        .environmentObject(MultipeerConnectionManager(playerId: UUID()))
        .environmentObject(GameScene())
}
