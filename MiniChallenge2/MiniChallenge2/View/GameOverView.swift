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
//    @Binding var statementGameOver : String
//    @Binding var imageGameOver : String
    
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .center){
                Text("Game Over")
                Text("Your role is \(gameScene.thisPlayer.role)")
                
                Text("Your id is \(gameScene.thisPlayer.id)")
                // Text("The winner is ... ")
                // Text(statementGameOver)
                // Image(imageGameOver)
                
                // DONE
                if gameScene.thisPlayer.role == "fbi" {
                    if gameScene.winner.id == gameScene.thisPlayer.id{
                        Text("You win.")
                    }else {
                        Text("You lose.")
                    }
                    Image("fbi-borgol-right-1")
                    Text("The winner id is \(gameScene.winner.id)")
                }
                else if gameScene.thisPlayer.role == "terrorist"{
                    if gameScene.winner.id == gameScene.thisPlayer.id{
                        Text("You win.")
                    } else {
                        Text("You lose.")
                    }
                    Image("terrorist-bom-rightt-1")
                    Text("The winner id is \(gameScene.winner.id)")
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
//    GameOverView(statementGameOver: $statementGameOver, imageGameOver: $imageGameOver)
}
