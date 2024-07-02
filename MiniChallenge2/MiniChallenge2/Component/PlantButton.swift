//
//  PlantButton.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class PlantButton: SKScene{
    var plantButton = SKSpriteNode(imageNamed: "plantButton")
    
    func setupPlantButton(){
            plantButton.position = CGPoint(x: 450, y: -110 )
            plantButton.size = CGSize(width: 130, height: 130)
            plantButton.alpha = 0.2
            plantButton.zPosition = 25
            plantButton.name = "plantButton"
    }
}
