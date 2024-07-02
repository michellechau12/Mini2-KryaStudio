//
//  PhysicsBodyExt.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

extension GameScene: SKPhysicsContactDelegate{
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if (bodyA.categoryBitMask == BitMaskCategory.player1 && bodyB.categoryBitMask == BitMaskCategory.player2) ||
            (bodyA.categoryBitMask == BitMaskCategory.player2 && bodyB.categoryBitMask == BitMaskCategory.player1) {
            print("Player 1 and Player 2 collided")
            handlePlayerCollision()
            
            // Handle collision between player1 and player2
        } else if (bodyA.categoryBitMask == BitMaskCategory.player1 && bodyB.categoryBitMask == BitMaskCategory.maze) ||
                    (bodyA.categoryBitMask == BitMaskCategory.maze && bodyB.categoryBitMask == BitMaskCategory.player1) {
            print("Player 1 collided with the maze")
            // Handle collision between player1 and the maze
        } else if (bodyA.categoryBitMask == BitMaskCategory.player2 && bodyB.categoryBitMask == BitMaskCategory.maze) ||
                    (bodyA.categoryBitMask == BitMaskCategory.maze && bodyB.categoryBitMask == BitMaskCategory.player2) {
            print("Player 2 collided with the maze")
            // Handle collision between player2 and the maze
        }
    }
    
    func handlePlayerCollision() {
//        thisPlayer.updatePlayerVulnerability()
        
        if thisPlayer.role == "fbi"{
            print("DEBUG handleplayercollision: vulnerable \(player1Model.isVulnerable), role: \(player1Model.role)")
            if player1Model.isVulnerable{
                print("DEBUG_COL : you (fbi) lose")
                gameOverByCollision(winner: "terrorist", playerRole: thisPlayer.role)
            } else {
                print("DEBUG_COL : you (fbi) win")
                gameOverByCollision(winner: "fbi", playerRole: thisPlayer.role)
            }
        }
    }
    
    func gameOverByCollision(winner: String, playerRole: String){
        self.isGameFinished = true
        
        if winner == "fbi"{
            self.winner = player1Model //fbi wins
            
//            sending multipeer
            let playerCondition = MPPlayerModel(action: .end, playerId: thisPlayer.id, playerPosition: thisPlayer.playerNode.position, playerOrientation: thisPlayer.orientation, isVulnerable: thisPlayer.isVulnerable, winnerId: self.winner.id)
            
            mpManager.send(player: playerCondition)
            
            statementGameOver = "FBI_WIN"
        } else {
            self.winner = player2Model // terrorist wins
            
//            sending multipeer
            let playerCondition = MPPlayerModel(action: .end, playerId: thisPlayer.id, playerPosition: thisPlayer.playerNode.position, playerOrientation: thisPlayer.orientation, isVulnerable: thisPlayer.isVulnerable, winnerId: self.winner.id)
            
            mpManager.send(player: playerCondition)
            
            statementGameOver = "TERRORIST_WIN"
        }
        
        if self.isGameFinished{
            removeAllNodes()
        }
    }
}

