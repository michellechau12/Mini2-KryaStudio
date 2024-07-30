//
//  PlantButton.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class PlantButton: SKScene{
    
    var plantButton = SKSpriteNode(imageNamed: "plantButton")
    var isPlantButtonEnabled = false
    
    var bombPlantTimer: Timer?
    var bombPlantTimerStartTime: Date?
    var plantDuration = 3.0
    
    // terrorist is ...
    var isBombLoadingPlanting = false
    var isBombNodeAdded = false
    
    // for joystick to stop moving when button pressed
    var isPlantButtonPressed = false
    
    func setupPlantButton(){
            plantButton.position = CGPoint(x: 450, y: -110 )
            plantButton.size = CGSize(width: 130, height: 130)
            plantButton.alpha = 0.2
            plantButton.zPosition = 25
            plantButton.name = "plantButton"
    }
    
    func startPlantingBomb(cameraNode: SKCameraNode?, location: CGPoint, thisPlayer: PlayerModel, progressBar: ProgressBar, mpManager: MultipeerConnectionManager) -> String{
        
        if let camera = cameraNode {
            let convertedLocation = camera.convert(location, from: self)
            if plantButton.contains(convertedLocation) && isPlantButtonEnabled && thisPlayer.orientation == "not-moving" {
                bombPlantTimerStartTime = Date()
                print("lagi plant...")
                
                // show progress bar
                progressBar.progressBarBackground?.isHidden = false
                progressBar.progressBar?.isHidden = false
                
                //run planting animation
                thisPlayer.updatePlayerTextures(condition: "terrorist-planting-bomb")
                thisPlayer.animatePlantingBombAnimation()
                
                // sending to multipeer
                let bombCondition = MPBombModel(bomb: .planting, playerBombCondition: "terrorist-planting-bomb", winnerId: thisPlayer.id)
                mpManager.send(bomb: bombCondition)
                
   
                isPlantButtonPressed = true
                
                return "terrorist-planting-bomb"
            }
        }
        return ""
    }
    
    func cancelledPlantingBomb(progressBar: ProgressBar, thisPlayer: PlayerModel, mpManager: MultipeerConnectionManager) -> String{
        if let bombPlantTimerStartTime = bombPlantTimerStartTime {
            let elapsedTime = Date().timeIntervalSince(bombPlantTimerStartTime)
            if elapsedTime < plantDuration {
                print("cancel planting")
                self.bombPlantTimerStartTime = nil
                
                // remove progress bar
                progressBar.progressBarBackground?.isHidden = true
                progressBar.progressBar?.isHidden = true
                
                // change terrorist condition from terrorist-planting-bomb to terrorist-initial
                
                thisPlayer.updatePlayerTextures(condition: "terrorist-initial")
                
                // remove planting animation
                thisPlayer.stopPlantingBombAnimation()
                
                // sending to multipeer
                let bombCondition = MPBombModel(bomb: .cancelledPlanting, playerBombCondition: "terrorist-initial", winnerId: thisPlayer.id)
                mpManager.send(bomb: bombCondition)
                
                return "terrorist-initial"
            }
        }
        return ""
    }
    
    func successPlantingBomb(cameraNode: SKCameraNode, progressBar: ProgressBar, thisPlayer: PlayerModel, player2Model: PlayerModel, timer: TimerLabel, mpManager: MultipeerConnectionManager) -> String{
        
        if let bombPlantTimerStartTime = bombPlantTimerStartTime {
            let elapsedTime = Date().timeIntervalSince(bombPlantTimerStartTime)
            progressBar.updateProgressBar(elapsedTime: elapsedTime, totalTime: plantDuration)
            if elapsedTime >= plantDuration {
                print("Success planting bomb")
                
                self.isBombLoadingPlanting = true
                self.bombPlantTimerStartTime = nil
                
                //remove the progress bar
                progressBar.progressBarBackground?.isHidden = true
                progressBar.progressBar?.isHidden = true
                
                //remove planting animation
                thisPlayer.stopPlantingBombAnimation()
                
                //  sending location of the bomb to other player
                let bombCondition = MPBombModel(bomb: .planted, playerBombCondition: "terrorist-planted-bomb", winnerId: thisPlayer.id)
                mpManager.send(bomb: bombCondition)
                print("DEBUG: sending location of the bomb to other player")
                
                return "terrorist-planted-bomb"
            }
        }
        return ""
    }
    
    
    func addBombNode(player2Model: PlayerModel, timer: TimerLabel, cameraNode: SKCameraNode) -> SKSpriteNode{
        let bombNode = SKSpriteNode(imageNamed: "bomb")
        bombNode.size = CGSize(width: 20, height: 20)
        bombNode.position = player2Model.playerNode.position
        bombNode.zPosition = 5
        bombNode.name = "bomb"
//        addChild(bombNode)
        isBombNodeAdded = true
        plantButton.isHidden = true
        
        AudioManager.shared.playBombTimerSound()
        AudioManager.shared.playBombPlantedAlertMusic()
        
        timer.startTimer()
        timer.startTimerCover(cameraNode: cameraNode)
        
        return bombNode
    }
    
    
}
