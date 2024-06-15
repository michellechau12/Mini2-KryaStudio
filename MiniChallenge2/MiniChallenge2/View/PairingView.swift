//
//  PairingView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 15/06/24.
//

import SwiftUI

struct PairingView: View {
    
    @State private var availablePlayers = ["John", "Mike", "Jack"]
    @State private var playerImages = ["playerA-img", "playerB-img", "playerC-img"]
    @State private var playerImageMapping: [String: String] = [:]
    
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                
                Image("pairing-bg-img")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
                    Text("Pairing with Your Enemy ...")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                        .padding()
                    ZStack {
                        HStack {
                            VStack {
                                Image("playerA-img")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                                Text("You")
                                    .font(.system(size: 56, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding()
                            } .frame(width:600)
                            List(availablePlayers, id: \.self) { player in
                                HStack {
                                    if let imageName = playerImageMapping[player] {
                                        Image(imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200)
                                    }
                                    Text(player)
                                        .font(.system(size: 56, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding()
                                }
                                .listRowBackground(Color.clear)
                            }
                            .listStyle(PlainListStyle())
                            .background(Color.clear)
                            .padding(.leading, 20)

                        }
                        Image("vs-title-img")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            .padding()
                            .offset(x: -50)
                    }
                }
            }
            .onAppear {
                assignImagesToPlayers()
                
            }
        }
    }
    
    private func assignImagesToPlayers() {
        for (index, player) in availablePlayers.enumerated() {
            if playerImageMapping[player] == nil {
                let imageIndex = index % playerImages.count
                playerImageMapping[player] = playerImages[imageIndex]
            }
        }
    }
}

#Preview {
    PairingView()
}
