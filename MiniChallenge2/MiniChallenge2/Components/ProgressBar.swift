//
//  ProgressBar.swift
//  MiniChallenge2
//
//  Created by Ferris Leroy Winata on 20/06/24.
//

import SpriteKit

class ProgressBar: SKNode {
    private var progressBarBackground: SKSpriteNode
    private var progressBar: SKSpriteNode
    private let maxWidth: CGFloat
    
    init(size: CGSize, position: CGPoint) {
    
        progressBarBackground = SKSpriteNode(color: .gray, size: size)
        progressBarBackground.position = position
        progressBarBackground.zPosition = 5
        
 
        progressBar = SKSpriteNode(color: .green, size: CGSize(width: 0, height: size.height))
        progressBar.position = CGPoint(x: position.x - size.width / 2, y: position.y)
        progressBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        progressBar.zPosition = 6
        
        maxWidth = size.width
        
        super.init()
        
        addChild(progressBarBackground)
        addChild(progressBar)
        
        // Initially hidden
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        self.isHidden = false
        progressBar.size.width = 0
    }
    
    func updateProgress(elapsedTime: TimeInterval, duration: TimeInterval) {
        let progress = CGFloat(elapsedTime / duration)
        progressBar.size.width = maxWidth * progress
        
        if progress >= 1.0 {
            complete()
        }
    }
    
    func reset() {
        self.isHidden = true
        progressBar.size.width = 0
    }
    
    private func complete() {
        self.isHidden = true
        progressBar.size.width = 0
    }
}

