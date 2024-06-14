//
//  ContentView.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 11/06/24.
//

import SwiftUI

struct ContentView: View {
    @State var startGame: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    startGame = true
                } label: {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .tint(.green)
            }
            .onAppear() {
                startGame = false
                //mpManager.availablePlayers.removeAll()
                //mpManager.stopBrowsing()
                //mpManager.stopAdvertising()
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $startGame) {
                PlayerPairingView()
            }
        }
    }
}

#Preview {
    ContentView()
}
