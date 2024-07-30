//
//  TimerLabel.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class TimerLabel: SKScene{
    var timerLabel: SKLabelNode?
    
    var timer: Timer?
    var timeLeft = 0 // setted at the function
    var timerCover = SKSpriteNode(imageNamed: "timerCover")
    
    var isTimeEnded = false
    
    func setUpTimerLabel(){
        let timerLabel = SKLabelNode(fontNamed: "Palatino-Bold")
        timerLabel.fontSize = 40
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: -6, y: 307)
        timerLabel.zPosition = 100
        
        self.timerLabel = timerLabel
        self.timerLabel?.text = ""
        self.timerLabel?.isHidden = false
    }
    
    func startTimer() {
        timeLeft = 60
        timerLabel?.text = "\(timeLeft)"
        timerLabel?.isHidden = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.timeLeft -= 1
            self.timerLabel?.text = "\(self.timeLeft)"
            
            if self.timeLeft <= 0 {
                timer.invalidate()
                self.timerLabel?.isHidden = true
                self.timerCover.isHidden = true
                
                if let bombNode = self.childNode(withName: "bomb"){
                    bombNode.removeFromParent()
                }
//                gameOverByExplodingBomb()
                isTimeEnded = true
                //Logic untuk pindah scene misalnya (Kalah atau poin Terrorist bertambah nanti jika tidak didefuse)
                
            }
        }
    }
    
    func startTimerCover(cameraNode: SKCameraNode?) {
        
        timerCover.position = CGPoint(x: -6, y: 320)
        timerCover.setScale(0.1)
        timerCover.alpha = 0.8
        timerCover.zPosition = 12
        timerCover.name = "timerCover"
        cameraNode?.addChild(timerCover)
        
        timerCover.isHidden = false
        
    }
}
