////
////  GameView.swift
////  MiniChallenge2
////
////  Created by Tania Cresentia on 13/06/24.
////
//
//import SwiftUI
//import SpriteKit
//
//struct GameView: View {
//    @EnvironmentObject var gameScene: GameScene
//    @EnvironmentObject var mpManager: MultipeerConnectionManager
//    var gameSceneTest = GameSceneTest()
//    var scene: SKScene {
//            let scene = GameScene2()
//            scene.size = CGSize(width: 300, height: 600)
//            scene.scaleMode = .resizeFill
//            return scene
//        }
//
//        var body: some View {
//            SpriteView(scene: scene)
//                .frame(width: 300, height: 600)
//                .edgesIgnoringSafeArea(.all)
//        }
//}
//
//#Preview{
//    GameView()
//        .environmentObject(MultipeerConnectionManager(playerId: UUID()))
//        .environmentObject(GameScene())
//}
