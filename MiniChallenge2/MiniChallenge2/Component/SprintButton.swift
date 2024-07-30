//
//  SprintButton.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class SprintButton: SKScene{
    var sprintButton = SKSpriteNode(imageNamed: "sprint-button")
    var isSprintButtonEnabled: Bool = true
    var sprintButtonPressCount = 0
    var sprintOneTimeTapfunction = false
    
    var extraSpeed = 2.0 // for sprint
    var sprintStartTime: Date?
    var sprintDuration = 5.0
    
    func setupSprintButton() {
            sprintButton.position = CGPoint(x: 300, y: -220 )
            sprintButton.size = CGSize(width: 130, height: 130)
            sprintButton.alpha = 1.2
            sprintButton.zPosition = 25
            sprintButton.name = "plantButton"
            
        }
    
    func startSprint(cameraNode: SKCameraNode?, location: CGPoint, thisPlayer: PlayerModel){
        if let camera = cameraNode{
            let convertedLocation = camera.convert(location, from: self)
            if sprintButton.contains(convertedLocation) && isSprintButtonEnabled {
                sprintStartTime = Date()
                
                // Button Cooldown
                isSprintButtonEnabled = false
                //Function cooldownTimer
//                setupSprintCondition()
                setupStartSprintLabel(cameraNode: cameraNode)
                animateSprintCooldownTimer(cameraNode: cameraNode)
                setNumberOfSprintAllowed()
                
                // adding speed multiplier
                thisPlayer.speedMultiplier += self.extraSpeed

                
            } else if sprintButton.contains(convertedLocation) && !isSprintButtonEnabled {
                print("Button in cooldown")
            }
        }
    }
    
    
    func animateSprintCooldownTimer(cameraNode: SKCameraNode?) {
        
        if !sprintOneTimeTapfunction {
            sprintOneTimeTapfunction = true
            
            let path = UIBezierPath(arcCenter: CGPoint.zero, radius: 52.3, startAngle: 0, endAngle:.pi * 2, clockwise: true)
            let shapeNode = SKShapeNode(path: path.cgPath)
            shapeNode.fillColor = .clear
            shapeNode.strokeColor = .gray
            shapeNode.lineWidth = 9
            shapeNode.position = CGPoint(x: 300, y: -216 )
            shapeNode.zPosition = 10
            cameraNode?.addChild(shapeNode)
            
            //Dalam function ini, ketika dijalankan, otomatis membuat alpha dari sprintButton menjadi 0.2
            sprintButton.alpha = 0.3
            
            let animation = SKAction.customAction(withDuration: 20.0) { node, elapsedTime in
                let percentage = elapsedTime / 20.0
                shapeNode.path = UIBezierPath(arcCenter: CGPoint.zero, radius: 52, startAngle: 0, endAngle:.pi * 2 * (1 - percentage), clockwise: true).cgPath
            }
            shapeNode.run(animation) {
                shapeNode.removeFromParent()
                self.isSprintButtonEnabled = true
                self.sprintButton.alpha = 1
            }
        }
    }
    
    func stopSprintCondition(thisPlayer: PlayerModel){
        print("DEBUG: initial speed \(thisPlayer.speedMultiplier)")
        if let sprintStartTime = sprintStartTime {
            let sprintElapsedTime = Date().timeIntervalSince(sprintStartTime)
            if sprintElapsedTime > sprintDuration {
                print("DEBUG: elapsed time more than sprint duration")
                thisPlayer.speedMultiplier -= self.extraSpeed
                self.sprintStartTime = nil
            }
            print("DEBUG: sprint speed \(thisPlayer.speedMultiplier)")
        }

    }
    
    func setupStartSprintLabel(cameraNode: SKCameraNode?){
        
        _ = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) { [weak self] timer in
               self?.isSprintButtonEnabled = true
        
           }
        
        let sprintLabel = SKLabelNode(fontNamed: "Palatino-Bold")
            sprintLabel.text = "Your speed will be greatly increased for 5 seconds!"
            sprintLabel.fontSize = 27
            sprintLabel.color = .black
            sprintLabel.position = CGPoint(x: 0, y: -102)
            sprintLabel.zPosition = 40
            cameraNode?.addChild(sprintLabel)

            print("Children: \(self.children)")
            
            // Fade in
            sprintLabel.alpha = 0
            let fadeInAction = SKAction.fadeIn(withDuration: 2)
            sprintLabel.run(fadeInAction)
        
        let sprintLabelDuration = SKAction.wait(forDuration: 5.0)
            let removeLabel3 = SKAction.run {
                sprintLabel.removeFromParent()
            }
            let sequenceAction3 = SKAction.sequence([sprintLabelDuration, removeLabel3])
            run(sequenceAction3)
    }
    
    
    func setNumberOfSprintAllowed(){
        sprintButtonPressCount += 1

        if sprintButtonPressCount == 2 {
            sprintButton.removeFromParent()
        }
    }
    
}
