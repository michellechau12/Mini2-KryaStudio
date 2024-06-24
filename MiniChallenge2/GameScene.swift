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
    @Published var isGameFinished: Bool!
    @Published var winner: PlayerModel!
    
    @Published var statementGameOver: String = ""
    @Published var imageGameOver: String = ""
    
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
    var timeLeft = 0 // setted at the function
    
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
    private let defuseButton = SKSpriteNode(imageNamed: "tang")
    private var isBombPlanted = false
    private var defuseRadius: CGFloat = 50.0
    
    private var isPlantButtonTapped = false
    private var isDefuseButtonTapped = false
    
    private var terroristCondition = "start"
    private var fbiCondition = "start"
    private var viewSabotaged = false
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        isGameFinished = false
        
        // Load Textures and Setting Players
        loadFBITextures()
        loadTerroristsTextures()
        createPlayers()
        setThisPlayer()
        
        // Setting up the map
        setupMapPhysics()
        setupBombSites()
        
        // Setting up Game Components that follows the users camera
        createCamera()
        createJoystick()
        setUpTimerLabel()
        
        if viewSabotaged {
            setupSabotagedView()
        }
        
        if thisPlayer.role == "terrorist"{
            setupPlantButton()
        }else{
            setupDefuseButton()
        }
        
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
        } else if type == "borgol-right"{
            return fbiRightTextures
        } else if type == "borgol-left"{
            return fbiLeftTextures
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
        } else if type == "bomb-right"{
            return terroristRightTextures
        } else if type == "bomb-left"{
            return terroristLeftTextures
        }
        return terroristRightTextures
    }
    
    func createPlayers(){
        // Initialize player models
        if let player1Id = player1Id, let player2Id = player2Id {
            player1Model = PlayerModel(
                id: player1Id,
                playerRightTextures: fbiRightTextures,
                playerLeftTextures: fbiLeftTextures,
                gameScene: self
            )
            player2Model = PlayerModel(
                id: player2Id, 
                playerRightTextures: terroristRightTextures,
                playerLeftTextures: terroristLeftTextures,
                gameScene: self
            )
        } else {
            print("DEBUG: Player IDs are not set correctly.")
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
    
    func setupSabotagedView() {
        maskNode = SKShapeNode(circleOfRadius: 150)
        maskNode?.fillColor = .white
        maskNode?.strokeColor = .clear
        
        cropNode = SKCropNode()
        cropNode?.maskNode = maskNode
        cropNode?.zPosition = 50
        addChild(cropNode!)
        
        // Create a black background
        let background = SKSpriteNode(color: .black, size: self.size)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = 5
        cropNode?.addChild(background)  // Added to cropNode instead of scene
    }
    
    func setupPlantButton() {
        plantButton.size = CGSize(width: 120, height: 70)
        plantButton.zPosition = 20
        plantButton.alpha = 0.7
        addChild(plantButton)
        plantButton.isHidden = true
    }
    
    func setupDefuseButton() {
        defuseButton.size = CGSize(width: 60, height: 60)
        defuseButton.zPosition = 20
        addChild(defuseButton)
        defuseButton.isHidden = true
    }
    
    func calculateDistance(from charPosition: CGPoint, to bombPosition: CGPoint) -> CGFloat {
        let dx = charPosition.x - bombPosition.x
        let dy = charPosition.y - bombPosition.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func isPlayerNearBomb() -> Bool {
        guard let bombNode = childNode(withName: "bomb") else { return false }
        let distanceToBomb = calculateDistance(from: thisPlayer.playerNode.position, to: bombNode.position)
        
        return distanceToBomb <= defuseRadius
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
    
    func startTimer() {
        timeLeft = 10
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
                gameOverByExplodingBomb()
                //Logic untuk pindah scene misalnya (Kalah atau poin Terrorist bertambah nanti jika tidak didefuse)
                
            }
        }
    }
    
    func gameOverByExplodingBomb(){
        // send event to other person
        let bombCondition = MPBombModel(bomb: .exploded, playerBombCondition: "exploded", winnerId: player2Id)
        mpManager.send(bomb: bombCondition)
        self.winner = player2Model // terrorist win
        
        // print("DEBUG : Yang menang adalah \(player2Model.role)")
        
        isGameFinished = true
        if self.winner.id == self.thisPlayer.id{
            statementGameOver = "You Win"
            imageGameOver = "terrorist-bom-rightt-1"
            print("DEBUG_GO_COLS: TERRORIST WIN")
        } else{
            statementGameOver = "You Lose"
            imageGameOver = "fbi-borgol-right-1"
            print("DEBUG_GO_COLS: FBI LOSE")
            
        }
        
        if isGameFinished{
            removeAllNodes()
        }
    }
    
    func removeAllNodes(){
        for node in self.children {
            // check if the node is a shark
            if let node = node as? SKSpriteNode, node.name == "Player1" || node.name == "Player2" || node.name == "joyStick" || node.name == "joyStickKnob" || node.name == "Maze" || node.name == "bomb" {
                
                node.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Assigning joystickknob to the touch location
        if let joystick = joystick, joystick.contains(location) {
            let convertedLocation = camera?.convert(location, from: self) ?? location
            joystickKnob?.position = convertedLocation
        }
        
        // Detecting touch on plant button
        if plantButton.contains(location) && !plantButton.isHidden && !isBombPlanted {
            bombPlantTimerStartTime = Date()
            print("lagi plant...")
        }
        
        // Detecting touch on defuse button
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
        
//        // return if the game is finish
//        if isGameFinish {
//            return
//        }
        
        guard let joystick = joystick, let joystickKnob = joystickKnob else { return }
        
        let displacement = CGVector(dx: joystickKnob.position.x - joystick.position.x, dy: joystickKnob.position.y - joystick.position.y)
        let velocity = CGVector(dx: displacement.dx * thisPlayer.speedMultiplier, dy: displacement.dy * thisPlayer.speedMultiplier)
        
        if thisPlayer.role == "fbi" {
            //If FBI near bomb, defuse button will appear
            if isPlayerNearBomb() {
                let offset: CGFloat = 20.0
                defuseButton.position = CGPoint(
                    x: thisPlayer.playerNode.position.x,
                    y: thisPlayer.playerNode.position.y + thisPlayer.playerNode.size.height / 2 + defuseButton.size.height / 2 + offset)
                defuseButton.isHidden = false
                fbiCondition = "fbi-near-bomb"
                
                //sending to multipeer
                let bombCondition = MPBombModel(bomb: .approachedByPlayers, playerBombCondition: "fbi-near-bomb", winnerId: thisPlayer.id)
                mpManager.send(bomb: bombCondition)
            } else {
                defuseButton.isHidden = true
                fbiCondition = "fbi-far-from-bomb"
                
                //sending to multipeer
                let bombCondition = MPBombModel(bomb: .approachedByPlayers, playerBombCondition: "fbi-far-from-bomb", winnerId: thisPlayer.id)
                mpManager.send(bomb: bombCondition)
            }
        }
        //role terrorist
        else {
            if isPlayerInBombSite() && !isBombPlanted {
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
            
            if isBombPlanted {
                if isPlayerNearBomb() {
                    terroristCondition = "terrorist-near-bomb"
                    
                    //sending to multipeer
                    let bombCondition = MPBombModel(bomb: .approachedByPlayers, playerBombCondition: "terrorist-near-bomb", winnerId: thisPlayer.id)
                    mpManager.send(bomb: bombCondition)
                } else {
                    terroristCondition = "terrorist-planted-bomb"
                    
                    //sending to multipeer
                    let bombCondition = MPBombModel(bomb: .approachedByPlayers, playerBombCondition: "terrorist-planted-bomb", winnerId: thisPlayer.id)
                    mpManager.send(bomb: bombCondition)
                }
            }
        }
        
        // Moving the player
        if thisPlayer.role == "terrorist"{
            self.thisPlayer.movePlayer(velocity: velocity, mpManager: mpManager, condition: terroristCondition)
        } else {
            self.thisPlayer.movePlayer(velocity: velocity, mpManager: mpManager, condition: fbiCondition)
        }
        
        //        print("x: \(self.thisPlayer.playerNode.position.x), y: \(self.thisPlayer.playerNode.position.y)")
        
        //Camera mengikuti character
        cameraNode?.position = thisPlayer.playerNode.position
        
        // Mask mengikuti character -> sabotage view
        maskNode?.position = thisPlayer.playerNode.position
        
        // add bomb if players already held plant button for a certain period of time
        if let bombPlantTimerStartTime = bombPlantTimerStartTime {
            let elapsedTime = Date().timeIntervalSince(bombPlantTimerStartTime)
            if elapsedTime >= 2.0 {
                print("Success planting bomb")
                self.addBombNode()
                
                //                sending location of the bomb to other player
                let bombCondition = MPBombModel(bomb: .planted, playerBombCondition: "terrorist-planted-bomb", winnerId: thisPlayer.id)
                self.mpManager.send(bomb: bombCondition)
            }
        }
        
        // defuse bomb if players already held defuse button for a certain period of time
        if let defuseTimerStartTime = defuseTimerStartTime {
            let elapsedTime = Date().timeIntervalSince(defuseTimerStartTime)
            if elapsedTime >= 2.0 {
                print("Success defusing bomb")
                self.defuseBombNode()
                
                //           sending bomb condition to multipeer
                let bombCondition = MPBombModel(bomb: .defused, playerBombCondition: "fbi-defused-bomb", winnerId: player2Id)
                self.mpManager.send(bomb: bombCondition)
            }
        }
        
    }
    
    func addBombNode() {
        let bombNode = SKSpriteNode(imageNamed: "bomb")
        bombNode.size = CGSize(width: 20, height: 20)
        bombNode.position = player2Model.playerNode.position
        bombNode.zPosition = 5
        bombNode.name = "bomb"
        addChild(bombNode)
        terroristCondition = "terrorist-planted-bomb"
        
        isBombPlanted = true
        plantButton.isHidden = true
        
        startTimer()
        
        self.bombPlantTimerStartTime = nil
    }
    
    func defuseBombNode(){
        self.defuseButton.isHidden = true
        self.timerLabel?.isHidden = true
        if let bombNode = self.childNode(withName: "bomb") {
            bombNode.removeFromParent()
        }
        self.defuseTimerStartTime = nil
    }
    
    func handlePlayer(player: MPPlayerModel, mpManager: MultipeerConnectionManager) {
        switch player.action {
        case .start:
            print("Start")
        case .move:
            self.moveOtherPlayer(id: player.playerId, pos: player.playerPosition, orientation: player.playerOrientation)
        case .sabotagedView:
            print("sabotaged view")
        case .death:
            print("Start")
        case .reset:
            print("Start")
        case .end:
            isGameFinished = true
            
            if thisPlayer.role == "fbi"{ // OtherPlayer as FBI
                // If player as fbi winning the game
                if player.winnerId == thisPlayer.id{
                    statementGameOver = "You Win"
                    imageGameOver = "fbi-borgol-right-1"
                    print("DEBUG_GO_COLS_handle: FBI WIN")
                } else {
                    statementGameOver = "You Lose"
                    imageGameOver = "fbi-borgol-right-1"
                    print("DEBUG_GO_COLS_handle: TERRORIST LOSE")
                }
            } else {
                // If player as terrorist winning the game
                if player.winnerId == thisPlayer.id{
                    statementGameOver = "You Win"
                    imageGameOver = "terrorist-bom-rightt-1"
                    print("DEBUG_GO_COLS_handle: TERRORIST WIN")
                } else{
                    statementGameOver = "You Lose"
                    imageGameOver = "terrorist-bom-rightt-1"
                    print("DEBUG_GO_COLS_handle: FBI LOSE")
                }
            }
            
            if isGameFinished{
                removeAllNodes()
            }
            
            if thisPlayer.id == player.playerId {
                
            }else {
                
            }
            // mpManager.session.disconnect()
        }
    }
    
    func handleBomb(bomb: MPBombModel, mpManager: MultipeerConnectionManager) {
        switch bomb.bomb {
        case .planted:
            print("planted")
            updateOtherPlayerTextures(condition: bomb.playerBombCondition)
            synchronizeOtherPlayerBombCondition(isDefused: false)
//            updatePlayerVulnerability()
        case .approachedByPlayers:
            print("bomb approached by players")
            updateOtherPlayerTextures(condition: bomb.playerBombCondition)
        case .defused:
            print("defused")
            synchronizeOtherPlayerBombCondition(isDefused: true)
        case .exploded:
            print("exploded")
            isGameFinished = true
            if bomb.winnerId == self.thisPlayer.id{
                statementGameOver = "You Win"
                imageGameOver = "terrorist-bom-rightt-1"
                print("DEBUG_GO_COLS: TERRORIST WIN")
            } else{
                statementGameOver = "You Lose"
                imageGameOver = "fbi-borgol-right-1"
                print("DEBUG_GO_COLS: FBI LOSE")
                
            }
            
            if isGameFinished{
                removeAllNodes()
            }
            mpManager.session.disconnect()
        }
    }
    
    func moveOtherPlayer(id: String, pos: CGPoint, orientation: String) {
        if id == player1Id {
            player1Model.synchronizeOtherPlayerPosition(position: pos, orientation: orientation, condition: terroristCondition)
        }
        else {
            player2Model.synchronizeOtherPlayerPosition(position: pos, orientation: orientation, condition: fbiCondition)
        }
    }
    
    func synchronizeOtherPlayerBombCondition(isDefused: Bool){
        if isDefused {
            self.defuseBombNode()
        }else{
            self.addBombNode()
        }
    }
    
//    func updateCondition(){
////        if thisPlayer.role != "terrorist"{
//            //other player is terrorist
//            if terroristCondition != "terrorist-near-bomb" {
//                terroristCondition = "terrorist-near-bomb"
//            }else{
//                terroristCondition = "terrorist-planted-bomb"
//            }
////        } else {
//            if fbiCondition != "fbi-near-bomb"{
//                fbiCondition = "fbi-near-bomb"
//            } else {
//                fbiCondition = "fbi-far-from-bomb"
//            }
////        }
//    }
    
    func updateOtherPlayerTextures(condition: String){
        if thisPlayer.role != "terrorist"{
            // other player is terrorist
            if condition == "terrorist-planted-bomb"{
                player2Model.playerRightTextures = terroristRightNone
                player2Model.playerLeftTextures = terroristLeftNone
            } else if condition == "terrorist-near-bomb"{
                player2Model.playerRightTextures = terroristRightPentungan
                player2Model.playerLeftTextures = terroristLeftPentungan
            }
            player2Model.latestTextureLeft = player2Model.playerLeftTextures[player2Model.playerLeftTextures.count - 1]
            player2Model.latestTextureRight = player2Model.playerRightTextures[player2Model.playerRightTextures.count - 1]
        } else {
            // other player is fbi
            if condition == "fbi-near-bomb"{
                player1Model.playerRightTextures = fbiRightTang
                player1Model.playerLeftTextures = fbiLeftTang
            } else {
                player1Model.playerRightTextures = fbiRightTextures
                player1Model.playerLeftTextures = fbiLeftTextures
            }
            player1Model.latestTextureLeft = player1Model.playerLeftTextures[player1Model.playerLeftTextures.count - 1]
            player1Model.latestTextureRight = player1Model.playerRightTextures[player1Model.playerRightTextures.count - 1]
        }
    }
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
        // If thisPlayer win the game
        if !thisPlayer.isVulnerable{
            
        }
        
        if thisPlayer.role == "fbi"{
            if thisPlayer.isVulnerable{
                print("DEBUG_COL : you (fbi) lose")
                gameOverByCollision(winner: "terrorist", playerRole: thisPlayer.role)
            } else{
                print("DEBUG_COL : you (fbi) win")
                gameOverByCollision(winner: "fbi", playerRole: thisPlayer.role)
            }
        } else if thisPlayer.role == "terrorist" {
            if thisPlayer.isVulnerable {
                print("DEBUG_COL : you (terrorist) lose")
                gameOverByCollision(winner: "fbi", playerRole: thisPlayer.role)
            } else {
                print("DEBUG_COL : you (terrorist) win")
                gameOverByCollision(winner: "terrorist", playerRole: thisPlayer.role)
            }
        }
    }
    
    func gameOverByCollision(winner: String, playerRole: String){
        isGameFinished = true
        
        if winner == "fbi"{
            self.winner = player1Model //fbi wins
            
            //sending multipeer
            let playerCondition = MPPlayerModel(action: .end, playerId: thisPlayer.id, playerPosition: thisPlayer.playerNode.position, playerOrientation: thisPlayer.orientation, isVulnerable: thisPlayer.isVulnerable, winnerId: self.winner.id)
            
            mpManager.send(player: playerCondition)
            
            // If player as fbi winning the game
            if self.winner.id == self.thisPlayer.id{
                statementGameOver = "You Win"
                imageGameOver = "fbi-borgol-right-1"
                print("DEBUG_GO_COLS: FBI WIN")
            } else { // If player as terrorist losing the game
                statementGameOver = "You Lose"
                imageGameOver = "terrorist-bom-rightt-1"
                print("DEBUG_GO_COLS: TERRORIST LOSE")
            }
        } else {
            self.winner = player2Model // terrorist wins
            
            //sending multipeer
            let playerCondition = MPPlayerModel(action: .end, playerId: thisPlayer.id, playerPosition: thisPlayer.playerNode.position, playerOrientation: thisPlayer.orientation, isVulnerable: thisPlayer.isVulnerable, winnerId: self.winner.id)
            
            mpManager.send(player: playerCondition)
            
            if self.winner.id == self.thisPlayer.id{
                statementGameOver = "You Win"
                imageGameOver = "terrorist-bom-rightt-1"
                print("DEBUG_GO_COLS: TERRORIST WIN")
            } else{
                statementGameOver = "You Lose"
                imageGameOver = "fbi-borgol-right-1"
                print("DEBUG_GO_COLS: FBI LOSE")
            }
        }
        
        if isGameFinished{
            removeAllNodes()
        }
    }
}
