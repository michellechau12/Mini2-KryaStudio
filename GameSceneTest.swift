//
//  GameScene.swift
//  miniChallenge2
//
//  Created by Ferris Leroy Winata on 12/06/24.
//

import SpriteKit
import GameplayKit

class GameSceneTest: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var character: SKSpriteNode?
    private var joystick: SKSpriteNode?
    private var joystickKnob: SKSpriteNode?
    
    private var fbiTexture: [SKTexture] = [
        SKTexture(imageNamed: "fbi-borgol"),
        SKTexture(imageNamed: "fbi-tang")
    ]
    private var terroristTexture: [SKTexture] = [
        SKTexture(imageNamed: "terrorist-bomb"),
        SKTexture(imageNamed: "terrorist-none"),
        SKTexture(imageNamed: "terrorist-pentungan")
    ]
    private var bombTexture: [SKTexture] = [
        SKTexture(imageNamed: "bomb-on"),
        SKTexture(imageNamed: "bomb-off")
    ]
    
    func createCharacter() {
        
        
        let characterTexture = SKTexture(imageNamed: "fbi-borgol")
        character = SKSpriteNode(texture: characterTexture)
        
        let characterWidth = characterTexture.size().width * 0.05
        let characterHeight = characterTexture.size().height * 0.05
        let offsetX = (frame.width - characterWidth) / 2
        let offsetY = characterHeight / 2
        let characterPosition = CGPoint(x: frame.minX + offsetX + 15, y: frame.minY + offsetY-10)
        
        character?.position = characterPosition
        character?.setScale(0.2)
        
        // Add the character to the scene
        if let character = character {
            character.physicsBody = SKPhysicsBody(circleOfRadius: characterWidth / 2)
            character.physicsBody?.allowsRotation = false
            character.physicsBody?.affectedByGravity = false
            character.physicsBody?.categoryBitMask = 1
            character.physicsBody?.collisionBitMask = 2
            character.physicsBody?.contactTestBitMask = 2
            character.physicsBody?.affectedByGravity = false
            character.physicsBody?.isDynamic = true
            addChild(character)
        }
    }
    
    func createMaze() {
        // Create an SKSpriteNode with the maze image
        let mazeTexture = SKTexture(imageNamed: "mazeTest")
        let maze = SKSpriteNode(texture: mazeTexture)
        
        // Set the position of the maze to the center of the screen
        maze.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // Adjust the size of the maze to fit the screen while maintaining the aspect ratio
        let screenWidth = frame.size.width
        let screenHeight = frame.size.height
        let textureWidth = mazeTexture.size().width
        let textureHeight = mazeTexture.size().height
        
        let scaleX = (screenWidth / textureWidth) + 60
        let scaleY = screenHeight / textureHeight
        let scale = min(scaleX, scaleY)
        
        maze.setScale(scale)
        
        // Add the maze to the scene
        maze.physicsBody = SKPhysicsBody(texture: mazeTexture, size: maze.size)
        maze.physicsBody?.isDynamic = false
        maze.physicsBody?.categoryBitMask = 2
        maze.physicsBody?.collisionBitMask = 1
        maze.physicsBody?.contactTestBitMask = 1
        
        addChild(maze)
    }
    
    func createJoystick() {
        
        //Otak-atik posisi Joystick
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
        joystickKnob.zPosition = 2
        joystickKnob.name = "joystickKnob2"
        addChild(joystickKnob)
        
        self.joystick = joystickBase
        self.joystickKnob = joystickKnob
    }
    
    
    override func didMove(to view: SKView) {
        
        createMaze()
        createCharacter()
        createJoystick()
        
    }
    
//    func didBegin(_ contact: SKPhysicsContact) {
//        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
//        if collision == (1 | 2) {
//            // Character collided with the maze wall, stop the character's movement
//            character?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
//        }
//    }
    
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
        guard let character = character, let joystick = joystick, let joystickKnob = joystickKnob else { return }
        
        let displacement = CGVector(dx: joystickKnob.position.x - joystick.position.x, dy: joystickKnob.position.y - joystick.position.y)
        let velocity = CGVector(dx: displacement.dx * 0.1, dy: displacement.dy * 0.1)
        
        character.position = CGPoint(x: character.position.x + velocity.dx, y: character.position.y + velocity.dy)
    }
}
