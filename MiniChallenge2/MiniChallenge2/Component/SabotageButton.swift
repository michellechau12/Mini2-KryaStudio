//
//  SabotageButton.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class SabotageButton: SKScene{
    
    var sabotageButton: SKSpriteNode?
    var isSabotageButtonEnabled = true
    var sabotageButtonPressCount = 0
    var sabotageOneTimeTapfunction = false
    
    func setupSabotageButton() {
        let sabotageButton = SKSpriteNode(imageNamed: "sabotageButton")
        sabotageButton.position = CGPoint(x: 450, y: -280 )
//        sabotageButton.position = CGPoint(x: 350, y: -280 )
        sabotageButton.size = CGSize(width: 180, height: 180)
        sabotageButton.alpha = 1.2
        sabotageButton.zPosition = 25
        sabotageButton.name = "sabotageButton"
        
        self.sabotageButton = sabotageButton
    }
    
    
    func removeSabotageButtonAfterUse(){
        sabotageButtonPressCount += 1

        if sabotageButtonPressCount == 2 {
            sabotageButton?.removeFromParent()
//            sabotageButton = nil
        }
    }
    
    
    func sabotage(cameraNode: SKCameraNode?, location: CGPoint, thisPlayer: PlayerModel, mpManager: MultipeerConnectionManager){
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
                animateSabotageCooldownTimer(cameraNode: cameraNode)
                //function to remove sabotage button after 2x tap
                removeSabotageButtonAfterUse()
                
            }
            else if sabotageButton.contains(convertedLocation) && !isSabotageButtonEnabled{
                print("Button in cooldown")
            }
        }
    }
    
    
    func animateSabotageCooldownTimer(cameraNode: SKCameraNode?) {
        
        if !sabotageOneTimeTapfunction {
            sabotageOneTimeTapfunction = true
            
            let path = UIBezierPath(arcCenter: CGPoint.zero, radius: 68, startAngle: 0, endAngle:.pi * 2, clockwise: true)
            let shapeNode = SKShapeNode(path: path.cgPath)
            shapeNode.fillColor = .clear
            shapeNode.strokeColor = .gray
            shapeNode.lineWidth = 11
            shapeNode.position = CGPoint(x: 448, y: -259)
            shapeNode.zPosition = 10
            cameraNode?.addChild(shapeNode)
            
            //Dalam function ini, ketika dijalankan, otomatis membuat alpha dari sabotageButton menjadi 0.2
            sabotageButton?.alpha = 0.45
            
            let animation = SKAction.customAction(withDuration: 20.0) { node, elapsedTime in
                let percentage = elapsedTime / 20.0
                shapeNode.path = UIBezierPath(arcCenter: CGPoint.zero, radius: 68, startAngle: 0, endAngle:.pi * 2 * (1 - percentage), clockwise: true).cgPath
            }
            shapeNode.run(animation) {
                shapeNode.removeFromParent()
                self.isSabotageButtonEnabled = true
                self.sabotageButton?.alpha = 1
            }
        }
    }
    
}
