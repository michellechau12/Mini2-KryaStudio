//
//  ContentView.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 11/06/24.
//

import SwiftUI

struct ContentView: View {
    @State var startGame: Bool = false
    @State private var textPosition: CGFloat = -500
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("bg-img")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    Image("title-img")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 1000)
                        .offset(y: textPosition)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1).delay(1)) {
                                textPosition = -100                            }
                        }
                    
                    Spacer()
                    Button {
                        startGame = true
                    } label: {
                        Image("playbutton-img")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 100)
                            .padding()
                    }
                    Spacer()
                        .frame(height:50)
                }
                .onAppear() {
                    startGame = false
                    //mpManager.availablePlayers.removeAll()
                    //mpManager.stopBrowsing()
                    //mpManager.stopAdvertising()
                }
                
                .navigationBarBackButtonHidden(true)
                .navigationDestination(isPresented: $startGame) {
                    PlayerPairingView2()
            }
            }
        }
    }
}

#Preview {
    ContentView()
}
