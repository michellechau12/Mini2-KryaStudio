//
//  TerroristWinningView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 23/06/24.
//

import SwiftUI

struct TerroristWinningView: View {
    
    @State private var textPosition: CGFloat = -100
    @State private var showBlackScreen: Bool = false
    @State private var terroristImagePosition: CGFloat = UIScreen.main.bounds.width
    @State private var playAgain: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Image("terrorist-winning-view")
                        .resizable()
                        .scaledToFill()
                        .frame(height: geometry.size.height*1.06)
                        .edgesIgnoringSafeArea(.all)
                    
                    if showBlackScreen {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                    }
                    
                    VStack {
                        Image("text-win-terrorist")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.7)
                            .offset(y: textPosition)
                            .onAppear {
                                textPosition = -geometry.size.height
                                withAnimation(.easeOut(duration: 1).delay(1.5)) {
                                    textPosition = geometry.size.height * 0.018
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation {
                                        showBlackScreen = true
                                    }
                                    
                                    withAnimation(.easeOut(duration: 1).delay(1.8)) {
                                        terroristImagePosition = geometry.size.width*0.5
                                    }
                                }
                            }
                        
                        Button{
                            playAgain = true
                        } label: {
                            Image("button-playagain")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.1)
                        }
                    }
                    
                    Image("terrorist-none-strokewhite 1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.5)
                        .offset(x: terroristImagePosition)
                        .offset(y: UIScreen.main.bounds.height*0.4)
                }
                .navigationDestination(isPresented: $playAgain) {
                    ContentView()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
        .onAppear(){
            AudioManager.shared.stopWalkSound()
            AudioManager.shared.stopBombTimerSound()
            
            AudioManager.shared.stopMusic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                AudioManager.shared.playTerroristWinningMusic()
            }
        }
    }
}

#Preview {
    TerroristWinningView()
}
