//
//  MiniChallenge2App.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 11/06/24.
//

import SwiftUI

@main
struct MiniChallenge2App: App {
        // Integrate the custom AppDelegate with SwiftUI
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
        // @StateObject var mpManager = MultipeerConnectionManager(playerName: "sample")
        @StateObject var mpManager = MultipeerConnectionManager(playerId: UUID())
        @StateObject var gameScene = GameScene(fileNamed: "MazeScene")!
        
        init(){
            _mpManager = StateObject(
                wrappedValue: MultipeerConnectionManager(
                    playerId: UUID()
                )
            )
            _gameScene = StateObject(
                wrappedValue: GameScene(fileNamed: "MazeScene") ?? GameScene()
            )
    //        _gameScene = StateObject(
    //            wrappedValue: GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    //        )
//            BACKGROUND MUSIC
            AudioManager.shared.playBackgroundMusic()
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mpManager)
                .environmentObject(gameScene)
                .onAppear{
                    AppDelegate.orientationLock = .landscape
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                            windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                    }
                }
        }
    }
}
