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
    
    @State var startGame: Bool = false
    @State private var sendInvitation = false
    @Environment (\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Text("Finding Other Player...")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    
                    List(mpManager.availablePlayers, id: \.self) { player in
                        AvailablePlayerCard(playerName: player.displayName)
                            .onTapGesture {
                                print("DEBUG: Touch Detected")
                                inviteOtherPlayer = true
                                mpManager.searchPlayers.invitePeer(player, to: mpManager.session, withContext: nil, timeout: 20)
                                gameScene.player1Id = mpManager.myConnectionId.displayName
                                gameScene.player2Id = player.displayName
                                print("DEBUG: inviteReceived \(mpManager.inviteReceived)")
                            }
                            .listStyle(.plain)
                            .alert("Received invitation from  \(mpManager.inviteReceivedFrom? .displayName ?? "Unknown")", isPresented: $mpManager.inviteReceived) {
                                Button {
                                    if let invitationHandler = mpManager.invitationHandler {
                                        invitationHandler(false, nil)
                                    }
                                } label: {
                                    Text("Decline Invite")
                                }
                                
                                Button {
                                    if let invitationHandler = mpManager.invitationHandler {
                                        invitationHandler(true, mpManager.session)
                                        gameScene.player1Id = mpManager.inviteReceivedFrom? .displayName ?? "Unknown"
                                        gameScene.player2Id = mpManager.myConnectionId.displayName
                                    }
                                } label: {
                                    Text("Accept")
                                }
                            }
                    }
                }
                .overlay(sendInvitation ? ProgressView().progressViewStyle(CircularProgressViewStyle()) : nil
                )
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
                    startGame = newValue
                    sendInvitation = false
                }
                
                Button(
                    role: .cancel,
                    action: {
                        dismiss()
                        mpManager.availablePlayers.removeAll()
                        mpManager.stopBrowsing()
                        mpManager.stopAdvertising()
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    })
                .buttonStyle(BorderedProminentButtonStyle())
                .tint(Color.red)
            }
            .padding(.horizontal, 30)
            .navigationBarBackButtonHidden(true)
            .onAppear(){
                mpManager.setupGame(gameScene: gameScene)
            }
            .navigationDestination(
                isPresented: $startGame) {
                    GameView()
                }
        }
        
        
    }
}

struct AvailablePlayerCard: View {
    @State var playerName: String
    
    var body: some View {
        VStack {
            Rectangle()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Text(playerName)
                .font(.title)
        }
    }
}

#Preview {
    PlayerPairingView()
}



