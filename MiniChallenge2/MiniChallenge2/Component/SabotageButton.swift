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
    
    func sabotage(){
        
    }
    
}
