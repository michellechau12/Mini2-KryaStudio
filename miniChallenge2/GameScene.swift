//
//  GameScene.swift
//  miniChallenge2
//
//  Created by Ferris Leroy Winata on 12/06/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var character: SKSpriteNode?
    private var joystick: SKSpriteNode?
    private var joystickKnob: SKSpriteNode?
    private var cameraNode: SKCameraNode?
    private var maskNode: SKShapeNode?
    private var cropNode: SKCropNode?
    
    private var buttonNode: SKSpriteNode?
    private var timerLabel: SKLabelNode?
    var timerIsRunning = false

       
       var timer: Timer?
       var timeLeft = 60


    var speedMultiplierTerrorist = 0.05
    var speedMultiplierFBI = Int.self

    
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        
        cameraNode = SKCameraNode()
            self.camera = cameraNode
            if let camera = cameraNode {
                // Set the initial position of the camera to be centered on the character
                camera.position = character?.position ?? CGPoint(x: frame.midX, y: frame.midY)
                addChild(camera)
                                
                //Initial Map Zoom (Camera Scale)
                camera.setScale(1.5)
                
                //Supaya bisa abrupt view dari mapnya (Animation)
                let zoomInAction = SKAction.scale(to: 1, duration: 0.5)
                camera.run(zoomInAction)
            }
        
        createMaze()
        createCharacter()
        createJoystick()
        createButton()
        //setupMask()
        
        physicsWorld.contactDelegate = self
        
    }
    
    func createButton() {
           buttonNode = SKSpriteNode(imageNamed: "circleButton")
           buttonNode?.position = CGPoint(x: frame.midX, y: frame.midY)
           buttonNode?.setScale(0.5)
           buttonNode?.zPosition = 10
           buttonNode?.name = "circleButton"
           addChild(buttonNode!)
         
           timerLabel = SKLabelNode(fontNamed: "Arial")
           timerLabel?.fontSize = 45
           timerLabel?.fontColor = .white
           timerLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 100)
           timerLabel?.zPosition = 10
           timerLabel?.isHidden = true
           addChild(timerLabel!)
       }

    func startTimer() {
            timeLeft = 30
            timerLabel?.text = "\(timeLeft)"
            timerLabel?.isHidden = false

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                self.timeLeft -= 1
                self.timerLabel?.text = "\(self.timeLeft)"
                
                if self.timeLeft <= 0 {
                    timer.invalidate()
                    self.timerLabel?.isHidden = true
                    
                    //Logic untuk pindah scene misalnya (Kalah atau poin Terrorist bertambah nanti jika tidak didefuse)
                }
            }
        }
    
    
    

    func createCharacter() {
        let characterTexture = SKTexture(imageNamed: "characterTest")
        character = SKSpriteNode(texture: characterTexture)
        
           let characterWidth = characterTexture.size().width * 0.05 //
           let characterHeight = characterTexture.size().height * 0.1
           let offsetX = (frame.width - characterWidth) / 2
           let offsetY = characterHeight / 2
           let characterPosition = CGPoint(x: frame.minX + offsetX + 15, y: frame.minY + offsetY-10)
           
        character?.position = characterPosition
        character?.setScale(0.17)
        character?.zPosition = 3
        
        let scaledRadius = (characterWidth / 2) * 0.9
        
        
        //Setting manual supaya SKPhysicsBody cocok ke Character
        character?.anchorPoint = CGPoint(x: 0.495, y: 0.6)
           
        if let character = character {
               // Create a physics body that matches the visual size of the sprite
               character.physicsBody = SKPhysicsBody(circleOfRadius: scaledRadius)
               character.physicsBody?.affectedByGravity = false
               character.physicsBody?.isDynamic = true
               character.physicsBody?.allowsRotation = false
               character.physicsBody?.categoryBitMask = 1
               character.physicsBody?.collisionBitMask = 2
               character.physicsBody?.contactTestBitMask = 2
               addChild(character)
           }
    }
    
    
    
    
    
    func createMaze() {
           // Create an SKSpriteNode with the maze image
           let mazeTexture = SKTexture(imageNamed: "mazePercobaan")
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
        
        let walls = [
            CGRect(x: 30, y: -505, width: 480, height: 20),
            CGRect(x: -505, y: -505, width: 480, height: 20),
            //CGRect(x: -505, y: -505, width: 20, height: 70),
            
        ]
        
        var bodies = [SKPhysicsBody]()
        for wall in walls {
            let body = SKPhysicsBody(rectangleOf: wall.size, center: CGPoint(x: wall.midX, y: wall.midY))
            bodies.append(body)
        }

        let compoundBody = SKPhysicsBody(bodies: bodies)
        maze.physicsBody = compoundBody
        maze.physicsBody?.isDynamic = false
        maze.physicsBody?.categoryBitMask = 2
        maze.physicsBody?.collisionBitMask = 1
        addChild(maze)
       }
    
    func createJoystick() {
        
            //Otak-atik posisi Joystick
            let joystickBase = SKSpriteNode(imageNamed: "joystickBase2")
            joystickBase.position = CGPoint(x: -550, y: -380)
            joystickBase.setScale(1.5)
        
            //Alpha adalah transparency
            joystickBase.alpha = 0.5
            joystickBase.zPosition = 1
            joystickBase.name = "joystickBase2"

            let joystickKnob = SKSpriteNode(imageNamed: "joystickKnob2")
            joystickKnob.position = CGPoint(x: -550, y: -380)
            joystickKnob.setScale(1.5)
            joystickKnob.zPosition = 2
            joystickKnob.name = "joystickKnob2"

            cameraNode?.addChild(joystickBase)
            cameraNode?.addChild(joystickKnob)

            self.joystick = joystickBase
            self.joystickKnob = joystickKnob
        
    }
       
    func setupMask() {
        maskNode = SKShapeNode(circleOfRadius: 100)
        maskNode?.fillColor = .clear
        maskNode?.strokeColor = .white
        maskNode?.lineWidth = 50
        maskNode?.position = character?.position ?? CGPoint(x: frame.midX, y: frame.midY)

        cropNode = SKCropNode()
        cropNode?.maskNode = maskNode
        cropNode?.zPosition = 10
        addChild(cropNode!)

        let background = SKSpriteNode(color: .black, size: self.size)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = 5
        cropNode?.addChild(background)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == (1 | 2) {
            print("Collision Detected: Character has hit the wall.")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let buttonNode = buttonNode, buttonNode.contains(location) {
            if timerIsRunning == false {
                timerIsRunning = true
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                    self?.startTimer()
                    self?.timerIsRunning = false
                }
            }
            
            }
        
        if let joystickKnob = joystickKnob, joystickKnob.contains(location) {
            joystickKnob.position = location
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

            if let joystick = joystick, let joystickKnob = joystickKnob, let camera = cameraNode {
            
            
            //Convert Lokasi touch dari Scene ke Cam
            let convertedLocation = camera.convert(location, from: self)
            
        
            //Setup seberapa jauh Knob bisa ditarik
            let maxDistance: CGFloat = 50.0
            
            let displacement = CGVector(dx: convertedLocation.x - joystick.position.x, dy: convertedLocation.y - joystick.position.y)
                
            let distance = sqrt(displacement.dx * displacement.dx + displacement.dy * displacement.dy)
            
            if distance <= maxDistance {
                joystickKnob.position = convertedLocation
            } else {
                let angle = atan2(displacement.dy, displacement.dx)
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
        let velocity = CGVector(dx: displacement.dx * speedMultiplierTerrorist, dy: displacement.dy * speedMultiplierTerrorist)
        
        character.position = CGPoint(x: character.position.x + velocity.dx, y: character.position.y + velocity.dy)
        
        //Camera mengikuti character
        cameraNode?.position = character.position
        
        // SabotageView mengikuti character
        maskNode?.position = character.position
    }
    
}
