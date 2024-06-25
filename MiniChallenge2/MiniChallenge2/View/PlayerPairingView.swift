//
//  PlayerPlayingView.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 12/06/24.
//

import SwiftUI
import MultipeerConnectivity

struct PlayerPairingView: View {
    @State var inviteOtherPlayer: Bool = false
    @EnvironmentObject var mpManager: MultipeerConnectionManager
    @EnvironmentObject var gameScene: GameScene
    
    @State var instructionGame: Bool = false
    @State private var sendInvitation = false
    @Environment (\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("pairing-bg-img")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    VStack {
                        Spacer()
                        HStack{
                            Button(
                                role: .cancel,
                                action: {
                                    print("DEBUG: Cancel button pressed")
                                    dismiss()
                                    mpManager.availablePlayers.removeAll()
                                    mpManager.stopBrowsing()
                                    mpManager.stopAdvertising()
                                }, label: {
                                    Image("back-button")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 140)
                                    
                                }) .padding(.leading,50)
                            Spacer()
                        }
                        Image("text-pairing")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 800)
                        Text("Make sure your Bluetooth and Wi-Fi are on")
                            .font(Font.custom("PixelifySans-Regular", size: 32))
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                            .frame(height: 80)
                        HStack {
                            Spacer()
                                .frame(width: 200)
                            VStack {
                                Image("circle-fbi-right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                                Text("\(mpManager.myConnectionId.displayName)")
                                    .font(Font.custom("PixelifySans-Regular_SemiBold", size: 56))
                                    .foregroundColor(.white)
                                    .padding()
                            } .frame(width:300)
                            Image("text-vs")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200)
                            ScrollView(.horizontal) {
                                HStack (spacing: 5) {
                                    ForEach(mpManager.availablePlayers, id: \.self) { player in
                                        AvailablePlayerCard(playerName: player.displayName, imageName: "circle-fbi-left")
                                            .onTapGesture {
                                                print("DEBUG: Touch Detected on \(player.displayName)")
                                                inviteOtherPlayer = true
                                                sendInvitation = true
                                                mpManager.searchPlayers.invitePeer(player, to: mpManager.session, withContext: nil, timeout: 20)
                                                gameScene.player1Id = mpManager.myConnectionId.displayName
                                                gameScene.player2Id = player.displayName
                                                print("DEBUG: inviteReceived \(mpManager.inviteReceived)")
                                                
                                                // Set peerId to thisPlayer
//                                                gameScene.playerPeerId = gameScene.player1Id
                                                // print("DEBUG: this player id \(gameScene.playerPeerId ?? "none")")
                                            }
                                            .scrollTransition {content, phase in content
                                                    .opacity(phase.isIdentity ? 1.0 : 0.3)
                                                    .scaleEffect(x: phase.isIdentity ? 1.0 : 0.3,
                                                                 y: phase.isIdentity ? 1.0 : 0.3)
                                                    .offset(y: phase.isIdentity ? 0 : 20)
                                            }
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .safeAreaPadding(20)
                            .contentMargins(16, for: .scrollContent)
                            .scrollTargetBehavior(.viewAligned)
                            .alert("Received invitation from  \(mpManager.inviteReceivedFrom?.displayName ?? "Unknown")", isPresented: $mpManager.inviteReceived) {
                                Button {
                                    print("DEBUG: Decline Invite")
                                    if let invitationHandler = mpManager.invitationHandler {
                                        invitationHandler(false, nil)
                                    }
                                } label: {
                                    Text("Decline Invite")
                                }
                                Button {
                                    print("DEBUG: Accept Invite from \(mpManager.inviteReceivedFrom?.displayName ?? "Unknown")")
                                    if let invitationHandler = mpManager.invitationHandler {
                                        invitationHandler(true, mpManager.session)
                                        gameScene.player1Id = mpManager.inviteReceivedFrom?.displayName ?? "Unknown"
                                        gameScene.player2Id = mpManager.myConnectionId.displayName
                                        
                                        // Set peerId to thisPlayer
                                        // gameScene.playerPeerId = gameScene.player2Id
                                        //print("DEBUG: this player id \(gameScene.playerPeerId ?? "none")")
                                    }
                                } label: {
                                    Text("Accept")
                                }
                            }
                        }
                        .padding(.bottom, 120)
                        Spacer()
                    }
                    //                .overlay(sendInvitation ? ProgressView().progressViewStyle(CircularProgressViewStyle()) : nil
                    //                )
                    .onAppear(){
                        mpManager.isAvailableToPlay = true
                        mpManager.startBrowsing()
                        mpManager.startAdvertising()
                    }
                    .onDisappear(){
                        mpManager.isAvailableToPlay = false
                        mpManager.stopBrowsing()
                        mpManager.stopAdvertising()
                    }
                    .onChange(of: mpManager.paired) { oldValue, newValue in
                        instructionGame = newValue
                        sendInvitation = false
                    }
                }
                .navigationBarBackButtonHidden(true)
                .onAppear(){
                    mpManager.setupGame(gameScene: gameScene)
                    gameScene.playerPeerId = mpManager.myConnectionId.displayName
                }
                .navigationDestination(
                    isPresented: $instructionGame) {
                        // gameScene.player1Id = mpManager.myConnectionId.displayName
                        // gameScene.player2Id = player.displayName
                        
                        
                        // player1 is FBI
                        if gameScene.player1Id == mpManager.myConnectionId.displayName {
                            FBIInstructionView()
                        }
                        // player2 is Terrorist
                        else{
                            TerroristInstructionView()
                        }
                        // GameView()
                    }
            }
        }
    }
}

struct AvailablePlayerCard: View {
    @State var playerName: String
    let imageName: String?
    
    var body: some View {
        VStack {
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
            }
            Text(playerName)
                .font(Font.custom("PixelifySans-Regular_SemiBold", size: 56))                
                .foregroundColor(.white)
                .padding()
        } .frame(width:300)
    }
}

#Preview {
    PlayerPairingView()
}



