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
    @State var statementGameOver : String = ""
    @State var imageGameOver : String = ""
    
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .center){
                Text("Game Over")
                Text("Your role is \(gameScene.thisPlayer.role)")
                
                Text("Your id is \(gameScene.thisPlayer.id)")
                // Text("The winner is ... ")
                Text(statementGameOver)
                Image(imageGameOver)
                
                Button{
                    playAgain = true
                } label:{
                    Text("Play Again")
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .onAppear(){
                statementGameOver = gameScene.statementGameOver
                imageGameOver = gameScene.imageGameOver
                
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
//    GameOverView(statementGameOver: $statementGameOver, imageGameOver: $imageGameOver)
}
