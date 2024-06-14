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
    
    override func didMove(to view: SKView) {
        setupCharacters()
        setupPhysics()
        createJoystick()
        backgroundColor = .gray
    }
    
    func setupCharacters() {
        fbiNode = SKSpriteNode(texture: fbiTextures[0])
//        fbiNode.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        fbiNode.position = CGPoint(x: size.width / 2, y: 0)
        fbiNode.setScale(0.001)
        fbiNode.name = "fbi"
        
        addChild(fbiNode)
        
        terroristNode = SKSpriteNode(texture: terroristTextures[0])
        terroristNode.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        terroristNode.name = "terrorist"
        addChild(terroristNode)
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
        
        fbiNode.physicsBody = SKPhysicsBody(rectangleOf: fbiNode.size)
        fbiNode.physicsBody?.affectedByGravity = false
        fbiNode.physicsBody?.categoryBitMask = 1
        fbiNode.physicsBody?.contactTestBitMask = 2
        fbiNode.physicsBody?.collisionBitMask = 0
        
        terroristNode.physicsBody = SKPhysicsBody(rectangleOf: terroristNode.size)
        terroristNode.physicsBody?.affectedByGravity = false
        terroristNode.physicsBody?.categoryBitMask = 2
        terroristNode.physicsBody?.contactTestBitMask = 1
        terroristNode.physicsBody?.collisionBitMask = 0
    }
    
    func handlePlayer(player: MPPlayerModel, mpManager: MultipeerConnectionManager) {
        if player.playerId == player1Id {
            fbiNode.position = player.playerPosition
            fbiNode.texture = SKTexture(imageNamed: player.playerTextureName)
        } else if player.playerId == player2Id {
            terroristNode.position = player.playerPosition
            terroristNode.texture = SKTexture(imageNamed: player.playerTextureName)
        }
    }
    
    func handleBomb(bomb: MPBombModel, mpManager: MultipeerConnectionManager) {
        if bomb.bomb == .planted {
            plantBomb(at: bomb.position)
        } else if bomb.bomb == .defused {
            defuseBomb()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        if nodeA?.name == "fbi" && nodeB?.name == "terrorist" {
            terroristNode.removeFromParent()
        } else if nodeA?.name == "terrorist" && nodeB?.name == "fbi" {
            terroristNode.removeFromParent()
        }
    }
    
    func plantBomb(at position: CGPoint) {
        bombNode = SKSpriteNode(texture: bombTextures[0])
        bombNode.position = position
        bombNode.name = "bomb"
        addChild(bombNode)
    }
    
    func defuseBomb() {
        bombNode.texture = bombTextures[1]
    }
    
    func createJoystick() {
        let joystickBase = SKSpriteNode(imageNamed: "joystickBase2")
        joystickBase.position = CGPoint(x: frame.midX - 590, y: frame.midY - 280)
        joystickBase.setScale(1.2)
        joystickBase.alpha = 0.5
        joystickBase.zPosition = 1
        joystickBase.name = "joystickBase2"
        addChild(joystickBase)
        
        let joystickKnob = SKSpriteNode(imageNamed: "joystickKnob2")
        joystickKnob.position = CGPoint(x: joystickBase.position.x, y: joystickBase.position.y)
        joystickKnob.zPosition = 2
        joystickKnob.name = "joystickKnob2"
        addChild(joystickKnob)
        
        self.joystick = joystickBase
        self.joystickKnob = joystickKnob
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let joystickKnob = joystickKnob, joystickKnob.contains(location) {
            joystickKnob.position = location
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let joystick = joystick, let joystickKnob = joystickKnob {
            let maxDistance: CGFloat = 50.0
            let displacement = CGVector(dx: location.x - joystick.position.x, dy: location.y - joystick.position.y)
            let distance = sqrt(displacement.dx * displacement.dx + displacement.dy * displacement.dy)
            let angle = atan2(displacement.dy, displacement.dx)
            
            if distance <= maxDistance {
                joystickKnob.position = location
            } else {
                joystickKnob.position = CGPoint(x: joystick.position.x + cos(angle) * maxDistance,
                                                y: joystick.position.y + sin(angle) * maxDistance)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystickKnob = joystickKnob, let joystick = joystick else { return }
        let moveBack = SKAction.move(to: joystick.position, duration: 0.1)
        moveBack.timingMode = .easeOut
        joystickKnob.run(moveBack)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        let fbiPosition = fbiNode.position
        let terroristPosition = terroristNode.position
        let bombPosition = bombNode.position
        
        let distanceToBomb = fbiPosition.distance(to: bombPosition)
        if distanceToBomb < (bombNode.size.width * 1.2) {
            fbiNode.texture = fbiTextures[1]
        } else {
            fbiNode.texture = fbiTextures[0]
        }
        
        let terroristDistanceToBomb = terroristPosition.distance(to: bombPosition)
        if terroristDistanceToBomb < (bombNode.size.width * 1.2) {
            terroristNode.texture = terroristTextures[2]
        } else {
            terroristNode.texture = terroristTextures[1]
        }
        
        updateCharacterPosition()
    }
    
    func updateCharacterPosition() {
        guard let joystick = joystick, let joystickKnob = joystickKnob else { return }
        
        let displacement = CGVector(dx: joystickKnob.position.x - joystick.position.x, dy: joystickKnob.position.y - joystick.position.y)
        let velocity = CGVector(dx: displacement.dx * 0.1, dy: displacement.dy * 0.1)
        
        fbiNode.position = CGPoint(x: fbiNode.position.x + velocity.dx, y: fbiNode.position.y + velocity.dy)
        
        if let mpManager = mpManager {
            let playerModel = MPPlayerModel(action: .move, playerId: player1Id ?? "", playerPosition: fbiNode.position, playerTextureName: fbiNode.texture?.description ?? "")
            mpManager.send(player: playerModel)
        }
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
    }
}
