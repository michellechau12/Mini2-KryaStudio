//
//  DefuseButton.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class DefuseButton: SKScene{
    var defuseButton = SKSpriteNode(imageNamed: "defuseButton")
    
    func setupDefuseButton(){
            defuseButton.position = CGPoint(x: 450, y: -110 )
            defuseButton.size = CGSize(width: 130, height: 130)
            defuseButton.alpha = 0.2
            defuseButton.zPosition = 25
            defuseButton.name = "defuseButton"
        }
}
