//
//  PlayerPairingView2.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 16/06/24.
//

import SwiftUI
import MultipeerConnectivity

struct PlayerPairingView2: View {
    
    @State var inviteOtherPlayer: Bool = false
    @EnvironmentObject var mpManager: MultipeerConnectionManager
    @EnvironmentObject var gameScene: GameScene
    
    @State var startGame: Bool = false
    @State private var sendInvitation = false
    @Environment (\.dismiss) private var dismiss
    
    //    @State private var availablePlayers = ["John", "Mike", "Jack"]
    @State private var playerImages = ["playerB-img", "playerC-img", "playerA-img"]
    @State private var playerImageMapping: [String: String] = [:]
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Image("pairing-bg-img")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Pairing with Your Enemy ...")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                        .padding()
                    HStack {
                        Spacer()
                            .frame(width: 200)
                        VStack {
                            Image("playerA-img")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200)
                            Text("You")
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                        } .frame(width:300)
                        Image("vs-title-img")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(mpManager.availablePlayers, id: \.self) { player in
                                    let playerName = String(player.displayName.prefix(4))
                                    let imageName = playerImageMapping[playerName]
                                    AvailablePlayerCard2(playerName: playerName, imageName: imageName)
                                        .padding(.leading, 50)
                                        .onTapGesture {
                                            print("DEBUG: Touch Detected on \(playerName)")
                                            inviteOtherPlayer = true
                                            sendInvitation = true
                                            mpManager.searchPlayers.invitePeer(player, to: mpManager.session, withContext: nil, timeout: 20)
                                            gameScene.player1Id = mpManager.myConnectionId.displayName
                                            gameScene.player2Id = player.displayName
                                            print("DEBUG: inviteReceived \(mpManager.inviteReceived)")
                                        }
                                }
                            }
                        }
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
                                }
                            } label: {
                                Text("Accept")
                            }
                        }
                    }
                    Button(
                        role: .cancel,
                        action: {
                            print("DEBUG: Cancel button pressed")
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
                .overlay(sendInvitation ? ProgressView().progressViewStyle(CircularProgressViewStyle()) : nil)
                .onAppear {
                    print("DEBUG: View appeared")
                    assignImagesToPlayers()
                    mpManager.isAvailableToPlay = true
                    mpManager.startBrowsing()
                    mpManager.startAdvertising()
                }
                .onDisappear {
                    print("DEBUG: View disappeared")
                    mpManager.isAvailableToPlay = false
                    mpManager.stopBrowsing()
                    mpManager.stopAdvertising()
                }
                .onChange(of: mpManager.paired) { oldValue, newValue in
                    print("DEBUG: Paired changed from \(oldValue) to \(newValue)")
                    startGame = newValue
                    sendInvitation = false
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                print("DEBUG: Setting up game")
                mpManager.setupGame(gameScene: gameScene)
            }
            .navigationDestination(isPresented: $startGame) {
                GameView()
            }
        }
    }
    
    private func assignImagesToPlayers() {
        print("DEBUG: Assigning images to players")
        for (index, player) in mpManager.availablePlayers.enumerated() {
            let playerName = String(player.displayName.prefix(4)) // Extract first 4 characters of player name
            if playerImageMapping[playerName] == nil {
                let imageIndex = index % playerImages.count
                playerImageMapping[playerName] = playerImages[imageIndex]
                print("DEBUG: Assigned \(playerImages[imageIndex]) to \(playerName)")
            }
        }
    }
}

struct AvailablePlayerCard2: View {
    let playerName: String
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
                .font(.system(size: 56, weight: .bold))
                .foregroundColor(.white)
                .padding()
        }
    }
}
//
//struct PlayerPairingView2_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerPairingView2()
//            .environmentObject(MultipeerConnectionManager())
//            .environmentObject(GameScene())
//    }
//}
