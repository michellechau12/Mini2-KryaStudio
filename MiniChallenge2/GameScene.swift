//
//  GameScene.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 12/06/24.
//

import SpriteKit
import GameplayKit
import Combine

class GameScene: SKScene, ObservableObject {
    
    var mpManager: MultipeerConnectionManager!
    @Published var isGameFinished: Bool = false
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
    private var defuseCooldownStartTime: Date?
    
    private var fbiNode = SKSpriteNode(imageNamed: "fbi-borgol")
    private var terroristNode = SKSpriteNode(imageNamed: "terrorist-bomb")
    
    private var fbiRightTextures: [SKTexture] = []
    private var fbiLeftTextures: [SKTexture] = []
    
    private var terroristRightTextures: [SKTexture] = []
    private var terroristLeftTextures: [SKTexture] = []
    
    // custom textures
    private var fbiRightTang: [SKTexture] = []
    private var fbiLeftTang: [SKTexture] = []
    
    private var fbiRightDefuseBomb: [SKTexture] = []
    private var fbiLeftDefuseBomb: [SKTexture] = []
    
    private var fbiDefuseDelayTexture: [SKTexture] = []
    
    private var terroristRightNone: [SKTexture] = []
    private var terroristLeftNone: [SKTexture] = []
    
    private var terroristRightPentungan: [SKTexture] = []
    private var terroristLeftPentungan: [SKTexture] = []
    
    private var terroristRightPlantBomb: [SKTexture] = []
    private var terroristLeftPlantBomb: [SKTexture] = []
    
    private var joystick: SKSpriteNode?
    private var joystickKnob: SKSpriteNode?
    private var joystickTouchArea : SKShapeNode?
    private var cameraNode: SKCameraNode?
    private var maskNode: SKShapeNode?
    private var cropNode: SKCropNode?
    private var sabotageButton: SKSpriteNode?
    private var isSabotageButtonEnabled = true
    private var sabotageButtonPressCount = 0
    
    private var bombSites: [BombSiteModel] = []
    
    private let plantButton = SKSpriteNode(imageNamed: "plantButton")
    private let defuseButton = SKSpriteNode(imageNamed: "tang")
    
    private var isBombPlanted = false
    private var defuseRadius: CGFloat = 50.0
    
    private var isPlantButtonTapped = false
    private var isDefuseButtonTapped = false
    
    private var progressBar: SKSpriteNode?
    private var progressBarBackground: SKSpriteNode?
    
    private var plantDuration = 3.0
    private var defuseDuration = 4.0
    
    var terroristCondition = "terrorist-initial"
    var fbiCondition = "fbi-initial"
    
    var isDefusing: Bool = false
    var isDelayingMove: Bool = false
    private var defuseCooldownDuration = 2.0
    
    var oneTimeTapfunction = false
    
    var isWalkingSoundPlaying = false

    
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
        setupProgressBar()
        setupSabotageButton()

        
        if thisPlayer.role == "terrorist"{
            //Audio starting terrorist
            AudioManager.shared.playTerroristStartingMusic()
            setupPlantButton()
        }else{
            //Audio starting FBI
            AudioManager.shared.playFbiStartingMusic()
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
        
        //Defusing bomb textures
        //right
        for i in 1...4 {
            let texture = SKTexture(imageNamed: "fbi-defuse-right-\(i)")
            fbiRightDefuseBomb.append(texture)
        }
        
        //left
        for i in 1...4 {
            let texture = SKTexture(imageNamed: "fbi-defuse-left-\(i)")
            fbiLeftDefuseBomb.append(texture)
        }
        
        // defuse delay texture
        for i in 1...4 {
            let texture = SKTexture(imageNamed: "delayed-texture-\(i)")
            fbiDefuseDelayTexture.append(texture)
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
        
        //planting bomb textures
        //right
        for i in 1...4 {
            let texture = SKTexture(imageNamed: "terrorsit-plantbomb-right-\(i)")
            terroristRightPlantBomb.append(texture)
        }
        
        //left
        for i in 1...4 {
            let texture = SKTexture(imageNamed: "terrorsit-plantbomb-left-\(i)")
            terroristLeftPlantBomb.append(texture)
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
        } else if type == "defuse-right"{
            return fbiRightDefuseBomb
        } else if type == "defuse-left"{
            return fbiLeftDefuseBomb
        } else if type == "delay"{
            return fbiDefuseDelayTexture
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
        } else if type == "plantbomb-right"{
            return terroristRightPlantBomb
        } else if type == "plantbomb-left"{
            return terroristLeftPlantBomb
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
//                        tileNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (tileTexture.size().width), height: tileTexture.size().height))
                        tileNode.physicsBody = SKPhysicsBody(texture: tileTexture, size: tileTexture.size())
                        tileNode.physicsBody?.affectedByGravity = false
                        tileNode.physicsBody?.allowsRotation = false
                        tileNode.physicsBody?.restitution = 0
                        tileNode.physicsBody?.isDynamic = false
                        
                        //friction = semakin strict objectnya, sehingga lebih baik dibuat 0 saja
                        //tileNode.physicsBody?.friction = 20.0
                        
                        tileNode.physicsBody?.mass = 30.0
                        
                        tileNode.physicsBody?.categoryBitMask = BitMaskCategory.maze
                        tileNode.physicsBody?.collisionBitMask = BitMaskCategory.player1 | BitMaskCategory.player2
                        tileNode.physicsBody?.contactTestBitMask = BitMaskCategory.player1 | BitMaskCategory.player2
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
        
        let joystickTouchArea = SKShapeNode (circleOfRadius: 400)
        joystickTouchArea.position = joystickBase.position
        joystickTouchArea.zPosition = 19
        joystickTouchArea.strokeColor = .clear
        joystickTouchArea.fillColor = .clear
        joystickTouchArea.name = "joystickTouchArea"
        cameraNode?.addChild(joystickTouchArea)
        
        self.joystickTouchArea = joystickTouchArea
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
    
    func setupProgressBar() {
        progressBarBackground = SKSpriteNode(color: .gray, size: CGSize(width: 100, height: 15))
        progressBarBackground?.zPosition = 30
        progressBarBackground?.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressBarBackground?.position = CGPoint(x: -52, y: 245)
        cameraNode?.addChild(progressBarBackground!)
        progressBarBackground?.isHidden = true
        
        progressBar = SKSpriteNode(color: .green, size: CGSize(width: 0, height: 15))
        progressBar?.anchorPoint = CGPoint(x: 0, y: 0.5) //to make it grow from left to right
        progressBar?.position = CGPoint(x: -52, y: 245)
        progressBar?.zPosition = 31
        cameraNode?.addChild(progressBar!)
        progressBar?.isHidden = true
    }
    
    func updateProgressBar(elapsedTime: TimeInterval, totalTime: TimeInterval) {
        let progress = min(CGFloat(elapsedTime / totalTime), 1.0)
        progressBar?.size.width = 100 * progress
    }
    
    func setupSabotageButton() {
        let sabotageButton = SKSpriteNode(imageNamed: "sabotageButton")
        sabotageButton.position = CGPoint(x: 450, y: -280 )
        sabotageButton.size = CGSize(width: 180, height: 180)
        sabotageButton.alpha = 1.2
        sabotageButton.zPosition = 25
        sabotageButton.name = "sabotageButton"
        
        cameraNode?.addChild(sabotageButton)
        
        self.sabotageButton = sabotageButton
    }
    
    func setupSabotagedView() {
           maskNode = SKShapeNode(circleOfRadius: 1000)
           maskNode?.fillColor = .clear
           maskNode?.strokeColor = .white
           maskNode?.lineWidth = 0 // Start with a line width of 0
           maskNode?.position = thisPlayer.playerNode.position
           
           cropNode = SKCropNode()
           cropNode?.maskNode = maskNode
           cropNode?.zPosition = 10
           addChild(cropNode!)
           
           let background = SKSpriteNode(color: .black, size: CGSize(width: 5200, height: 5200))
           background.position = CGPoint(x: frame.midX, y: frame.midY)
           background.zPosition = 5
           cropNode?.addChild(background)
           
    
        let lineWidthAction = SKAction.customAction(withDuration: 3.0) { node, elapsedTime in
            let percentage = elapsedTime / 3.0
               self.maskNode?.lineWidth = 1825 * percentage
           }
           maskNode?.run(lineWidthAction)
        
        let sabotageLabel = SKLabelNode(fontNamed: "Palatino-Bold")
            sabotageLabel.text = "Your view will be sabotaged for 3 seconds!"
            sabotageLabel.fontSize = 27
            sabotageLabel.color = .black
            sabotageLabel.position = CGPoint(x: 0, y: 92)
            sabotageLabel.zPosition = 40
            cameraNode?.addChild(sabotageLabel)

            print("Children: \(self.children)")
            
            // Fade in
            sabotageLabel.alpha = 0
            let fadeInAction = SKAction.fadeIn(withDuration: 2)
            sabotageLabel.run(fadeInAction)
        
        let sabotageLabelDuration = SKAction.wait(forDuration: 5.0)
            let removeLabel = SKAction.run {
                sabotageLabel.removeFromParent()
            }
            let sequenceAction2 = SKAction.sequence([sabotageLabelDuration, removeLabel])
            run(sequenceAction2)
        
        
        let waitActionReversed = SKAction.wait(forDuration: 10.0)
            let reverseLineWidthActionReversed = SKAction.customAction(withDuration: 5.0) { node, elapsedTime in
                let percentage = 1 - (elapsedTime / 5.0)
                self.maskNode?.lineWidth = 1825 * percentage
            }
            let removeActionReversed = SKAction.run {
                self.maskNode?.removeFromParent()
                self.cropNode?.removeFromParent()
            }
            let sequenceActionReversed = SKAction.sequence([waitActionReversed, reverseLineWidthActionReversed, removeActionReversed])
            run(sequenceActionReversed)
        
//            sabotageButtonPressCount += 1
//
//            if sabotageButtonPressCount > 1 {
//                sabotageButton?.removeFromParent()
//                sabotageButton = nil
//            }
        

        _ = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) { [weak self] timer in
               self?.isSabotageButtonEnabled = true
        
           }
        }
    
    func animateCooldownTimer() {
        
        if !oneTimeTapfunction {
            oneTimeTapfunction = true
            
            let path = UIBezierPath(arcCenter: CGPoint.zero, radius: 77, startAngle: 0, endAngle:.pi * 2, clockwise: true)
            let shapeNode = SKShapeNode(path: path.cgPath)
            shapeNode.fillColor = .clear
            shapeNode.strokeColor = .gray
            shapeNode.lineWidth = 8
            shapeNode.position = CGPoint(x: 450, y: -256)
            shapeNode.zPosition = 26
            cameraNode?.addChild(shapeNode)
            
            //Dalam function ini, ketika dijalankan, otomatis membuat alpha dari sabotageButton menjadi 0.2
            sabotageButton?.alpha = 0.6
            
            let animation = SKAction.customAction(withDuration: 20.0) { node, elapsedTime in
                let percentage = elapsedTime / 20.0
                shapeNode.path = UIBezierPath(arcCenter: CGPoint.zero, radius: 88, startAngle: 0, endAngle:.pi * 2 * (1 - percentage), clockwise: true).cgPath
            }
            shapeNode.run(animation) {
                shapeNode.removeFromParent()
                self.isSabotageButtonEnabled = true
                self.sabotageButton?.alpha = 1
            }
        }
    }
    
    func setupPlantButton() {
        plantButton.size = CGSize(width: 40, height: 40)
        plantButton.zPosition = 20
        plantButton.alpha = 1
        addChild(plantButton)
        plantButton.isHidden = true
    }
    
    func setupDefuseButton() {
        defuseButton.size = CGSize(width: 70, height: 70)
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
        timeLeft = 60
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
//        let bombCondition = MPBombModel(bomb: .exploded, playerBombCondition: "exploded", winnerId: player2Id)
//        mpManager.send(bomb: bombCondition)
        self.winner = player2Model // terrorist win
        
        // print("DEBUG : Yang menang adalah \(player2Model.role)")
        
        self.isGameFinished = true
        if self.winner.id == self.thisPlayer.id{
            statementGameOver = "You Win"
            imageGameOver = "terrorist-bom-rightt-1"
            print("DEBUG_GO_EXPLODING_FUNC: TERRORIST WIN")
        } else{
            statementGameOver = "You Lose"
            imageGameOver = "fbi-borgol-right-1"
            print("DEBUG_GO_EXPLODING_FUNC: FBI LOSE")
            
        }
        
        if self.isGameFinished{
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
    
    func removeSabotageButtonAfterUse(){
        sabotageButtonPressCount += 1

        if sabotageButtonPressCount > 1 {
            sabotageButton?.removeFromParent()
//            sabotageButton = nil
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
        if thisPlayer.role == "terrorist"{
            if plantButton.contains(location) && !plantButton.isHidden && !isBombPlanted {
                bombPlantTimerStartTime = Date()
                print("lagi plant...")
                
                // show progress bar
                progressBarBackground?.isHidden = false
                progressBar?.isHidden = false
                
                self.terroristCondition = "terrorist-planting-bomb"
                
                //run planting animation
                thisPlayer.updatePlayerTextures(condition: terroristCondition)
                thisPlayer.animatePlantingBombAnimation()
                
                // sending to multipeer
                let bombCondition = MPBombModel(bomb: .planting, playerBombCondition: terroristCondition, winnerId: thisPlayer.id)
                mpManager.send(bomb: bombCondition)
            }
        }
        
        // Detecting touch on defuse button
        if thisPlayer.role == "fbi" {
            if defuseButton.contains(location) && !defuseButton.isHidden {
                defuseTimerStartTime = Date()
                print("lagi defuse...")
                
                // show progress bar
                progressBarBackground?.isHidden = false
                progressBar?.isHidden = false
                
                self.fbiCondition = "fbi-defusing-bomb"
                self.isDefusing = true
                
                //run defuse animation
                thisPlayer.updatePlayerTextures(condition: fbiCondition)
                thisPlayer.animateDefusingBomb()
                
                // sending to multipeer
                let bombCondition = MPBombModel(bomb: .defusing, playerBombCondition: fbiCondition, winnerId: thisPlayer.id)
                mpManager.send(bomb: bombCondition)
            }
        }
        
        if let sabotageButton = sabotageButton, let camera = cameraNode {
            let convertedLocation = camera.convert(location, from: self)
            if sabotageButton.contains(convertedLocation) && isSabotageButtonEnabled {
                
                // sending to multipeer
                let playerCondition = MPPlayerModel(action: .sabotagedView, playerId: thisPlayer.id, playerPosition: thisPlayer.playerNode.position, playerOrientation: thisPlayer.orientation, isVulnerable: thisPlayer.isVulnerable, winnerId: thisPlayer.id)
                
                mpManager.send(player: playerCondition)
                
                print("sabotageButton tapped")
                
                //Button Cooldown
                isSabotageButtonEnabled = false
                //Function cooldownTimer
                animateCooldownTimer()
                //function to remove sabotage button after 2x tap
                removeSabotageButtonAfterUse()
                
            }
            else if sabotageButton.contains(convertedLocation) && !isSabotageButtonEnabled{
                print("Button in cooldown")
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let joystick = joystick, let joystickKnob = joystickKnob, let camera = cameraNode {
            
            //Convert Lokasi touch dari Scene ke Cam
            let convertedLocation = camera.convert(location, from: self)
            if let unwrappedJoystickTouchArea = joystickTouchArea {
                if unwrappedJoystickTouchArea.contains(convertedLocation) {
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
//                                if !isWalkingSoundPlaying {
//                                                    AudioManager.shared.playWalkSound()
//                                                    isWalkingSoundPlaying = true
//                                                }
            }
//            else {
//                AudioManager.shared.stopWalkSound()
//                isWalkingSoundPlaying = false
//            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystickKnob = joystickKnob, let joystick = joystick else { return }
        let moveBack = SKAction.move(to: joystick.position, duration: 0.1)
        moveBack.timingMode = .easeOut
        joystickKnob.run(moveBack)
        
        // Terrorist cancelled planting bomb
        if thisPlayer.role == "terrorist"{
            if let bombPlantTimerStartTime = bombPlantTimerStartTime {
                let elapsedTime = Date().timeIntervalSince(bombPlantTimerStartTime)
                if elapsedTime < plantDuration {
                    print("cancel planting")
                    self.bombPlantTimerStartTime = nil
                    
                    // remove progress bar
                    progressBarBackground?.isHidden = true
                    progressBar?.isHidden = true
                    
                    // change terrorist condition from terrorist-planting-bomb to terrorist-initial
                    self.terroristCondition = "terrorist-initial"
                    thisPlayer.updatePlayerTextures(condition: terroristCondition)
                    
                    //remove planting animation
                    thisPlayer.stopPlantingBombAnimation()
                    
                    // sending to multipeer
                    let bombCondition = MPBombModel(bomb: .cancelledPlanting, playerBombCondition: terroristCondition, winnerId: thisPlayer.id)
                    mpManager.send(bomb: bombCondition)
                    
                }
            }
        }
        
        if thisPlayer.role == "fbi"{
            if let defuseTimerStartTime = defuseTimerStartTime {
                let elapsedTime = Date().timeIntervalSince(defuseTimerStartTime)
                if elapsedTime < defuseDuration {
                    print("cancel defusing")
                    self.defuseTimerStartTime = nil
                    
                    // remove progress bar
                    progressBarBackground?.isHidden = true
                    progressBar?.isHidden = true
                    
                    // change fbi condition from fbi-defusing-bomb to fbi-cancel-defusing
                    self.fbiCondition = "fbi-cancel-defusing"
                    self.isDefusing = false
                    
                    // run cancel defuse animation:
                    thisPlayer.cancelDefuseAnimation() // there's delay after cancelling defuse animation
                    
                    // remove defusing animation
                    thisPlayer.stopDefusingBombAnimation()
                    
                    // sending to multipeer
                    let bombCondition = MPBombModel(bomb: .cancelledDefusing, playerBombCondition: fbiCondition, winnerId: thisPlayer.id)
                    mpManager.send(bomb: bombCondition)
                    
                    //Start delay timer:
                    defuseCooldownStartTime = Date()
                    isDelayingMove = true
                }
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
                let offset: CGFloat = 10.0
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
        //delaymove
        if thisPlayer.role == "fbi"{
            if isDelayingMove {
                thisPlayer.playerNode.physicsBody?.velocity = .zero
                thisPlayer.playerNode.removeAction(forKey: "moveLeft")
                thisPlayer.playerNode.removeAction(forKey: "moveRight")
                
                if let defuseCooldownStartTime = defuseCooldownStartTime {
                    let cooldownElapsedTime = Date().timeIntervalSince(defuseCooldownStartTime)
                    if cooldownElapsedTime >= defuseCooldownDuration {
                        thisPlayer.playerNode.removeAction(forKey: "delayCancelling")
                        
                        switch thisPlayer.previousOrientation {
                        case "left" :
                            thisPlayer.playerNode.texture = thisPlayer.latestTextureLeft
                        case "right" :
                            thisPlayer.playerNode.texture = thisPlayer.latestTextureRight
                        default:
                            thisPlayer.playerNode.texture = thisPlayer.latestTextureRight
                        }
                        
                        isDelayingMove = false
                        self.defuseCooldownStartTime = nil
                        
                        // setting the vulnerability
                        player1Model.isVulnerable = true // fbi
                        player2Model.isVulnerable = false // terrorist
                        
                        // change from fbi-cancel-defusing
                        
                    }
                    self.fbiCondition = "fbi-initial"
                }
                return
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
        if thisPlayer.role == "terrorist"{
            if let bombPlantTimerStartTime = bombPlantTimerStartTime {
                let elapsedTime = Date().timeIntervalSince(bombPlantTimerStartTime)
                updateProgressBar(elapsedTime: elapsedTime, totalTime: plantDuration)
                if elapsedTime >= plantDuration {
                    print("Success planting bomb")
                    self.addBombNode()
                    self.bombPlantTimerStartTime = nil
                    
                    //remove the progress bar
                    progressBarBackground?.isHidden = true
                    progressBar?.isHidden = true
                    
                    //remove planting animation
                    thisPlayer.stopPlantingBombAnimation()
                    
                    //  sending location of the bomb to other player
                    let bombCondition = MPBombModel(bomb: .planted, playerBombCondition: "terrorist-planted-bomb", winnerId: thisPlayer.id)
                    self.mpManager.send(bomb: bombCondition)
                    
                }
            }
        }
        
        // defuse bomb if players already held defuse button for a certain period of time
        if thisPlayer.role == "fbi"{
            if let defuseTimerStartTime = defuseTimerStartTime {
                let elapsedTime = Date().timeIntervalSince(defuseTimerStartTime)
                updateProgressBar(elapsedTime: elapsedTime, totalTime: defuseDuration)
                if elapsedTime >= defuseDuration {
                    print("Success defusing bomb")
                    self.defuseBombNode()
                    self.defuseTimerStartTime = nil
                    
                    //remove the progress bar
                    progressBarBackground?.isHidden = true
                    progressBar?.isHidden = true
                    
                    //remove defusing animation
                    thisPlayer.playerNode.removeAction(forKey: "defusingAnimation")
                    
                    //  sending bomb condition to multipeer
                    let bombCondition = MPBombModel(bomb: .defused, playerBombCondition: "fbi-defused-bomb", winnerId: player1Id)
                    self.mpManager.send(bomb: bombCondition)
                    
                    
                    timer?.invalidate()
                    
                    self.winner = player1Model // fbi wins
                    
                    isGameFinished = true
                    if self.winner.id == self.thisPlayer.id{
                        statementGameOver = "You Win"
                        imageGameOver = "fbi-borgol-right-1"
                        print("DEBUG_GO_COLS: TERRORIST WIN")
                    } else{
                        statementGameOver = "You Lose"
                        imageGameOver = "terrorist-bom-rightt-1"
                        print("DEBUG_GO_COLS: FBI LOSE")
                        
                    }
                    
                    if isGameFinished{
                        removeAllNodes()
                    }
                }
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
        
        
        AudioManager.shared.playBombTimerSound()
        AudioManager.shared.playBombPlantedAlertMusic()
        startTimer()
    }
    
    func defuseBombNode(){
        
        self.defuseButton.isHidden = true
        self.timerLabel?.isHidden = true
        if let bombNode = self.childNode(withName: "bomb") {
            bombNode.removeFromParent()
        }
        
    }
    
    func handlePlayer(player: MPPlayerModel, mpManager: MultipeerConnectionManager) {
        switch player.action {
        case .start:
            print("Start")
        case .move:
            self.moveOtherPlayer(id: player.playerId, pos: player.playerPosition, orientation: player.playerOrientation)
        case .sabotagedView:
            print("sabotaged view")
            setupSabotagedView()
            
        case .death:
            print("Start")
        case .reset:
            print("Start")
        case .end:
            print("DEBUG_GAMEOVER awal : role \(thisPlayer.id) || \(statementGameOver)")
            if player.winnerId == thisPlayer.id{
                if thisPlayer.role == "fbi"{
                    statementGameOver = "FBI_WIN"
                    print("DEBUG_GAMEOVER role FBI : \(statementGameOver)")
                } else if thisPlayer.role == "terrorist"{
                    statementGameOver = "TERRORIST_WIN"
                    print("DEBUG_GAMEOVER role TERRORIST : \(statementGameOver)")
                }
            } else if player.winnerId != thisPlayer.id{
                if thisPlayer.role == "fbi"{
                    statementGameOver = "TERRORIST_WIN"
                    print("DEBUG_GAMEOVER role FBI : \(statementGameOver)")
                } else if thisPlayer.role == "terrorist" {
                    statementGameOver = "FBI_WIN"
                    print("DEBUG_GAMEOVER role TERRORIST : \(statementGameOver)")
                }
            }
            
            self.isGameFinished = true
            
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
        case .planting:
            print("planting")
            updateOtherPlayerTextures(condition: bomb.playerBombCondition)
            player2Model.animatePlantingBombAnimation() // terrorist animate planting bomb
        case .cancelledPlanting:
            print("cancel planting")
            player2Model.stopPlantingBombAnimation() // terrorist stop animate planting bomb
            updateOtherPlayerTextures(condition: bomb.playerBombCondition)
        case .planted:
            print("planted")
            updateOtherPlayerTextures(condition: bomb.playerBombCondition)
            player2Model.stopPlantingBombAnimation() // terrorist stop animate planting bomb
            synchronizeOtherPlayerBombCondition(isDefused: false)
//            updatePlayerVulnerability()
        case .approachedByPlayers:
            print("bomb approached by players")
            updateOtherPlayerTextures(condition: bomb.playerBombCondition)
        case .defusing:
            print("defusing")
            updateOtherPlayerTextures(condition: bomb.playerBombCondition)
            player1Model.animateDefusingBomb() // fbi animate defusing bomb
            
//            // if defusing, fbi becomes vulnerable
//            if self.thisPlayer.role == "fbi"{
//                self.thisPlayer.isVulnerable = true
//            }else{
//                self.thisPlayer.isVulnerable = false
//            }
            
        case .cancelledDefusing:
            print("cancelled defusing")
            player1Model.cancelDefuseAnimation() // there's delay when cancelled defusing bomb
            player1Model.stopDefusingBombAnimation() // fbi stop animate defusing bomb
            updateOtherPlayerTextures(condition: bomb.playerBombCondition)
            
        case .defused:
            print("defused")
            synchronizeOtherPlayerBombCondition(isDefused: true)
            AudioManager.shared.stopBombTimerSound()
            
            self.isGameFinished = true
            if bomb.winnerId == self.thisPlayer.id{
                statementGameOver = "You Win"
                imageGameOver = "fbi-borgol-right-1"
                print("DEBUG_GO_COLS_DEFUSED: TERRORIST WIN")
            } else{
                statementGameOver = "You Lose"
                imageGameOver = "terrorist-bom-rightt-1"
                print("DEBUG_GO_COLS_DEFUSED: FBI LOSE")
                
            }
            
            if self.isGameFinished{
                removeAllNodes()
            }
            mpManager.session.disconnect()
        case .exploded:
            print("exploded")
            
            self.isGameFinished = true
            if bomb.winnerId == self.thisPlayer.id{
                statementGameOver = "You Win"
                imageGameOver = "terrorist-bom-rightt-1"
                print("DEBUG_GO_EXPLODED: TERRORIST WIN")
            } else{
                statementGameOver = "You Lose"
                imageGameOver = "fbi-borgol-right-1"
                print("DEBUG_GO_EXPLODED: FBI LOSE")
                
            }
            
            if self.isGameFinished{
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
    
    func updateOtherPlayerTextures(condition: String){
        if thisPlayer.role == "fbi"{
            // other player is terrorist
            print("DEBUG: condition for updateOtherPlayer \(condition)")
            if condition == "terrorist-planted-bomb"{
                print("DEBUG: went in the if")
                player2Model.playerRightTextures = terroristRightNone
                player2Model.playerLeftTextures = terroristLeftNone
            } else if condition == "terrorist-near-bomb"{
                player2Model.playerRightTextures = terroristRightPentungan
                player2Model.playerLeftTextures = terroristLeftPentungan
            } else if condition == "terrorist-planting-bomb"{
                player2Model.playerRightTextures = terroristRightPlantBomb
                player2Model.playerLeftTextures = terroristLeftPlantBomb
            } else if condition == "terrorist-initial"{
                player2Model.playerRightTextures = terroristRightTextures
                player2Model.playerLeftTextures = terroristLeftTextures
            }
            player2Model.latestTextureLeft = player2Model.playerLeftTextures[player2Model.playerLeftTextures.count - 1]
            player2Model.latestTextureRight = player2Model.playerRightTextures[player2Model.playerRightTextures.count - 1]
        } else {
            // other player is fbi
            if condition == "fbi-near-bomb"{
                player1Model.playerRightTextures = fbiRightTang
                player1Model.playerLeftTextures = fbiLeftTang
            } else if condition == "fbi-defusing-bomb"{
                player1Model.playerRightTextures = fbiRightDefuseBomb
                player1Model.playerLeftTextures = fbiLeftDefuseBomb
            } else if condition == "fbi-cancel-defusing"{
                // not yet defined left and right
                player1Model.playerRightTextures = fbiDefuseDelayTexture
                player1Model.playerLeftTextures = fbiDefuseDelayTexture
            }  else {
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
        
        if (bodyA.categoryBitMask == BitMaskCategory.player1 && bodyB.categoryBitMask == BitMaskCategory.player2) ||
            (bodyA.categoryBitMask == BitMaskCategory.player2 && bodyB.categoryBitMask == BitMaskCategory.player1) {
            print("Player 1 and Player 2 collided")
            handlePlayerCollision()
            
            // Handle collision between player1 and player2
        } else if (bodyA.categoryBitMask == BitMaskCategory.player1 && bodyB.categoryBitMask == BitMaskCategory.maze) ||
                    (bodyA.categoryBitMask == BitMaskCategory.maze && bodyB.categoryBitMask == BitMaskCategory.player1) {
            print("Player 1 collided with the maze")
            // Handle collision between player1 and the maze
        } else if (bodyA.categoryBitMask == BitMaskCategory.player2 && bodyB.categoryBitMask == BitMaskCategory.maze) ||
                    (bodyA.categoryBitMask == BitMaskCategory.maze && bodyB.categoryBitMask == BitMaskCategory.player2) {
            print("Player 2 collided with the maze")
            // Handle collision between player2 and the maze
        }
        
//         is not applicable when there's a lot of spritenode
//                let bodyA = contact.bodyA
//                let bodyB = contact.bodyB
//        
//                // Determine the categories involved in the collision
//                let collision = bodyA.categoryBitMask | bodyB.categoryBitMask
//                print("DEBUG: bodyA = \(bodyA.categoryBitMask), bodyB = \(bodyB.categoryBitMask)")
//                print("DEBUG: bodyA = \(BitMaskCategory.player1), bodyB = \(BitMaskCategory.player2)")
//        
//                switch collision {
//                case BitMaskCategory.player1 | BitMaskCategory.player2:
//                    // FBI and terrorist collided
//                    print("FBI and terrorist collided")
//                    handlePlayerCollision()
//                case BitMaskCategory.player1 | BitMaskCategory.maze:
//                    // FBI and maze collided
//                    print("FBI and maze collided")
//        
//                case BitMaskCategory.player2 | BitMaskCategory.maze:
//                    // Terrorist and maze collided
//                    print("Terrorist and maze collided")
//        
//                default:
//                    break
//                }
    }
    
    func handlePlayerCollision() {
//        thisPlayer.updatePlayerVulnerability()
        
        if thisPlayer.role == "fbi"{
            print("DEBUG handleplayercollision: vulnerable \(player1Model.isVulnerable), role: \(player1Model.role)")
            if player1Model.isVulnerable{
                print("DEBUG_COL : you (fbi) lose")
                gameOverByCollision(winner: "terrorist", playerRole: thisPlayer.role)
            } else {
                print("DEBUG_COL : you (fbi) win")
                gameOverByCollision(winner: "fbi", playerRole: thisPlayer.role)
            }
        } 
//        else if thisPlayer.role == "terrorist" {
//            print("DEBUG handleplayercollision: vulnerable \(player2Model.isVulnerable), role: \(player2Model.role)")
//            if player2Model.isVulnerable {
//                print("DEBUG_COL : you (terrorist) lose")
//                gameOverByCollision(winner: "fbi", playerRole: thisPlayer.role)
//            } else {
//                print("DEBUG_COL : you (terrorist) win")
//                gameOverByCollision(winner: "terrorist", playerRole: thisPlayer.role)
//            }
//        }
    }
    
    func gameOverByCollision(winner: String, playerRole: String){
        self.isGameFinished = true
        
        if winner == "fbi"{
            self.winner = player1Model //fbi wins
            
//            sending multipeer
            let playerCondition = MPPlayerModel(action: .end, playerId: thisPlayer.id, playerPosition: thisPlayer.playerNode.position, playerOrientation: thisPlayer.orientation, isVulnerable: thisPlayer.isVulnerable, winnerId: self.winner.id)
            
            mpManager.send(player: playerCondition)
            
            statementGameOver = "FBI_WIN"
        } else {
            self.winner = player2Model // terrorist wins
            
//            sending multipeer
            let playerCondition = MPPlayerModel(action: .end, playerId: thisPlayer.id, playerPosition: thisPlayer.playerNode.position, playerOrientation: thisPlayer.orientation, isVulnerable: thisPlayer.isVulnerable, winnerId: self.winner.id)
            
            mpManager.send(player: playerCondition)
            
            statementGameOver = "TERRORIST_WIN"
        }
        
        if self.isGameFinished{
            removeAllNodes()
        }
    }
}
