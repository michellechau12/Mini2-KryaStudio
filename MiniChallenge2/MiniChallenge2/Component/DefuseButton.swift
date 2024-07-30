//
//  DefuseButton.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class DefuseButton: SKScene{
    
    var defuseButton = SKSpriteNode(imageNamed: "defuseButton")
    var isDefuseButtonEnabled = false
    
    var defuseTimerStartTime: Date?
    var defuseCooldownStartTime: Date?
    var defuseDuration = 4.0
    var defuseCooldownDuration = 2.0
    
    // fbi is ...
    var isDefusing: Bool = false
    var isDelayingMove: Bool = false
    
    var isBombDefused: Bool = false
    
    // for joystick to stop moving when button pressed
    var isDefuseButtonPressed = false
    
    func setupDefuseButton(){
            defuseButton.position = CGPoint(x: 450, y: -110 )
            defuseButton.size = CGSize(width: 130, height: 130)
            defuseButton.alpha = 0.2
            defuseButton.zPosition = 25
            defuseButton.name = "defuseButton"
    }
    
    func startDefusing(cameraNode: SKCameraNode?, location: CGPoint, thisPlayer: PlayerModel, progressBar: ProgressBar, mpManager: MultipeerConnectionManager) -> String{
        if let camera = cameraNode {
            let convertedLocation = camera.convert(location, from: self)
            if defuseButton.contains(convertedLocation) && isDefuseButtonEnabled && thisPlayer.orientation == "not-moving"{
                defuseTimerStartTime = Date()
                print("lagi defuse...")
                
                // show progress bar
                progressBar.progressBarBackground?.isHidden = false
                progressBar.progressBar?.isHidden = false
                
                self.isDefusing = true
                
                //run defuse animation
                thisPlayer.updatePlayerTextures(condition: "fbi-defusing-bomb")
                thisPlayer.animateDefusingBomb()
                
                // sending to multipeer
                let bombCondition = MPBombModel(bomb: .defusing, playerBombCondition: "fbi-defusing-bomb", winnerId: thisPlayer.id)
                mpManager.send(bomb: bombCondition)
                
                isDefuseButtonPressed = true
                
                return "fbi-defusing-bomb"
            }
        }
        return ""
    }
    
    func stopDefusing(progressBar: ProgressBar, thisPlayer: PlayerModel, mpManager: MultipeerConnectionManager) -> String{
        if let defuseTimerStartTime = defuseTimerStartTime {
            let elapsedTime = Date().timeIntervalSince(defuseTimerStartTime)
            if elapsedTime < defuseDuration {
                print("cancel defusing")
                self.defuseTimerStartTime = nil
                
                // remove progress bar
                progressBar.progressBarBackground?.isHidden = true
                progressBar.progressBar?.isHidden = true
                
                // change fbi condition from fbi-defusing-bomb to fbi-cancel-defusing
                isDefusing = false
                
                // run cancel defuse animation:
                thisPlayer.cancelDefuseAnimation() // there's delay after cancelling defuse animation
                
                // remove defusing animation
                thisPlayer.stopDefusingBombAnimation()
                
                // sending to multipeer
                let bombCondition = MPBombModel(bomb: .cancelledDefusing, playerBombCondition: "fbi-cancel-defusing", winnerId: thisPlayer.id)
                mpManager.send(bomb: bombCondition)
                
                // Start delay timer:
                defuseCooldownStartTime = Date()
                isDelayingMove = true
                
                return "fbi-cancel-defusing"
            }
        }
        return ""
    }
    
    func successDefusingBomb(progressBar: ProgressBar, thisPlayer: PlayerModel, player1Model: PlayerModel, timerLabel: TimerLabel){
        if let defuseTimerStartTime = defuseTimerStartTime {
            let elapsedTime = Date().timeIntervalSince(defuseTimerStartTime)
            progressBar.updateProgressBar(elapsedTime: elapsedTime, totalTime: defuseDuration)
            if elapsedTime >= defuseDuration {
                print("Success defusing bomb")
                
                isBombDefused = true
                self.defuseTimerStartTime = nil
                
                //remove the progress bar
                progressBar.progressBarBackground?.isHidden = true
                progressBar.progressBar?.isHidden = true
                
                //remove defusing animation
                thisPlayer.playerNode.removeAction(forKey: "defusingAnimation")
                timerLabel.timer?.invalidate()
                
                
            }
        }
    }
    
    func defuseBombNode(timerLabel: TimerLabel){
        
        self.defuseButton.isHidden = true
        timerLabel.timerLabel?.isHidden = true
        
    }
    
    func cancelDefuseDelay(thisPlayer: PlayerModel, player1Model: PlayerModel, player2Model: PlayerModel){
        
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
        }
    }
    
}
