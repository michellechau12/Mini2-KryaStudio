//
//  GameScene.swift
//  miniChallenge2
//
//  Created by Ferris Leroy Winata on 12/06/24.
//

import SpriteKit
import GameplayKit
import SwiftUI

class GameSceneTest: SKScene, SKPhysicsContactDelegate {
    
    var mpManager: MultipeerConnectionManager?
    
    var fbiTexture = SKTexture(imageNamed: "fbi-borgol-right-1")
    
    let fbiSpawnPoint = CGPoint(x: 3.57, y: 945.85)
    let terroristSpawnPoint = CGPoint(x: 48.57, y: -354)
    
    var player1Id: String!
    var player2Id: String!
    
    var playerPeerId: String!
    var thisPlayer: PlayerModel!
    
    var player1Model: PlayerModel!
    var player2Model: PlayerModel!
    
    var host: Bool = false
    var role: String = "fbi"
    
    private var timerLabel: SKLabelNode?
    var timerIsRunning = false
    
    var timer: Timer?
    var timeLeft = 30
    
    private var bombPlantTimer: Timer?
    private var bombPlantTimerStartTime: Date?
    
    private var defuseTimer: Timer?
    private var defuseTimerStartTime: Date?
    
    // Define texture arrays for animations
    private var fbiRightTextures: [SKTexture] = [
        SKTexture(imageNamed: "fbi-borgol-right-1"),
        SKTexture(imageNamed: "fbi-borgol-right-2"),
        SKTexture(imageNamed: "fbi-borgol-right-3"),
        SKTexture(imageNamed: "fbi-borgol-right-4"),
        SKTexture(imageNamed: "fbi-borgol-right-5")
    ]
    
    private var fbiLeftTextures: [SKTexture] = [
        SKTexture(imageNamed: "fbi-borgol-left-1"),
        SKTexture(imageNamed: "fbi-borgol-left-2"),
        SKTexture(imageNamed: "fbi-borgol-left-3"),
        SKTexture(imageNamed: "fbi-borgol-left-4"),
        SKTexture(imageNamed: "fbi-borgol-left-5")
    ]
    
    
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
    
    private var character: SKSpriteNode = SKSpriteNode(imageNamed: "fbi-borgol-right-1")
    private var joystick: SKSpriteNode?
    private var joystickKnob: SKSpriteNode?
    private var cameraNode: SKCameraNode?
    private var maskNode: SKShapeNode?
    private var cropNode: SKCropNode?
    
    
    var speedMultiplierTerrorist = 3.0
    var speedMultiplierFBI = Int.self
    
    private var bombSites: [BombSiteModel] = []
    private let playerCatNode = SKSpriteNode(imageNamed: "player_cat")
    private let plantButton = SKSpriteNode(imageNamed: "plantButton")
    private let defuseButton = SKSpriteNode(imageNamed: "defuseButton")
    private var isBombPlanted = false
    private var defuseRadius: CGFloat = 50.0
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        cameraNode = SKCameraNode()
        self.camera = cameraNode
        if let camera = cameraNode {
            // Set the initial position of the camera to be centered on the character
            camera.position = character.position
            addChild(camera)
            
            //Initial Map Zoom (Camera Scale) -> nanti bisa dibuat testing
            camera.setScale(1.5)
            
            //Supaya bisa abrupt view dari mapnya (Animation)
            let zoomInAction = SKAction.scale(to: 0.3, duration: 0.5)
            camera.run(zoomInAction)
        }
        
        setupMapPhysics()
        setupBombSites()
        createCharacter()
        //        setThisPlayer()
        createJoystick()
        setupPlantButton()
        setupDefuseButton()
        // sabotagedView()
        setupTimerLabel()
        physicsWorld.contactDelegate = self
    }
    
    func setupMapPhysics() {
        //map physics body:
        let map = childNode(withName: "Maze") as! SKTileMapNode
        
        let tileMap = map // the tile map to be given physics body
        let tileSize = tileMap.tileSize // the size of each tile map
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width // half width of tile map
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height // half height of tile map
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    
                    let isEdgeTile = tileDefinition.userData?["AddBody"] as? Int
                    if isEdgeTile == 1 {
                        let tileArray = tileDefinition.textures //get the tile textures in array
                        let tileTexture = tileArray[0] //get the first texture
                        let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width/2)
                        let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height/2)
                        let tileNode = SKNode()
                        
                        tileNode.position = CGPoint(x: x, y: y)
                        tileNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (tileTexture.size().width), height: tileTexture.size().height))
                        tileNode.physicsBody?.affectedByGravity = false
                        tileNode.physicsBody?.allowsRotation = false
                        tileNode.physicsBody?.restitution = 0
                        tileNode.physicsBody?.isDynamic = false
                        
                        tileNode.physicsBody?.mass = 30.0
                        tileNode.physicsBody?.categoryBitMask = 1
                        tileNode.physicsBody?.contactTestBitMask = 2
                        tileNode.physicsBody?.collisionBitMask = 1
                        
                        tileMap.addChild(tileNode)
                    }
                }
            }
        }
    }
    
    // Setup bombsite
    func setupBombSites() {
        for child in self.children {
            if child.name == "BombSite" { //Di setup di MazeScene
                if let child = child as? SKSpriteNode {
                    let bombSitePosition = child.position
                    let bombSiteSize = child.size
                    let bombSite = BombSiteModel(
                        position: bombSitePosition,
                        size: bombSiteSize)
                    bombSites.append(bombSite)
                }
            }
        }
    }
    
    func setThisPlayer() {
        // temp: player1 is fbi, player 2 is terrorist
        if playerPeerId == player1Id {
            self.thisPlayer = player1Model
            role = "fbi"
        }
        else {
            self.thisPlayer = player2Model
            role = "terrorist"
        }
    }
    
    func createCharacter() {
        var characterTexture : SKTexture
        var characterPosition = CGPoint(x: 0, y: 0)
        
        if role == "fbi" {
            characterTexture = fbiRightTextures[0]
            character = SKSpriteNode(texture: characterTexture)
            characterPosition = fbiSpawnPoint
        } else {
            characterTexture =  SKTexture(imageNamed: "terrorist-bomb")
            character = SKSpriteNode(texture: characterTexture)
            characterPosition = terroristSpawnPoint
        }
        
        let characterWidth = characterTexture.size().width * 0.095 //
        let characterHeight = characterTexture.size().height * 0.1
        let offsetX = (frame.width - characterWidth) / 2
        let offsetY = characterHeight / 2
        print("Terrorist Character Position: x = \(frame.minX + offsetX + 5), y = \(frame.minY + offsetY + 1360)")
        
        character.position = characterPosition
        character.setScale(0.3)
        character.zPosition = 3
        
        character.physicsBody = SKPhysicsBody(texture: characterTexture, size: character.size)
        character.physicsBody?.affectedByGravity = false
        character.physicsBody?.isDynamic = true
        character.physicsBody?.allowsRotation = false
        character.physicsBody?.categoryBitMask = 2
        character.physicsBody?.contactTestBitMask = 1
        character.physicsBody?.collisionBitMask = 3
        addChild(character)
    }
    
    func createJoystick() {
        
        //Otak-atik posisi Joystick
        let joystickBase = SKSpriteNode(imageNamed: "joystickBase2")
        //        joystickBase.position = CGPoint(x: size.width / 2, y: size.width/2)
        joystickBase.position = CGPoint(x: -480, y: -310)
        joystickBase.setScale(1.5)
        joystickBase.alpha = 0.5
        joystickBase.zPosition = 20
        joystickBase.name = "joystickBase2"
        
        let joystickKnob = SKSpriteNode(imageNamed: "joystickKnob2")
        //        joystickKnob.position = CGPoint(x: size.width / 2, y: size.width/2)
        joystickKnob.position = CGPoint(x: -480, y: -310)
        joystickKnob.setScale(1.5)
        joystickKnob.zPosition = 21
        joystickKnob.name = "joystickKnob2"
        
        cameraNode?.addChild(joystickBase)
        cameraNode?.addChild(joystickKnob)
        self.joystick = joystickBase
        self.joystickKnob = joystickKnob
        
    }
    
    func sabotagedView() {
        maskNode = SKShapeNode(circleOfRadius: 1000)
        maskNode?.fillColor = .clear
        maskNode?.strokeColor = .white
        maskNode?.lineWidth = 1800
        maskNode?.position = character.position
        
        cropNode = SKCropNode()
        cropNode?.maskNode = maskNode
        cropNode?.zPosition = 10
        addChild(cropNode!)
        
        let background = SKSpriteNode(color: .black, size: CGSize(width: 5000, height: 5000))
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = 5
        cropNode?.addChild(background)
    }
    
    //Setup plant button
    func setupPlantButton() {
        plantButton.size = CGSize(width: 120, height: 70)
        plantButton.zPosition = 2
        addChild(plantButton)
        plantButton.isHidden = true
    }
    
    
    //Check if player enters the bombsite area
    func isPlayerInBombSite() -> Bool {
        for bombSite in bombSites {
            let bombSiteRect = CGRect(
                origin: CGPoint(
                    x: bombSite.position.x - bombSite.size.width/2,
                    y: bombSite.position.y - bombSite.size.height/2),
                size: bombSite.size)
            
            if bombSiteRect.contains(character.position){
                // Debugging print:
                //  print("Player is in bomb site: \(character.position)")
                return true
            }
        }
        return false
    }
    
    
    func addBombNode() {
        let bombNode = SKSpriteNode(imageNamed: "bomb-on")
        bombNode.size = CGSize(width: 50, height: 50)
        bombNode.position = character.position
        bombNode.zPosition = 5
        bombNode.name = "bombNode"
        addChild(bombNode)
        
        isBombPlanted = true
        plantButton.isHidden = true
        startTimer()
    }
    
    func setupTimerLabel() {
        let timerLabel = SKLabelNode(fontNamed: "Arial")
        timerLabel.fontSize = 40
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: -6, y: 320)
        timerLabel.zPosition = 100
        
        self.timerLabel = timerLabel
        self.timerLabel?.text = "Timer:"
        cameraNode?.addChild(timerLabel)
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
    
    
    func calculateDistance(from charPosition: CGPoint, to bombPosition: CGPoint) -> CGFloat {
        let dx = charPosition.x - bombPosition.x
        let dy = charPosition.y - bombPosition.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func setupDefuseButton() {
        defuseButton.size = CGSize(width: 60, height: 60)
        defuseButton.zPosition = 2
        addChild(defuseButton)
        defuseButton.isHidden = true
    }
    
    func isPlayerNearBomb() -> Bool {
        guard let bombNode = childNode(withName: "bombNode") else { return false }
        let distanceToBomb = calculateDistance(from: character.position, to: bombNode.position)
        
        return distanceToBomb <= defuseRadius
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
        
        if let joystick = joystick, joystick.contains(location) {
            let convertedLocation = camera?.convert(location, from: self) ?? location
            joystickKnob?.position = convertedLocation
        }
        
        if plantButton.contains(location) && !plantButton.isHidden && !isBombPlanted {
            bombPlantTimerStartTime = Date()
            print("lagi plant...")
        }
        
        
        if defuseButton.contains(location) && !defuseButton.isHidden {
            defuseTimerStartTime = Date()
            print("lagi defuse...")
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let joystick = joystick, let joystickKnob = joystickKnob, let camera = cameraNode {
            
            
            //Convert Lokasi touch dari Scene ke Cam
            let convertedLocation = camera.convert(location, from: self)
            
            if joystick.contains(convertedLocation) {
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
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystickKnob = joystickKnob, let joystick = joystick else { return }
        let moveBack = SKAction.move(to: joystick.position, duration: 0.1)
        moveBack.timingMode = .easeOut
        joystickKnob.run(moveBack)
        
        if let bombPlantTimerStartTime = bombPlantTimerStartTime {
            let elapsedTime = Date().timeIntervalSince(bombPlantTimerStartTime)
            if elapsedTime < 2.0 {
                print("cancel planting")
                self.bombPlantTimerStartTime = nil
            }
        }
        
        if let defuseTimerStartTime = defuseTimerStartTime {
            let elapsedTime = Date().timeIntervalSince(defuseTimerStartTime)
            if elapsedTime < 2.0 {
                print("cancel defusing")
                self.defuseTimerStartTime = nil
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
                
        guard let joystick = joystick, let joystickKnob = joystickKnob else { return }
        
        let displacement = CGVector(dx: joystickKnob.position.x - joystick.position.x, dy: joystickKnob.position.y - joystick.position.y)
        
        if displacement.dx != 0 || displacement.dy != 0 {
            let velocity = CGVector(dx: displacement.dx * speedMultiplierTerrorist, dy: displacement.dy * speedMultiplierTerrorist)
            
            character.physicsBody?.velocity = velocity
            
            // Determine movement direction and play appropriate animation
            if velocity.dx > 0 {
                character.removeAction(forKey: "moveLeft")
                character.run(SKAction.repeatForever(SKAction.animate(with: fbiRightTextures, timePerFrame: 0.1)), withKey: "moveRight")
            } else if velocity.dx < 0 {
                character.removeAction(forKey: "moveRight")
                character.run(SKAction.repeatForever(SKAction.animate(with: fbiLeftTextures, timePerFrame: 0.1)), withKey: "moveLeft")
            } else {
                character.removeAction(forKey: "moveRight")
                character.removeAction(forKey: "moveLeft")
            }
        } else {
            character.physicsBody?.velocity = .zero
            character.removeAction(forKey: "moveRight")
            character.removeAction(forKey: "moveLeft")
        }
        
        //Camera mengikuti character
        cameraNode?.position = character.position
        
        // Mask mengikuti character -> sabotage view
        maskNode?.position = character.position
        
        //If player enters bomsite, the plant button will appear
        if isPlayerInBombSite() && !isBombPlanted {
            let offset: CGFloat = 20.0
            plantButton.position = CGPoint(
                x: character.position.x,
                y: character.position.y + character.size.height / 2 + plantButton.size.height / 2 + offset)
            
            plantButton.isHidden = false
            // Debugging print:
//            print("Plant button is visible")
        } else {
            plantButton.isHidden = true
        }
        
        //If FBI near bomb, defuse button will appear
        if isPlayerNearBomb() {
            let offset: CGFloat = 20.0
            defuseButton.position = CGPoint(
                x: character.position.x,
                y: character.position.y + character.size.height / 2 + defuseButton.size.height / 2 + offset)
            defuseButton.isHidden = false
        } else {
            defuseButton.isHidden = true
        }
        
        
        // add bomb if players already held plant button for a certain period of time
        if let bombPlantTimerStartTime = bombPlantTimerStartTime {
            let elapsedTime = Date().timeIntervalSince(bombPlantTimerStartTime)
            if elapsedTime >= 2.0 {
                print("Success planting bomb")
                self.addBombNode()
                self.bombPlantTimerStartTime = nil
            }
        }
        // defuse bomb if players already held defuse button for a certain period of time
        if let defuseTimerStartTime = defuseTimerStartTime {
            let elapsedTime = Date().timeIntervalSince(defuseTimerStartTime)
            if elapsedTime >= 2.0 {
                print("Success defusing bomb")
                self.defuseButton.isHidden = true
                self.timerLabel?.isHidden = true
                if let bombNode = self.childNode(withName: "bombNode") {
                    bombNode.removeFromParent()
                }
                self.defuseTimerStartTime = nil
            }
        }

    }
    
}
