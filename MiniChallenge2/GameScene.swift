//
//  GameScene.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 12/06/24.
//
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    
    var mpManager: MultipeerConnectionManager?
    
    var player1Id: String?
    var player2Id: String?
    
    var playerPeerId: String!
    var thisPlayer: PlayerModel!
    
    var player1Model: PlayerModel!
    var player2Model: PlayerModel!
    
    var host: Bool = false
    
    private var fbiNode = SKSpriteNode(imageNamed: "fbi-borgol")
    private var terroristNode = SKSpriteNode(imageNamed: "terrorist-bomb")
    private var bombNode = SKSpriteNode(imageNamed: "bomb-on")
    
    private var fbiTextures: [SKTexture] = [
        SKTexture(imageNamed: "fbi-borgol"),
        SKTexture(imageNamed: "fbi-tang")
    ]
    private var terroristTextures: [SKTexture] = [
        SKTexture(imageNamed: "terrorist-bomb"),
        SKTexture(imageNamed: "terrorist-none"),
        SKTexture(imageNamed: "terrorist-pentungan")
    ]
    private var bombTextures: [SKTexture] = [
        SKTexture(imageNamed: "bomb-on"),
        SKTexture(imageNamed: "bomb-off")
    ]
    
    override func didMove(to view: SKView) {
        createCharacters()
        setThisPlayer()
        backgroundColor = .gray
    }
    
    func createCharacters() {
        // Setup the main player
        fbiNode.position = CGPoint(x: size.width / 4, y: size.height / 2)
        fbiNode.physicsBody = SKPhysicsBody(rectangleOf: fbiNode.size)
        fbiNode.physicsBody?.affectedByGravity = false
        fbiNode.physicsBody?.isDynamic = true
        fbiNode.physicsBody?.categoryBitMask = 1
        fbiNode.physicsBody?.contactTestBitMask = 2 | 4
        fbiNode.physicsBody?.collisionBitMask = 2 | 4
        addChild(fbiNode)
        
        // Setup the other player
        terroristNode.position = CGPoint(x: size.width*3 / 4, y: size.height / 2)
        terroristNode.physicsBody = SKPhysicsBody(rectangleOf: terroristNode.size)
        terroristNode.physicsBody?.affectedByGravity = false
        terroristNode.physicsBody?.isDynamic = true
        terroristNode.physicsBody?.categoryBitMask = 2
        terroristNode.physicsBody?.contactTestBitMask = 1 | 4
        terroristNode.physicsBody?.collisionBitMask = 1 | 4
        addChild(terroristNode)
    }
    
    func setThisPlayer() {
        if playerPeerId == player1Id {
            self.thisPlayer = player1Model
        }
        else {
            self.thisPlayer = player2Model
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        movePlayer(to: location)
    }
    
    private func movePlayer(to location: CGPoint) {
        let moveAction = SKAction.move(to: location, duration: 1.0)
        fbiNode.run(moveAction)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == 1 && secondBody.categoryBitMask == 2 {
            if let player = firstBody.node as? SKSpriteNode, let otherPlayer = secondBody.node as? SKSpriteNode {
                handleCollision(player: player, otherPlayer: otherPlayer)
            }
        } else if firstBody.categoryBitMask == 2 && secondBody.categoryBitMask == 1 {
            if let otherPlayer = firstBody.node as? SKSpriteNode, let player = secondBody.node as? SKSpriteNode {
                handleCollision(player: player, otherPlayer: otherPlayer)
            }
        }
    }
    
    private func handleCollision(player: SKSpriteNode, otherPlayer: SKSpriteNode) {
        player.texture = fbiTextures[0]
        otherPlayer.texture = terroristTextures[1]
    }
    
    func handlePlayer(player: MPPlayerModel, mpManager: MultipeerConnectionManager) {
        if player.playerId == player1Id {
            fbiNode.position = player.playerPosition
            fbiNode.texture = fbiTextures[player.playerTextureIndex]
        } else if player.playerId == player2Id {
            terroristNode.position = player.playerPosition
            terroristNode.texture = terroristTextures[player.playerTextureIndex]
        }
    }
    
    func handleBomb(bomb: MPBombModel, mpManager: MultipeerConnectionManager) {
        
    }
    
//    override func update(_ currentTime: TimeInterval) {
//        
//        let fbiPosition = fbiNode.position
//        let terroristPosition = terroristNode.position
//        let bombPosition = bombNode.position
//        
//        let distanceToBomb = fbiPosition.distance(to: bombPosition)
//        if distanceToBomb < (bombNode.size.width * 1.2) {
//            fbiNode.texture = fbiTextures[1]
//        } else {
//            fbiNode.texture = fbiTextures[0]
//        }
//        
//        let terroristDistanceToBomb = terroristPosition.distance(to: bombPosition)
//        if terroristDistanceToBomb < (bombNode.size.width * 1.2) {
//            terroristNode.texture = terroristTextures[2]
//        } else {
//            terroristNode.texture = terroristTextures[1]
//        }
//        
//        updateCharacterPosition()
//    }
    
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
    }
}
