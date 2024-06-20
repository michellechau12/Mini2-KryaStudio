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
    
    @AppStorage("yourName") var yourName : String = ""
    
    @State private var userName = ""
    @State private var changeName = false
    @State private var newName = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Text("Finding Other Player...")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    
                    Text("Your name is \(userName)")
                        .font(.largeTitle)
                        .foregroundStyle(.yellow)
                    
                    if changeName {
                        TextField("Enter new name", text: $newName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Save Name") {
                            saveNewName()
                        }
                        .padding()
                        .buttonStyle(BorderedButtonStyle())
                    } else {
                        Button("Change Name") {
                            changeName.toggle()
                        }
                        .padding()
                        .buttonStyle(BorderedButtonStyle())
                    }

                    
                    List(mpManager.availablePlayers, id: \.self) { player in
                        AvailablePlayerCard(playerName: player.displayName)
                            .onTapGesture {
                                print("DEBUG: Touch Detected")
                                inviteOtherPlayer = true
                                mpManager.searchPlayers.invitePeer(player, to: mpManager.session, withContext: nil, timeout: 20)
                                gameScene.player1Id = mpManager.myConnectionId.displayName
                                gameScene.player2Id = player.displayName
                                
                                print("===========================")
                                print("DEBUG: player1Id \( gameScene.player1Id ?? "none")")
                                print("DEBUG: player2Id \( gameScene.player2Id ?? "none")")
                                print("DEBUG: inviteReceived \(mpManager.inviteReceived)")
                                print("===========================")
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
                    userName = mpManager.myConnectionId.displayName
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
    
    func saveNewName() {
        if !newName.isEmpty {
            yourName = newName
            userName = newName
            changeName.toggle()
            
            mpManager.updatePeerID(with: newName)
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
    PlayerPairingView(yourName: "Sample")
}



