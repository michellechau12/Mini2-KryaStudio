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
    
    @State private var waitingForResponse = false
    @State private var invitationAccepted = false
    @State private var invitationDeclined = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                
                let geoWidth = geometry.size.width
                let geoHeight = geometry.size.height
                
                ZStack {
                    Image("bg-img")
                        .resizable()
                        .scaledToFill()
                        .frame(height: geometry.size.height*1.06)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        VStack {
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
                                            .frame(width: geometry.size.height*0.2)
                                    }
                                ) .padding(.leading, geometry.size.width*0.03)
                                Spacer()
                            }
                            Image("text-pairing2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width*0.7)
                            
                            Text("Make sure your Bluetooth and Wi-Fi are on")
                                .font(Font.custom("PixelifySans-Regular", size: geometry.size.width * 0.03))
                                .foregroundColor(.white)
                                .padding()
                            Spacer()
                                .frame(height: geometry.size.height*0.1)
                            HStack {
                                Spacer()
                                    .frame(width: geometry.size.width*0.16)
                                AvailablePlayerCard(playerName: "You", imageName: "circle-fbi-right", geoWidth: geoWidth, geoHeight: geoHeight)
                                Image("text-vs")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:geometry.size.width*0.15)
                                ScrollView(.horizontal) {
                                    HStack () {
                                        ForEach(mpManager.availablePlayers, id: \.self) { player in
                                            AvailablePlayerCard(playerName: "Player \(String(describing: index))", imageName: "circle-terrorist-left", geoWidth: geoWidth, geoHeight: geoHeight)
                                                .onTapGesture {
                                                    print("DEBUG: Touch Detected on \(player.displayName)")
                                                    inviteOtherPlayer = true
                                                    sendInvitation = true
                                                    mpManager.searchPlayers.invitePeer(player, to: mpManager.session, withContext: nil, timeout: 20)
                                                    gameScene.player1Id = mpManager.myConnectionId.displayName
                                                    gameScene.player2Id = player.displayName
                                                    print("DEBUG: inviteReceived \(mpManager.inviteReceived)")
                                                    waitingForResponse = true // Show waiting alert
                                                    
                                                    
                                                    // Set peerId to thisPlayer
                                                    //                                                gameScene.playerPeerId = gameScene.player1Id
                                                    // print("DEBUG: this player id \(gameScene.playerPeerId ?? "none")")
                                                }
                                                .scrollTransition {content, phase in content
                                                        .opacity(phase.isIdentity ? 1.0 : 0.3)
                                                        .scaleEffect(x: phase.isIdentity ? 1.0 : 0.3,
                                                                     y: phase.isIdentity ? 1.0 : 0.3)
                                                        .offset(y: phase.isIdentity ? 0 : 10)
                                                }
                                        }
                                    }
                                    .scrollTargetLayout()
                                }
                                .frame(maxWidth: geometry.size.width*0.5)
                                .frame(minHeight: geometry.size.height*0.4)
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
                                // Waiting for response alert
                                .alert("Invitation has been sent", isPresented: $waitingForResponse) {
                                    Button {
                                        waitingForResponse = false
                                    } label: {
                                        Text("OK")
                                    }
                                } message: {
                                    Text("Waiting for response from \(gameScene.player2Id ?? "other player")")
                                }
                                
                                // Invitation accepted alert
                                .alert("Invitation accepted", isPresented: $invitationAccepted) {
                                    Button {
                                        invitationAccepted = false
                                    } label: {
                                        Text("OK")
                                    }
                                } message: {
                                    if let player2Id = gameScene.player2Id {
                                        Text("Invitation accepted by \(player2Id)")
                                    } else {
                                        Text("Invitation accepted")
                                    }
                                }
                                // Invitation declined alert
                                .alert("Invitation declined", isPresented: $invitationDeclined) {
                                    Button {
                                        invitationDeclined = false
                                    } label: {
                                        Text("OK")
                                    }
                                } message: {
                                    if let player2Id = gameScene.player2Id {
                                        Text("Invitation declined by \(player2Id)")
                                    } else {
                                        Text("Invitation declined")
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            Spacer()
                        }
                        .padding()
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
                            waitingForResponse = false
                            if newValue {
                                //                            if using invitation accepted alert
                                //                            invitationAccepted = true
                            } else {
                                invitationDeclined = true
                            }
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
                                    .environmentObject(mpManager)
                                    .environmentObject(gameScene)
                            }
                            // player2 is Terrorist
                            else{
                                TerroristInstructionView()
                                    .environmentObject(mpManager)
                                    .environmentObject(gameScene)
                            }
                            // GameView()
                        }
                }
            }
            
        }
    }
}

struct AvailablePlayerCard: View {
    @State var playerName: String
    let imageName: String?
    let geoWidth: CGFloat
    let geoHeight: CGFloat

    
    var body: some View {
        VStack {
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geoWidth * 0.22)
            }
            Text(playerName)
                .font(Font.custom("PixelifySans-Regular_SemiBold", size: geoWidth * 0.03))
                .foregroundColor(.white)
                .padding()
        } 
        .frame(width: geoWidth * 0.22)
        .frame(maxHeight: geoHeight * 0.4)
    }
}

#Preview {
    PlayerPairingView()
}
