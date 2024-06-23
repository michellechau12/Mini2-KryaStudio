//
//  PairingView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 15/06/24.
//

import SwiftUI

struct PairingView: View {
    
    @State private var playerNames = ["John", "Mike", "Jack"]
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
                    Spacer()
                    HStack{
                        Button(
                            role: .cancel,
                            action: {
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
                            Image("playerA-img")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200)
                            Text("You")
                                .font(Font.custom("PixelifySans-Regular_SemiBold", size: 56))
                                .foregroundColor(.white)
                                .padding()
                        } .frame(width:300)
                        Image("vs-title-img")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(playerNames, id: \.self) { player in
                                    VStack {
                                        if let imageName = playerImageMapping[player] {
                                            Image(imageName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 200)
                                        }
                                        Text(player)
                                            .font(Font.custom("PixelifySans-Regular_SemiBold", size: 56))                    .foregroundColor(.white)
                                            .padding()
                                    }
                                    .padding(.leading, 50)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 120)
                    Spacer()
                }
            }
            .onAppear {
                assignImagesToPlayers()
                
            }
        }
    }
    
    private func assignImagesToPlayers() {
        for (index, player) in playerNames.enumerated() {
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
