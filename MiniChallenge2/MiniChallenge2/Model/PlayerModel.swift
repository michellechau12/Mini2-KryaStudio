//
//  PlayerModel.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 12/06/24.
//

import Foundation
import SpriteKit

class PlayerModel: ObservableObject {
    @Published var id: String
    @Published var playerNode: SKSpriteNode
    
    var playerTextures: [SKTexture]
    var gameScene: GameScene
    var speedMultiplier: Double
    var isVulnerable: Bool
    var role: String
    
    init(id: String, playerTextures: [SKTexture], gameScene: GameScene) {
        self.id = id
        self.playerTextures = playerTextures
        self.gameScene = gameScene
        self.speedMultiplier = 0
        self.isVulnerable = true
        self.role = ""
        
        playerNode = SKSpriteNode(color: UIColor.gray, size: CGSize(width: 10, height: 10))
        playerNode.zPosition = 3
        print("DEBUG")
        print("===========================")
        print("player 1 id: \(gameScene.player1Id ?? "none")")
        print("player 2 id: \(gameScene.player2Id ?? "none")")
        print("this player id: \(self.id)")
        if(self.id == gameScene.player1Id){
            playerNode.name = "Player1"
            playerNode.position = CGPoint(x: 557.45, y: 825.29)
            speedMultiplier = 0.045
            isVulnerable = false
            role = "fbi"
        } else {
            playerNode.name = "Player2"
            playerNode.position = CGPoint(x: 594.05, y: -1.89)
            speedMultiplier = 0.0303
            isVulnerable = true
            role = "terrorist"
        }
        
//        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerNode.size)
        //note for bitmask:
        // 1 = player 1 (fbi)
        // 2 = player 2 (terrorist)
        // 3 = player 3 (maze)
        if(self.id == gameScene.player1Id){
            playerNode.texture = playerTextures[0]
            playerNode.physicsBody?.categoryBitMask = 1
            playerNode.physicsBody?.contactTestBitMask = 2 | 3
            playerNode.physicsBody?.collisionBitMask = 2 | 3
        } else if (self.id == gameScene.player2Id){
            playerNode.texture = playerTextures[0]
            playerNode.physicsBody?.categoryBitMask = 2
            playerNode.physicsBody?.contactTestBitMask = 1 | 3
            playerNode.physicsBody?.collisionBitMask = 1 | 3
        }
        playerNode.anchorPoint = CGPoint(x: 0.495, y: 0.6)
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width / 2)
        playerNode.physicsBody?.affectedByGravity = false
        playerNode.physicsBody?.isDynamic = true
        playerNode.physicsBody?.allowsRotation = false
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func movePlayer(displacement: CGVector, mpManager: MultipeerConnectionManager) {
        let velocity = CGVector(dx: displacement.dx * speedMultiplier, dy: displacement.dy * speedMultiplier)
        
        playerNode.physicsBody?.velocity = velocity
        
        //sending the movement to multipeer
        let playerCondition = MPPlayerModel(action: .move, playerId: self.id, playerPosition: playerNode.position, playerTextureIndex: 0, isVulnerable: false)
        mpManager.send(player: playerCondition)
    }
    
    func synchronizePlayerPosition(position: CGPoint) {
        playerNode.position = position
    }
    
    func plantBomb() {
        
    }
}
