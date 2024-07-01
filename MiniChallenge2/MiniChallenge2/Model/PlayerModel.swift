//
//  PlayerModel.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 12/06/24.
//

import Foundation
import SpriteKit

class PlayerModel: ObservableObject {
    @Published var id: String
    @Published var playerNode: SKSpriteNode
    
    var playerRightTextures: [SKTexture] = []
    var playerLeftTextures: [SKTexture] = []
    var gameScene: GameScene
    var speedMultiplier: Double = 0.0
    var isVulnerable: Bool = false
    var role: String = ""
    var playerTextureIndex: Int = 0
    var orientation: String = ""
    var previousCondition: String = ""
    var previousOrientation: String = "not-moving"
    // For notWalking Texture
    var latestTextureRight: SKTexture = SKTexture(imageNamed: "")
    var latestTextureLeft: SKTexture = SKTexture(imageNamed: "")
    var playerPreviousRightLeft: String?
    var isWalkingSoundPlaying = false
//    var playerVelocity: Double = 0.0
    
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
    
    init(id: String, gameScene: GameScene) {
        self.id = id
        self.gameScene = gameScene
        
        playerNode = SKSpriteNode(color: UIColor.gray, size: CGSize(width: 28, height: 28))
        playerNode.zPosition = 2
        
        print("DEBUG")
        print("===========================")
        print("player 1 id: \(gameScene.player1Id ?? "none")")
        print("player 2 id: \(gameScene.player2Id ?? "none")")
        print("this player id: \(self.id)")
        
        if(self.id == gameScene.player1Id){
            playerNode.name = "Player1"
            playerNode.position = CGPoint(x: 3.57, y: 945.85)
//          playerNode.position = CGPoint(x: -269, y: -31)
            self.playerRightTextures = fbiRightTextures
            self.playerLeftTextures = fbiLeftTextures
            speedMultiplier = 1.9
            isVulnerable = false
            role = "fbi"
        } else {
            playerNode.name = "Player2"
            playerNode.position = CGPoint(x: 48.57, y: -350)
//            playerNode.position = CGPoint(x: -335, y: -116)
            self.playerRightTextures = fbiRightTextures
            self.playerLeftTextures = fbiLeftTextures
            speedMultiplier = 1.8
            isVulnerable = true
            role = "terrorist"
        }
//        // assigning latest texture
        self.latestTextureRight = playerRightTextures[0]
        self.latestTextureLeft = playerLeftTextures[0]
        
        // Setting up Physics Body to player
//        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width / 2)
        playerNode.physicsBody = SKPhysicsBody(texture: playerRightTextures[playerTextureIndex], size: playerNode.size)
        playerNode.texture = playerRightTextures[0]
        
        if(self.id == gameScene.player1Id){
            // fbi
            playerNode.physicsBody?.categoryBitMask = BitMaskCategory.player1
            playerNode.physicsBody?.contactTestBitMask = BitMaskCategory.player2 | BitMaskCategory.maze
            playerNode.physicsBody?.collisionBitMask = BitMaskCategory.player2 | BitMaskCategory.maze
        } else if (self.id == gameScene.player2Id){
            // terrorist
            playerNode.physicsBody?.categoryBitMask = BitMaskCategory.player2
            playerNode.physicsBody?.contactTestBitMask = BitMaskCategory.player1 | BitMaskCategory.maze
            playerNode.physicsBody?.collisionBitMask = BitMaskCategory.player1 | BitMaskCategory.maze
        }
//        playerNode.anchorPoint = CGPoint(x: 0.495, y: 0.6)
        playerNode.physicsBody?.affectedByGravity = false
        playerNode.physicsBody?.isDynamic = true
        playerNode.physicsBody?.allowsRotation = false
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
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
    
    func movePlayer(velocity: CGVector, mpManager: MultipeerConnectionManager, condition: String) {
        
        playerNode.physicsBody?.velocity = velocity
        
        // assigning player walking orientation
        if velocity.dx > 0 {
            // Move Right
                self.orientation = "right"
                playerPreviousRightLeft = "right"
            
            if !isWalkingSoundPlaying {
                                AudioManager.shared.playWalkSound()
                                isWalkingSoundPlaying = true
                            }
            
        } else if velocity.dx < 0 {
            // Move Left
                self.orientation = "left"
                playerPreviousRightLeft = "left"
            
            if !isWalkingSoundPlaying {
                                AudioManager.shared.playWalkSound()
                                isWalkingSoundPlaying = true
                            }
            
        } else {
            self.orientation = "not-moving"
            AudioManager.shared.stopWalkSound()
            isWalkingSoundPlaying = false
        }
        
        // assigning player textures
        updatePlayerTextures(condition: condition, role: self.role)
        animateWalking(orientation: self.orientation, condition: condition)
              
        print("FBI is defusing? \(gameScene.isDefusing)")
        print ("FBI is delaying? \(gameScene.isDelayingMove)")
        
//        print("role? \(role)")
        if role == "fbi" {
            if gameScene.isDefusing {
                self.isVulnerable = true
            }
            else if gameScene.isDelayingMove {
                self.isVulnerable = true
            }
            else {
                self.isVulnerable = false
            }
        }
            
        //sending the movement to multipeer
        let playerCondition = MPPlayerModel(
                action: .move,
                playerId: self.id,
                playerPosition: playerNode.position,
                playerOrientation: self.orientation,
                isVulnerable: self.isVulnerable,
                winnerId: "_NaN_")
        mpManager.send(player: playerCondition)
    }
    
    func updatePlayerTextures(condition: String, role: String){
        print("DEBUG: role \(self.role)")
        print("DEBUG: condition \(condition)")
        if role == "terrorist"{
            if condition == "terrorist-planted-bomb"{
                playerRightTextures = terroristRightNone
                playerLeftTextures = terroristLeftNone
            } else if condition == "terrorist-near-bomb"{
                playerRightTextures = terroristRightPentungan
                playerLeftTextures = terroristLeftPentungan
            } else if condition == "terrorist-planting-bomb"{
                playerRightTextures = terroristRightPlantBomb
                playerLeftTextures = terroristLeftPlantBomb
            } else if condition == "terrorist-initial"{
                playerRightTextures = terroristRightTextures
                playerLeftTextures = terroristLeftTextures
            }
        }
        // role fbi
        else {
            if condition == "fbi-near-bomb"{
                playerRightTextures = fbiRightTang
                playerLeftTextures = fbiLeftTang
            } else if condition == "fbi-far-from-bomb"{
                playerRightTextures = fbiRightTextures
                playerLeftTextures = fbiLeftTextures
            } else if condition == "fbi-defusing-bomb"{
                playerRightTextures = fbiRightDefuseBomb
                playerLeftTextures = fbiLeftDefuseBomb
            } else if condition == "fbi-cancel-defusing"{
                playerRightTextures = fbiDefuseDelayTexture
                playerLeftTextures = fbiDefuseDelayTexture
            }
        }
        // Add latestTexture for animateNotWalking with last index of textures's array
        self.latestTextureRight = playerRightTextures[playerRightTextures.count - 1]
        self.latestTextureLeft = playerLeftTextures[playerLeftTextures.count - 1]
    }
    
    func animateWalking(orientation: String, condition: String){
        // Only update the animation if the condition has changed
        if condition != previousCondition {
            // Update the previous condition
            previousCondition = condition
            
            // Remove current walking actions
            playerNode.removeAction(forKey: "moveRight")
            playerNode.removeAction(forKey: "moveLeft")
            
            // Add new walking action based on the orientation
            if orientation == "right" {
                let walkToRight = SKAction.repeatForever(SKAction.animate(with: playerRightTextures, timePerFrame: 0.1))
                playerNode.run(walkToRight, withKey: "moveRight")
            } else if orientation == "left" {
                let walkToLeft = SKAction.repeatForever(SKAction.animate(with: playerLeftTextures, timePerFrame: 0.1))
                playerNode.run(walkToLeft, withKey: "moveLeft")
            }
        } else {
            // Update the animation if the orientation changes while keeping the same condition
            if orientation != previousOrientation {
                if orientation == "right" {
                    if playerNode.action(forKey: "moveRight") == nil {
                        playerNode.removeAction(forKey: "moveLeft")
                        let walkToRight = SKAction.repeatForever(SKAction.animate(with: playerRightTextures, timePerFrame: 0.1))
                        playerNode.run(walkToRight, withKey: "moveRight")
                    }
                } else if orientation == "left" {
                    if playerNode.action(forKey: "moveLeft") == nil {
                        playerNode.removeAction(forKey: "moveRight")
                        let walkToLeft = SKAction.repeatForever(SKAction.animate(with: playerLeftTextures, timePerFrame: 0.1))
                        playerNode.run(walkToLeft, withKey: "moveLeft")
                    }
                // If player is notWalking
                } else {
                    playerNode.removeAction(forKey: "moveRight")
                    playerNode.removeAction(forKey: "moveLeft")
                    
                    if previousOrientation == "right"{
                        playerNode.texture = latestTextureRight
                        // print("DEBUG: show notWalkingRight texture")
                    }else {
                        playerNode.texture = latestTextureLeft
                        // print("DEBUG: show notWalkingLeft texture")
                    }
                            
                }
                
                // Update the previous orientation
                previousOrientation = orientation
            }
        }
    }
    
    func animatePlantingBombAnimation(){
        
        print("DEBUG: previous Orientation \(self.previousOrientation)")
        switch self.playerPreviousRightLeft {
        case "left":
            self.playerNode.run(SKAction.repeatForever(SKAction.animate(with: self.playerLeftTextures, timePerFrame: 0.1)), withKey: "plantingAnimation")
        case "right":
            self.playerNode.run(SKAction.repeatForever(SKAction.animate(with: self.playerRightTextures, timePerFrame: 0.1)), withKey: "plantingAnimation")
        default:
            self.playerNode.run(SKAction.repeatForever(SKAction.animate(with: self.playerRightTextures, timePerFrame: 0.1)), withKey: "plantingAnimation")
        }
    }
    
    func stopPlantingBombAnimation(){
        self.playerNode.removeAction(forKey: "plantingAnimation")
        self.playerNode.texture = latestTextureRight
    }
    
    func animateDefusingBomb(){
        switch self.playerPreviousRightLeft {
        case "left":
            self.playerNode.run(SKAction.repeatForever(SKAction.animate(with: self.playerLeftTextures, timePerFrame: 0.1)), withKey: "defusingAnimation")
        case "right":
            self.playerNode.run(SKAction.repeatForever(SKAction.animate(with: self.playerRightTextures, timePerFrame: 0.1)), withKey: "defusingAnimation")
        default:
            self.playerNode.run(SKAction.repeatForever(SKAction.animate(with: self.playerRightTextures, timePerFrame: 0.1)), withKey: "defusingAnimation")
        }
    }
    
    func cancelDefuseAnimation(){
        self.playerNode.run(SKAction.repeatForever(SKAction.animate(with: fbiDefuseDelayTexture, timePerFrame: 0.1)), withKey: "delayCancelling")
    }
    
    func stopDefusingBombAnimation(){
        self.playerNode.removeAction(forKey: "defusingAnimation")
    }
    
    func synchronizeOtherPlayerPosition(position: CGPoint, orientation: String, condition: String) {
        playerNode.position = position
        
//        updatePlayerTextures(condition: condition)
        animateWalking(orientation: orientation, condition: condition)
    }
}
