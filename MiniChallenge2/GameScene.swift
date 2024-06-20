//
//  GameScene.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 12/06/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    
    var mpManager: MultipeerConnectionManager!
    
    @Published var player1Id: String!
    @Published var player2Id: String!
    
    @Published var playerPeerId: String!
    @Published var thisPlayer: PlayerModel!
    
    @Published var player1Model: PlayerModel!
    @Published var player2Model: PlayerModel!
    
    @Published var host: Bool = false
    @Published var role: String = ""
    
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
    
//    private var thisCharacter: SKSpriteNode?
    private var joystick: SKSpriteNode?
    private var joystickKnob: SKSpriteNode?
    private var cameraNode: SKCameraNode?
    private var maskNode: SKShapeNode?
    private var cropNode: SKCropNode?
    
    var speedMultiplierTerrorist = 0.015
    var speedMultiplierFBI = Int.self
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Initialize player models
               if let player1Id = player1Id, let player2Id = player2Id {
                   player1Model = PlayerModel(id: player1Id, playerTextures: fbiTextures, gameScene: self)
                   player2Model = PlayerModel(id: player2Id, playerTextures: terroristTextures, gameScene: self)
               } else {
                   print("DEBUG: Player IDs are not set correctly.")
               }
        
        setThisPlayer()
        createMaze()
//        createCharacter() // deleted
        
        
        createCamera()
        createJoystick()
        
        print("DEBUG Player1id, player2id, playerpeerid")
        print(player1Id ?? "none")
        print(player2Id ?? "none")
        print(playerPeerId ?? "none")
        print("==============")
        
        //setupMask()
        
        physicsWorld.contactDelegate = self
        
        addChild(player1Model.playerNode)
        addChild(player2Model.playerNode)
    }
    
    func createCamera(){
        cameraNode = SKCameraNode()
        self.camera = cameraNode
        if let camera = cameraNode {
            // Set the initial position of the camera to be centered on the character
            camera.position = thisPlayer.playerNode.position
            addChild(camera)
            
            //Initial Map Zoom (Camera Scale) -> nanti bisa dibuat testing
            camera.setScale(1.5)
            
            //Supaya bisa abrupt view dari mapnya (Animation)
            let zoomInAction = SKAction.scale(to: 0.3, duration: 0.5)
            camera.run(zoomInAction)
        }
    }
    
    func setThisPlayer() {
        // temp: player1 is fbi, player 2 is terrorist
        
        guard let playerPeerId = playerPeerId,
                      let player1Id = player1Id,
                      let player2Id = player2Id else {
                    print("DEBUG: Player IDs are not set correctly.")
                    return
                }
        print("DEBUG: playerPeerId = \(playerPeerId)")
                print("DEBUG: player1Id = \(player1Id)")
                print("DEBUG: player2Id = \(player2Id)")
        if playerPeerId == player1Id {
            self.thisPlayer = player1Model
        }
        else if playerPeerId == player2Id {
            self.thisPlayer = player2Model
        }
    }
    
    func movePlayer(id: String, pos: CGPoint) {
        if id == player1Id {
            player1Model.synchronizePlayerPosition(position: pos)
        }
        else {
            player2Model.synchronizePlayerPosition(position: pos)
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
        
        //        maze.physicsBody = SKPhysicsBody(texture: mazeTexture, size: mazeTexture.size())
        
        //        maze.physicsBody = SKPhysicsBody(texture: mazeTexture, alphaThreshold: 0.5, size: CGSize(width: 1000, height: 1000))
        
        //        maze.physicsBody = SKPhysicsBody(texture: mazeTexture, size: CGSize(width: 1000, height: 1000))
        
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
        //        joystickBase.position = CGPoint(x: size.width / 2, y: size.width/2)
        joystickBase.position = CGPoint(x: -480, y: -310)
        joystickBase.setScale(1.5)
        joystickBase.alpha = 0.5
        joystickBase.zPosition = 80
        joystickBase.name = "joystickBase2"
        
        let joystickKnob = SKSpriteNode(imageNamed: "joystickKnob2")
        //        joystickKnob.position = CGPoint(x: size.width / 2, y: size.width/2)
        joystickKnob.position = CGPoint(x: -480, y: -310)
        joystickKnob.setScale(1.5)
        joystickKnob.zPosition = 88
        joystickKnob.name = "joystickKnob2"
        
        cameraNode?.addChild(joystickBase)
        cameraNode?.addChild(joystickKnob)
        
        self.joystick = joystickBase
        self.joystickKnob = joystickKnob
        
    }
    
    func setupMask() {
        maskNode = SKShapeNode(circleOfRadius: 150)
        maskNode?.fillColor = .white
        maskNode?.strokeColor = .clear
//        maskNode?.position = thisCharacter?.position ?? CGPoint(x: frame.midX, y: frame.midY)
        
        cropNode = SKCropNode()
        cropNode?.maskNode = maskNode
        cropNode?.zPosition = 10
        addChild(cropNode!)
        
        // Create a black background
        let background = SKSpriteNode(color: .black, size: self.size)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = 5
        cropNode?.addChild(background)  // Added to cropNode instead of scene
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
        guard let joystick = joystick, let joystickKnob = joystickKnob else { return }
        
        let displacement = CGVector(dx: joystickKnob.position.x - joystick.position.x, dy: joystickKnob.position.y - joystick.position.y)

        self.thisPlayer.movePlayer(displacement: displacement, mpManager: mpManager)
        
        print("x: \(self.thisPlayer.playerNode.position.x), y: \(self.thisPlayer.playerNode.position.y)")
        
        //Camera mengikuti character
        cameraNode?.position = thisPlayer.playerNode.position
        
        // Mask mengikuti character -> sabotage view
        maskNode?.position = thisPlayer.playerNode.position
    }
    
    func handlePlayer(player: MPPlayerModel, mpManager: MultipeerConnectionManager) {
        switch player.action {
            case .start:
                print("Start")
            case .move:
                print("Move")
                self.movePlayer(id: player.playerId, pos: player.playerPosition)
            case .collide:
                print("Start")
            case .sabotagedView:
                print("Start")
            case .plantBomb:
                print("Start")
            case .defuseBomb:
                print("Start")
            case .death:
                print("Start")
            case .reset:
                print("Start")
            case .end:
                print("Start")
            }
    }
    
    func handleBomb(bomb: MPBombModel, mpManager: MultipeerConnectionManager) {
        switch bomb.bomb {
            case .unplanted:
                print("unplanted")
            case .planted:
                print("planted")
            case .defused:
                print("defused")
        }
    }
    
}
