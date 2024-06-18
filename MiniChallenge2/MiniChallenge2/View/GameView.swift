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
    var scene: SKScene {
        let scene = GameSceneTest()
        scene.size = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
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