//
//  FBIWinningView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 23/06/24.
//

import SwiftUI

struct FBIWinningView: View {
    
    @State private var textPosition: CGFloat = -500
    @State private var showBlackScreen: Bool = false
    @State private var fbiImagePosition: CGFloat = UIScreen.main.bounds.width
    @State private var playAgain: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("fbi-winning-view")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                if showBlackScreen {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                }
                
                VStack{
                    Image("text-win-fbi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 800)
                        .offset(y: textPosition)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1).delay(1.5)) {
                                textPosition = 0
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    showBlackScreen = true
                                }
                                
                                withAnimation(.easeOut(duration: 1).delay(1.8)) {
                                    fbiImagePosition = 500
                                }
                            }
                        }
                    
                    Button{
                        playAgain = true
                    } label: {
                        Image("button-playagain")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                    }
                }
                
                Image("fbi-none-strokewhite 1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 600)
                    .offset(x: fbiImagePosition)
                    .offset(y: 300)
            }
            .navigationDestination(isPresented: $playAgain) {
                ContentView()
            }
        }
        .onAppear(){
            AudioManager.shared.stopWalkSound()
            AudioManager.shared.stopBombTimerSound()
            
            AudioManager.shared.stopMusic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                AudioManager.shared.playFbiWinningMusic()
            }
        }
    }
}

#Preview {
    FBIWinningView()
}

