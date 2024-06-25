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
    
    var playerRightTextures: [SKTexture]
    var playerLeftTextures: [SKTexture]
    var gameScene: GameScene
    var speedMultiplier: Double
    var isVulnerable: Bool
    var role: String
    var playerTextureIndex: Int = 0
    var orientation: String = ""
    var previousCondition: String = ""
    var previousOrientation: String = "not-moving"
    // For notWalking Texture
    var latestTextureRight: SKTexture
    var latestTextureLeft: SKTexture
    var playerPreviousRightLeft: String?
    
    init(id: String, playerRightTextures: [SKTexture], playerLeftTextures: [SKTexture], gameScene: GameScene) {
        self.id = id
        self.playerRightTextures = playerRightTextures
        self.playerLeftTextures = playerLeftTextures
        self.gameScene = gameScene
        self.speedMultiplier = 0
        self.isVulnerable = true
        self.role = ""
        self.latestTextureRight = playerRightTextures[0]
        self.latestTextureLeft = playerLeftTextures[0]
        
        playerNode = SKSpriteNode(color: UIColor.gray, size: CGSize(width: 30, height: 30))
        playerNode.zPosition = 2
        
        print("DEBUG")
        print("===========================")
        print("player 1 id: \(gameScene.player1Id ?? "none")")
        print("player 2 id: \(gameScene.player2Id ?? "none")")
        print("this player id: \(self.id)")
        
        if(self.id == gameScene.player1Id){
            playerNode.name = "Player1"
            playerNode.position = CGPoint(x: 3.57, y: 945.85)
//            playerNode.position = CGPoint(x: -269, y: -31)
            speedMultiplier = 2
            isVulnerable = false
            role = "fbi"
        } else {
            playerNode.name = "Player2"
            playerNode.position = CGPoint(x: 48.57, y: -354)
//            playerNode.position = CGPoint(x: -335, y: -116)
            speedMultiplier = 1.5
            isVulnerable = true
            role = "terrorist"
        }
        
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
    
    func movePlayer(velocity: CGVector, mpManager: MultipeerConnectionManager, condition: String) {
        
        playerNode.physicsBody?.velocity = velocity
        
        // assigning player walking orientation
        if velocity.dx > 0 {
            // Move Right
                self.orientation = "right"
                playerPreviousRightLeft = "right"
        } else if velocity.dx < 0 {
            // Move Left
                self.orientation = "left"
                playerPreviousRightLeft = "left"
            
        } else {
            self.orientation = "not-moving"
        }
        
        // assigning player textures
        updatePlayerTextures(condition: condition)
        animateWalking(orientation: self.orientation, condition: condition)
        
        //setting vulnerability
//        self.checkPlayerVulnerability()
//        if self.role == "fbi" {
//            if gameScene.isDefusing || gameScene.isDelayingMove {
//                self.isVulnerable = true
//            } else {
//                self.isVulnerable = false
//            }
//        } else if self.role == "terrorist" {
//            if gameScene.isDefusing || gameScene.isDelayingMove {
//                self.isVulnerable = false
//            } else {
//                self.isVulnerable = true
//            }
//        }
        
//        if self.role == "fbi" && (gameScene.isDefusing || gameScene.isDelayingMove) {
//            self.isVulnerable = true
//        } else {
//            self.isVulnerable = false
//        }
//        
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
        
        
        
//        else if role == "terrorist" {
//            if gameScene.isDefusing2 {
//                self.isVulnerable = false
//            }
//            else if gameScene.isDelayingMove {
//                self.isVulnerable = false
//            }
//            else {
//                self.isVulnerable = true
//            }
//        }
            
        
        
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
    
    func updatePlayerVulnerability(){
        // setting vulnerability
        print("DEBUG: condition \(gameScene.fbiCondition), vulnerability \(isVulnerable)")
        print("DEBUG: condition \(gameScene.terroristCondition), vulnerability \(isVulnerable)")
        if self.role == "fbi"{
            if gameScene.fbiCondition == "fbi-defusing-bomb" || gameScene.fbiCondition == "fbi-cancel-defusing" {
                self.isVulnerable = true
            } else{
                self.isVulnerable = false
            }
        } else if self.role == "terrorist"{
            if gameScene.terroristCondition == "terrorist-initial" || gameScene.terroristCondition == "terrorist-planting-bomb" || gameScene.terroristCondition == "terrorist-planted-bomb" {
                self.isVulnerable = true
            }else if gameScene.terroristCondition == "terrorist-near-bomb" && (gameScene.fbiCondition == "fbi-defusing-bomb" || gameScene.fbiCondition == "fbi-cancel-defusing"){
                self.isVulnerable = false
            }
        }
        print("DEBUG: condition \(gameScene.fbiCondition), vulnerability \(isVulnerable)")
        print("DEBUG: condition \(gameScene.terroristCondition), vulnerability \(isVulnerable)")
    }
    
    func updatePlayerTextures(condition: String){
        print("DEBUG: role \(self.role)")
        print("DEBUG: condition \(condition)")
        if self.role == "terrorist"{
            if condition == "terrorist-planted-bomb"{
                playerRightTextures = gameScene.getTerroristTextures(type: "none-right")
                playerLeftTextures = gameScene.getTerroristTextures(type: "none-left")
            } else if condition == "terrorist-near-bomb"{
                playerRightTextures = gameScene.getTerroristTextures(type: "pentungan-right")
                playerLeftTextures = gameScene.getTerroristTextures(type: "pentungan-left")
            } else if condition == "terrorist-planting-bomb"{
                playerRightTextures = gameScene.getTerroristTextures(type: "plantbomb-right")
                playerLeftTextures = gameScene.getTerroristTextures(type: "plantbomb-left")
            } else if condition == "terrorist-initial"{
                playerRightTextures = gameScene.getTerroristTextures(type: "bomb-right")
                playerLeftTextures = gameScene.getTerroristTextures(type: "bomb-left")
            }
        }
        // role fbi
        else {
            if condition == "fbi-near-bomb"{
                playerRightTextures = gameScene.getFBITextures(type: "tang-right")
                playerLeftTextures = gameScene.getFBITextures(type: "tang-left")
            } else if condition == "fbi-far-from-bomb"{
                playerRightTextures = gameScene.getFBITextures(type: "borgol-right")
                playerLeftTextures = gameScene.getFBITextures(type: "borgol-left")
            } else if condition == "fbi-defusing-bomb"{
                playerRightTextures = gameScene.getFBITextures(type: "defuse-right")
                playerLeftTextures = gameScene.getFBITextures(type: "defuse-left")
            } else if condition == "fbi-cancel-defusing"{
                playerRightTextures = gameScene.getFBITextures(type: "delay")
                playerLeftTextures = gameScene.getFBITextures(type: "delay")
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
        self.playerNode.run(SKAction.repeatForever(SKAction.animate(with: gameScene.getFBITextures(type: "delay"), timePerFrame: 0.1)), withKey: "delayCancelling")
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
