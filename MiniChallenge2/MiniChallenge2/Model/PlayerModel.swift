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
    var cameraNode: SKCameraNode
    var playerTextures: [SKTexture]
    var playerSpawnLocation: CGPoint!
    var gameScene: GameScene
    
    init(id: String, spawnLocation: CGPoint, playerTextures: [SKTexture], gameScene: GameScene) {
        self.id = id
        self.playerTextures = playerTextures
        self.gameScene = gameScene
        cameraNode = SKCameraNode()
        cameraNode.position = spawnLocation
        cameraNode.setScale(5)
        
        playerNode = SKSpriteNode(color: UIColor.gray, size: CGSize(width: 100, height: 200))
        playerNode.position = spawnLocation
        playerSpawnLocation = spawnLocation
        
        if(self.id == gameScene.player1Id){
            playerNode.name = "Player1"
        } else {
            playerNode.name = "Player2"
        }
        
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerNode.size)
        if(self.id == gameScene.player1Id){
            playerNode.physicsBody?.categoryBitMask = 0b0
        }
    }
        
}
