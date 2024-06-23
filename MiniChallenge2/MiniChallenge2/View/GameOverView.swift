//
//  GameOverView.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 23/06/24.
//

import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var mpManager: MultipeerConnectionManager
    @EnvironmentObject var gameScene: GameScene
    
    @State var playAgain: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .center){
                Text("Game Over")
                Text("The winner is ... ")
                if gameScene.winner.id == gameScene.player1Id{
                    Image("fbi-borgol-right-1")
                } else {
                    Image("terrorist-bomb-right-1")
                }
                
                Button{
                    playAgain = true
                } label:{
                    Text("Play Again")
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .onAppear(){
                playAgain = false
                mpManager.stopBrowsing()
                mpManager.stopAdvertising()
                mpManager.availablePlayers.removeAll()
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $playAgain) {
                ContentView()
            }
        }
    }
}

#Preview {
    GameOverView()
}
