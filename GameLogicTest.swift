//
//  GameLogicTest.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 16/06/24.
//

import SpriteKit
import SwiftUI

class GameScene2: SKScene, SKPhysicsContactDelegate {
    
    private var bombButtonPressed = false
    private var pos: CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    private var fbiNode = SKSpriteNode(imageNamed: "fbi-borgol")
    private var terroristNode = SKSpriteNode(imageNamed: "terrorist-bomb")
    private var bombNode = SKSpriteNode(imageNamed: "bomb-on")
    
    private var joystick: SKSpriteNode?
    private var joystickKnob: SKSpriteNode?
    
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
    
    private func explodeBomb(_ bomb: SKSpriteNode) {
        // Change texture or add explosion animation
        bomb.removeFromParent()
    }
    
    func setBombButtonPressed(_ pressed: Bool) {
        bombButtonPressed = pressed
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.contactDelegate = self
        
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
        
        //adding physics body outline for test
        addPhysicsBodyOutline(for:fbiNode)
        addPhysicsBodyOutline(for: terroristNode)
        
//        let wait = SKAction.wait(forDuration: 2.0)
//        let plantBomb = SKAction.run { [weak self] in
//            self?.plantBomb(at: CGPoint(x: self?.size.width ?? 0 / 2, y: self?.size.height ?? 0 / 2))
//        }
//        let sequence = SKAction.sequence([wait, plantBomb])
//        run(sequence)
    }
    
    func plantBomb(at position: CGPoint) {
        print(position)
            let bomb = SKSpriteNode(color: .white, size: CGSize(width: 30, height: 30))
            bomb.position = position
            bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
            bomb.physicsBody?.isDynamic = true
            bomb.physicsBody?.affectedByGravity = false
            bomb.physicsBody?.categoryBitMask = 4
            bomb.physicsBody?.contactTestBitMask = 1
            bomb.physicsBody?.collisionBitMask = 0
            bomb.physicsBody?.affectedByGravity = false
            bomb.physicsBody?.allowsRotation = false
            addChild(bomb)
            
            // Bomb explosion after 3 seconds
            let wait = SKAction.wait(forDuration: 3.0)
            let explode = SKAction.run { [weak self] in
                self?.explodeBomb(bomb)
            }
            let sequence = SKAction.sequence([wait, explode])
            bomb.run(sequence)
        }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        pos = touch.location(in: self)
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
        } else if firstBody.categoryBitMask == 1 && secondBody.categoryBitMask == 4 {
            if let player = firstBody.node as? SKSpriteNode, let bomb = secondBody.node as? SKSpriteNode {
                handleBombCollision(player: player, bomb: bomb)
            }
        } else if firstBody.categoryBitMask == 4 && secondBody.categoryBitMask == 1 {
            if let bomb = firstBody.node as? SKSpriteNode, let player = secondBody.node as? SKSpriteNode {
                handleBombCollision(player: player, bomb: bomb)
            }
        }
    }
    
    private func handleCollision(player: SKSpriteNode, otherPlayer: SKSpriteNode) {
        player.texture = fbiTextures[0]
        otherPlayer.texture = terroristTextures[1]
    }
    
    private func addPhysicsBodyOutline(for node: SKNode) {
        guard let physicsBody = node.physicsBody else { return }
        let shapeNode: SKShapeNode
        
        if let texture = node as? SKSpriteNode, physicsBody.usesPreciseCollisionDetection {
            shapeNode = SKShapeNode(rectOf: texture.size)
        } else if physicsBody.isDynamic {
            shapeNode = SKShapeNode(rectOf: node.frame.size)
        } else {
            shapeNode = SKShapeNode(rectOf: CGSize(width: node.frame.size.width, height: node.frame.size.height))
        }
        
        shapeNode.strokeColor = .yellow
        shapeNode.lineWidth = 2.0
        shapeNode.position = node.position
        shapeNode.zPosition = node.zPosition + 1
        addChild(shapeNode)
    }
    
    private func handleBombCollision(player: SKSpriteNode, bomb: SKSpriteNode) {
        player.texture = SKTexture(imageNamed: "bombedTexture")
        bomb.removeFromParent()
    }
    
    func getfbiPos() -> CGPoint {
        
        return pos
    
    }
}

struct GameLogicTestView: View {
    var scene: SKScene {
        let scene = GameScene2()
        scene.size = CGSize(width: 1000, height: 600)
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if let gameScene = scene as? GameScene2 {
                            print("DEBUG: Button Plant Bomb detected")
                            gameScene.setBombButtonPressed(true)
                            gameScene.plantBomb(at: gameScene.getfbiPos())
                        }
                    }) {
                        Text("Plant Bomb")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    GameLogicTestView()
}
