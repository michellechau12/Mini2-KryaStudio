//
//  ContentView.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 11/06/24.
//

import SwiftUI

struct ContentView: View {
    
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
//            BACKGROUND MUSIC
        AudioManager.shared.playBackgroundMusic()
    }
    
    @State var startGame: Bool = false
    
    @State private var textPosition: CGFloat = -500
    @State private var showNameInput: Bool = false
    @State private var showCredit: Bool = false
    @State private var userName: String = ""
    @State private var newName = ""

    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("bg-homeview")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Image("title-homeview")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 1000)
                        .offset(y: textPosition)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.5).delay(0)) {
                                textPosition = 100}
                        }
                    Spacer()
                    ZStack {
                        Button {
//                            showNameInput = true
                              startGame = true

                        } label: {
                            Image("button-play")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 140)
                        }
                        
                        Button {
                            showCredit = true
                        } label: {
                            Image("button-credit")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 55)
                        } .offset(x: 500)
                        
                    }
                    Spacer()
                        .frame(height:50)
                }
            }
            .onAppear() {
                startGame = false
//                mpManager.availablePlayers.removeAll()
//                mpManager.stopBrowsing()
//                mpManager.stopAdvertising()
            }
            .navigationBarBackButtonHidden(true)
//            .overlay(
//                showNameInput ? NameInputOverlay(showNameInput: $showNameInput, newName: $newName, startGame: $startGame) : nil
//            )
            .overlay(
                showCredit ? CreditOverlay(showCredit: $showCredit) : nil
            )

            .navigationDestination(isPresented: $startGame) {
                PlayerPairingView()
                    .environmentObject(mpManager)
                    .environmentObject(gameScene)
        }

        }
    }
}

#Preview {
    ContentView()
}
