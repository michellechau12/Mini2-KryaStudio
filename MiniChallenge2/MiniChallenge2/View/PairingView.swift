//
//  PairingView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 15/06/24.
//

import SwiftUI

struct PairingView: View {
    
    @State private var availablePlayers = ["John", "Mike", "Jack"]
    @State private var playerImages = ["playerB-img", "playerC-img", "playerA-img"]
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
                                    ForEach(availablePlayers, id: \.self) { player in
                                        VStack {
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
                                        .padding(.leading, 50)
                                    }
                                }
                            }
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
