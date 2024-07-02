//
//  TimerLabel.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class TimerLabel: SKScene{
    var timerLabel: SKLabelNode?
    
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
}
