//
//  GameView.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 13/06/24.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    var role: String
    @EnvironmentObject var gameScene: GameScene
    @EnvironmentObject var mpManager: MultipeerConnectionManager
    var gameSceneTest = GameSceneTest()
    
    var body: some View {
//        Text("Game View")
        SpriteView(scene: gameSceneTest)
            .scaledToFit()
            .ignoresSafeArea()
    }
}

#Preview{
    GameView(role: "terrorist")
        .environmentObject(MultipeerConnectionManager(playerId: UUID()))
        .environmentObject(GameScene())
}
