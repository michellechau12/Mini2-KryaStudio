//
//  GameScene.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 12/06/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, ObservableObject {
    
    var mpManager: MultipeerConnectionManager!
    
    @Published var player1Id: String!
    @Published var player2Id: String!
    
    @Published var playerPeerId: String!
    @Published var thisPlayer: PlayerModel!
    
    @Published var player1Model: PlayerModel!
    @Published var player2Model: PlayerModel!
    
    @Published var host: Bool = false
    @Published var role: String = ""
    
    private var timerLabel: SKLabelNode?
    var timerIsRunning = false
    
    var timer: Timer?
    var timeLeft = 30
    
    private var bombPlantTimer: Timer?
    private var bombPlantTimerStartTime: Date?
    
    private var defuseTimer: Timer?
    private var defuseTimerStartTime: Date?
    
    private var fbiNode = SKSpriteNode(imageNamed: "fbi-borgol")
    private var terroristNode = SKSpriteNode(imageNamed: "terrorist-bomb")
    
    private var fbiRightTextures: [SKTexture] = []
    private var fbiLeftTextures: [SKTexture] = []
    
    private var terroristRightTextures: [SKTexture] = []
    private var terroristLeftTextures: [SKTexture] = []
    
    // custom textures
    private var fbiRightTang: [SKTexture] = []
    private var fbiLeftTang: [SKTexture] = []
    
    private var terroristRightNone: [SKTexture] = []
    private var terroristLeftNone: [SKTexture] = []
    
    private var terroristRightPentungan: [SKTexture] = []
    private var terroristLeftPentungan: [SKTexture] = []
    
    private var joystick: SKSpriteNode?
    private var joystickKnob: SKSpriteNode?
    private var cameraNode: SKCameraNode?
    private var maskNode: SKShapeNode?
    private var cropNode: SKCropNode?
    
    private var bombSites: [BombSiteModel] = []
    private let plantButton = SKSpriteNode(imageNamed: "plantButton")
    private let defuseButton = SKSpriteNode(imageNamed: "defuseButton")
    private var isBombPlanted = false
    private var defuseRadius: CGFloat = 50.0
    
    private var isPlantButtonTapped = false
    private var isDefuseButtonTapped = false
    
    private var condition = "initial-condition"
    
    override func didMove(to view: SKView) {
        
        loadFBITextures()
        loadTerroristsTextures()
        // Initialize player models
        if let player1Id = player1Id, let player2Id = player2Id {
            player1Model = PlayerModel(id: player1Id, playerRightTextures: fbiRightTextures, playerLeftTextures: fbiLeftTextures, gameScene: self)
            player2Model = PlayerModel(id: player2Id, playerRightTextures: terroristRightTextures, playerLeftTextures: terroristLeftTextures, gameScene: self)
        } else {
            print("DEBUG: Player IDs are not set correctly.")
        }
        
        setupMapPhysics()
        setupBombSites()
        
        setThisPlayer()
        //        createMaze()
        
        createCamera()
        createJoystick()
        setUpTimerLabel()
        
        if thisPlayer.role == "terrorist"{
            setupPlantButton()
        }else{
            setupDefuseButton()
        }
        
        //        print("DEBUG Player1id, player2id, playerpeerid")
        //        print(player1Id ?? "none")
        //        print(player2Id ?? "none")
        //        print(playerPeerId ?? "none")
        //        print("==============")
        
        //setupMask()
        
        physicsWorld.contactDelegate = self
        
        addChild(player1Model.playerNode)
        addChild(player2Model.playerNode)
    }
    
    func loadFBITextures(){
        //general textures
        //right
        for i in 1...5 {
            let texture = SKTexture(imageNamed: "fbi-borgol-right-\(i)")
            fbiRightTextures.append(texture)
        }
    
        //left
        for i in 1...5 {
            let texture = SKTexture(imageNamed: "fbi-borgol-left-\(i)")
            fbiLeftTextures.append(texture)
        }
        
        //Tang textures
        //right
        for i in 1...5 {
            let texture = SKTexture(imageNamed: "fbi-tang-right-\(i)")
            fbiRightTang.append(texture)
        }
        
        //left
        for i in 1...5 {
            let texture = SKTexture(imageNamed: "fbi-tang-left-\(i)")
            fbiLeftTang.append(texture)
        }
    }
    
    func loadTerroristsTextures(){
        //general textures
        //right
        for i in 1...5 {
            let texture = SKTexture(imageNamed: "terrorist-bom-rightt-\(i)")
            terroristRightTextures.append(texture)
        }
        
        //left
        for i in 1...5 {
            let texture = SKTexture(imageNamed: "terrorist-bom-left-\(i)")
            terroristLeftTextures.append(texture)
        }
        
        //none textures
        //right
        for i in 1...5 {
            let texture = SKTexture(imageNamed: "terrorist-none-right-\(i)")
            terroristRightNone.append(texture)
        }
        
        //left
        for i in 1...5 {
            let texture = SKTexture(imageNamed: "terrorist-none-left-\(i)")
            terroristLeftNone.append(texture)
        }
        
        //pentungan textures
        //right
        for i in 1...5 {
            let texture = SKTexture(imageNamed: "terrorist-pentungan-right-\(i)")
            terroristRightPentungan.append(texture)
        }
        
        //left
        for i in 1...5 {
            let texture = SKTexture(imageNamed: "terrorist-pentungan-left-\(i)")
            terroristLeftPentungan.append(texture)
        }
    }
    
    func getFBITextures(type: String) -> [SKTexture]{
        if type == "tang-right"{
            return fbiRightTang
        } else if type == "tang-left"{
            return fbiLeftTang
        }
        return fbiRightTextures
    }
    
    func getTerroristTextures(type: String) -> [SKTexture]{
        if type == "none-right"{
            return terroristRightNone
        } else if type == "none-left"{
            return terroristLeftNone
        } else if type == "pentungan-right"{
            return terroristRightPentungan
        } else if type == "pentungan-left"{
            return terroristLeftPentungan
        }
        return terroristRightTextures
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
        guard let bombNode = childNode(withName: "bomb") else { return false }
        let distanceToBomb = calculateDistance(from: thisPlayer.playerNode.position, to: bombNode.position)
        
        return distanceToBomb <= defuseRadius
    }
    
    func setUpTimerLabel(){
        let timerLabel = SKLabelNode(fontNamed: "Arial")
        timerLabel.fontSize = 40
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: -6, y: 320)
        timerLabel.zPosition = 100
        //           addChild(timerLabel)
        
        self.timerLabel = timerLabel
        self.timerLabel?.text = "Timer:"
        self.timerLabel?.isHidden = false
        cameraNode?.addChild(timerLabel)
    }
    
    func setupMapPhysics() {
        guard let map = childNode(withName: "Maze") as? SKTileMapNode else {
            print("DEBUG: SKTileMapNode 'Maze' not found.")
//            createMaze()
            return
        }
        
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
                        
                        //friction = semakin strict objectnya, sehingga lebih baik dibuat 0 saja
                        //tileNode.physicsBody?.friction = 20.0
                        
                        tileNode.physicsBody?.mass = 30.0
                        tileNode.physicsBody?.contactTestBitMask = 2
                        tileNode.physicsBody?.categoryBitMask = 1
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
                    
                    //Debugging print:
                    print("bombsite position is: \(bombSitePosition) and size is: \(bombSiteSize)")
                }
            }
        }
    }
    
    //Setup plant button
    func setupPlantButton() {
        plantButton.size = CGSize(width: 120, height: 70)
        plantButton.zPosition = 2
        plantButton.alpha = 0.7
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
            
            if bombSiteRect.contains(thisPlayer.playerNode.position){
                // Debugging print:
                //                print("Player is in bomb site: \(thisPlayer.playerNode.position)")
                return true
            }
        }
        return false
    }
    
    func addBombNode() {
        let bombNode = SKSpriteNode(imageNamed: "bomb")
        bombNode.size = CGSize(width: 50, height: 50)
        bombNode.position = player2Model.playerNode.position
        bombNode.zPosition = 5
        bombNode.name = "bomb"
        addChild(bombNode)
        condition = "terrorist-planted-bomb"
        
        isBombPlanted = true
        plantButton.isHidden = true
        
        startTimer()
    }
    
    func startTimer() {
        timeLeft = 30
        timerLabel?.text = "Time: \(timeLeft)"
        timerLabel?.isHidden = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.timeLeft -= 1
            self.timerLabel?.text = "Time: \(self.timeLeft)"
            
            if self.timeLeft <= 0 {
                timer.invalidate()
                self.timerLabel?.isHidden = true
                
                if let bombNode = self.childNode(withName: "bomb"){
                    bombNode.removeFromParent()
                }
                //Logic untuk pindah scene misalnya (Kalah atau poin Terrorist bertambah nanti jika tidak didefuse)
            }
        }
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
        if playerPeerId == player1Id {
            self.thisPlayer = player1Model
        }
        else if playerPeerId == player2Id {
            self.thisPlayer = player2Model
        }
    }
    
    func createJoystick() {
        
        //Otak-atik posisi Joystick
        let joystickBase = SKSpriteNode(imageNamed: "joystickBase2")
        joystickBase.position = CGPoint(x: -480, y: -310)
        joystickBase.setScale(1.5)
        joystickBase.alpha = 0.5
        joystickBase.zPosition = 80
        joystickBase.name = "joystickBase2"
        
        let joystickKnob = SKSpriteNode(imageNamed: "joystickKnob2")
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Assigning joystickknob to the touch location
        if let joystick = joystick, joystick.contains(location) {
            let convertedLocation = camera?.convert(location, from: self) ?? location
            joystickKnob?.position = convertedLocation
        }
        
        // planting the bomb from plant button -> only terrorists
        if plantButton.contains(location) && !plantButton.isHidden && !isBombPlanted {
            bombPlantTimerStartTime = Date()
            
            // kasih animasi
            
            bombPlantTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                self?.addBombNode()
                self?.bombPlantTimer = nil
                self?.bombPlantTimerStartTime = nil
                
                //sending location of the bomb to other player
                let bombCondition = MPBombModel(bomb: .planted)
                self?.mpManager.send(bomb: bombCondition)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let joystick = joystick, let joystickKnob = joystickKnob, let camera = cameraNode {
            
            //Convert Lokasi touch dari Scene ke Cam
            let convertedLocation = camera.convert(location, from: self)
            if joystick.contains(convertedLocation){
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
        
        guard let bombPlantTimer = bombPlantTimer, bombPlantTimerStartTime != nil else { return }
        let elapsedTime = Date().timeIntervalSince(bombPlantTimerStartTime!)
        if elapsedTime < 2.0 {
            bombPlantTimer.invalidate()
            bombPlantTimerStartTime = nil
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let joystick = joystick, let joystickKnob = joystickKnob else { return }
        
        let displacement = CGVector(dx: joystickKnob.position.x - joystick.position.x, dy: joystickKnob.position.y - joystick.position.y)
        let velocity = CGVector(dx: displacement.dx * thisPlayer.speedMultiplier, dy: displacement.dy * thisPlayer.speedMultiplier)
        
        self.thisPlayer.movePlayer(velocity: velocity, mpManager: mpManager, condition: condition)
        
        //        print("x: \(self.thisPlayer.playerNode.position.x), y: \(self.thisPlayer.playerNode.position.y)")
        
        //Camera mengikuti character
        cameraNode?.position = thisPlayer.playerNode.position
        
        // Mask mengikuti character -> sabotage view
        maskNode?.position = thisPlayer.playerNode.position
        
        //If FBI near bomb, defuse button will appear
        if isPlayerNearBomb() {
            
            // Debugging print:
//            print("Defuse button should be visible")
            let offset: CGFloat = 20.0
            defuseButton.position = CGPoint(
                x: thisPlayer.playerNode.position.x,
                y: thisPlayer.playerNode.position.y + thisPlayer.playerNode.size.height / 2 + defuseButton.size.height / 2 + offset)
            defuseButton.isHidden = false
        } else {
            defuseButton.isHidden = true
        }
        
        if isPlayerInBombSite() {
            // role fbi
            if thisPlayer.role == "fbi" {
                // kalo ada bomb
                if isBombPlanted {
                    // func defuse
                }
            }
            // role terrorist
            else {
                // kalo ga ada bomb
                if !isBombPlanted {//
                    // func to enable plantButton
                    let offset: CGFloat = 20.0
                    plantButton.position = CGPoint(
                        x: thisPlayer.playerNode.position.x,
                        y: thisPlayer.playerNode.position.y + thisPlayer.playerNode.size.height / 2 + plantButton.size.height / 2 + offset)
                    
                    plantButton.isHidden = false
                    
                    // Debugging print:
//                    print("Plant button is visible")
                } else {
                    plantButton.isHidden = true
                }
            }
        }
    }
    
    func handlePlayer(player: MPPlayerModel, mpManager: MultipeerConnectionManager) {
        switch player.action {
        case .start:
            print("Start")
        case .move:
            // print("Move")
            self.moveOtherPlayer(id: player.playerId, pos: player.playerPosition, orientation: player.playerOrientation, textures: player.playerTextures)
        case .collide:
            print("Start")
        case .sabotagedView:
            print("Start")
        case .plantBomb:
            print("Start")
            // change terrorist texture from terrorist-bomb to terrorist-none
        case .nearToBomb:
            print("Start")
            // change terrorist texture from terrorist-none to terrorist-pentungan
            // change fbi texture from fbi-borgol to fbi-tang
            // change terrorist isVulnerable -> false
            // change fbi isVulnerable -> true
        case .death:
            print("Start")
        case .reset:
            print("Start")
        case .end:
            mpManager.session.disconnect()
        }
    }
    
    func handleBomb(bomb: MPBombModel, mpManager: MultipeerConnectionManager) {
        switch bomb.bomb {
        case .unplanted:
            print("unplanted")
        case .planted:
            print("planted")
            synchronizeOtherBombPosition()
            updateTerroristTextures()
//            updatePlayerVulnerability()
        case .defused:
            print("defused")
        }
    }
    
    func moveOtherPlayer(id: String, pos: CGPoint, orientation: String, textures: String) {
        if id == player1Id {
            player1Model.synchronizeOtherPlayerPosition(position: pos, orientation: orientation, textures: textures)
        }
        else {
            player2Model.synchronizeOtherPlayerPosition(position: pos, orientation: orientation, textures: textures)
        }
    }
    
    func synchronizeOtherBombPosition(){
        self.addBombNode()
    }
    
    func updateTerroristTextures(){
        if thisPlayer.role != "terrorist"{
            // other player is terrorist
            player2Model.playerRightTextures = terroristRightNone
            player2Model.playerLeftTextures = terroristLeftNone
//            let playerCondition = MPPlayerModel(
//                action: .move,
//                playerId: player2Id,
//                playerPosition: player2Model.playerNode.position,
//                playerOrientation: player2Model.orientation,
//                playerTextures: "none",
//                isVulnerable: false
//            )
//            mpManager.send(player: playerCondition)
        }
    }
    
//    func updatePlayerVulnerability(){
//        
//    }
}

extension GameScene: SKPhysicsContactDelegate{
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Determine the categories involved in the collision
        let collision = bodyA.categoryBitMask | bodyB.categoryBitMask
        print("DEBUG: bodyA = \(bodyA.categoryBitMask), bodyB = \(bodyB.categoryBitMask)")
        print("DEBUG: bodyA = \(BitMaskCategory.player1), bodyB = \(BitMaskCategory.player2)")
        switch collision {
        case BitMaskCategory.player1 | BitMaskCategory.player2:
            // FBI and terrorist collided
            print("FBI and terrorist collided")
            handlePlayerCollision()
        case BitMaskCategory.player1 | BitMaskCategory.maze:
            // FBI and maze collided
            print("FBI and maze collided")
        case BitMaskCategory.player2 | BitMaskCategory.maze:
            // Terrorist and maze collided
            print("Terrorist and maze collided")
        default:
            break
        }
    }
    
    func handlePlayerCollision() {
        if thisPlayer.role == "fbi"{
            if thisPlayer.isVulnerable{
                print("you (fbI) lose")
            } else{
                print("you (fbi) win")
            }
        } else if thisPlayer.role == "terrorist" {
            if thisPlayer.isVulnerable {
                print("you (terrorist) lose")
            } else {
                print("you (terrorist) win")
            }
        }
    }
}
