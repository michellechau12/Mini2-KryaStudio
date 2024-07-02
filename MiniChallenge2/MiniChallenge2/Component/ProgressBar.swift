//
//  ProgressBar.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class ProgressBar: SKScene{
    var progressBarBackground: SKSpriteNode?
    var progressBar: SKSpriteNode?
    
    func setupProgressBar() {
        progressBarBackground = SKSpriteNode(color: .gray, size: CGSize(width: 100, height: 15))
        progressBarBackground?.zPosition = 30
        progressBarBackground?.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressBarBackground?.position = CGPoint(x: -52, y: 245)
        progressBarBackground?.isHidden = true
        
        progressBar = SKSpriteNode(color: .green, size: CGSize(width: 0, height: 15))
        progressBar?.anchorPoint = CGPoint(x: 0, y: 0.5) //to make it grow from left to right
        progressBar?.position = CGPoint(x: -52, y: 245)
        progressBar?.zPosition = 31
        progressBar?.isHidden = true
    }
}
