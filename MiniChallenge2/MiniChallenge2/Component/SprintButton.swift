//
//  SprintButton.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class SprintButton: SKScene{
    var sprintButton = SKSpriteNode(imageNamed: "sprint-button")
    
    func setupSprintButton() {
            sprintButton.position = CGPoint(x: 300, y: -220 )
            sprintButton.size = CGSize(width: 130, height: 130)
            sprintButton.alpha = 1.2
            sprintButton.zPosition = 25
            sprintButton.name = "plantButton"
            
        }
}
