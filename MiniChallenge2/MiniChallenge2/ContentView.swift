//
//  ContentView.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 11/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isLandscape = UIDevice.current.orientation.isLandscape
    
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
//            BACKGROUND MUSIC
        AudioManager.shared.playBackgroundMusic()
    }
    

    @State var startGame: Bool = false
    
    @State private var textPosition: CGFloat = 0
    @State private var showNameInput: Bool = false
    @State private var showCredit: Bool = false
    @State private var userName: String = ""
    @State private var newName = ""
    @State private var isMuted: Bool = false


    
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                ZStack {
                    Image("bg-img")
                        .resizable()
                        .scaledToFill()
                        .frame(height: geometry.size.height*1.06)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        Image("title-homeview")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.8)
                            .offset(y: textPosition)
                            .onAppear {
                                textPosition = -geometry.size.height
                                withAnimation(.easeOut(duration: 1.5).delay(0)) {
                                    textPosition = geometry.size.height * 0.18}
                            }
                        Spacer()
                        ZStack {
                            ZStack {
                                Button {
        //                            showNameInput = true
                                      startGame = true

                                } label: {
                                    Image("button-play")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.15)

                                }
                                
                                Button {
                                    showCredit = true
                                } label: {
                                    Image("button-credit")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.06)

                                } .offset(x: geometry.size.width * 0.12, y: geometry.size.height * 0.06)
                                
                                Button {
                                    isMuted.toggle()
                                    AudioManager.shared.toggleMute()
                                } label: {
                                    Image(isMuted ? "button-mute" : "button-unmute")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.06)
                                }
                                .offset(x: -geometry.size.width * 0.12, y: geometry.size.height * 0.06)
                            }
                            .offset(y: -geometry.size.height*0.1)
                            ZStack {
                                Image("fbi-none-1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.32)
                                    .offset(x: geometry.size.width * 0.2)

                                Image("terrorist-none-right-1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.32)
                                    .offset(x: -geometry.size.width * 0.2)
                                

                            }
                            .offset(y:geometry.size.height*0.3)
                        }
                        Spacer()
                    }
                }
                .onAppear() {
                    startGame = false
    //                mpManager.availablePlayers.removeAll()
    //                mpManager.stopBrowsing()
    //                mpManager.stopAdvertising()
                    
                    // Listen for device orientation changes
                    NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                        if UIDevice.current.orientation.isPortrait {
                            // Force landscape if the device is rotated to portrait
                            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                            }
                        }
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
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
}

#Preview {
    ContentView()
//        .environmentObject(MultipeerConnectionManager(playerName: "sample"))
//        .environmentObject(MultipeerConnectionManager(playerId: UUID()))
//        .environmentObject(GameScene())
}
