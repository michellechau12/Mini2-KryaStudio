//
//  MiniChallenge2App.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 11/06/24.
//

import SwiftUI

@main
struct MiniChallenge2App: App {
    
    @StateObject var mpManager = MultipeerConnectionManager(playerId: UUID())
    @StateObject var gameScene = GameScene()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mpManager)
                .environmentObject(gameScene)
        }
    }
}
