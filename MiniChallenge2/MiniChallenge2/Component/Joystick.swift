//
//  Joystick.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class Joystick: SKScene{
    
    var joystickBase: SKSpriteNode?
    var joystickKnob: SKSpriteNode?
    var joystickTouchArea: SKShapeNode?
    
    func createJoystick() {
        //Otak-atik posisi Joystick
        let joystickBase = SKSpriteNode(imageNamed: "joystickBase6")
        joystickBase.position = CGPoint(x: -430, y: -230)
        joystickBase.setScale(2.5)
        joystickBase.alpha = 0.15
        joystickBase.zPosition = 80
        joystickBase.name = "joystickBase5"
        
        let joystickKnob = SKSpriteNode(imageNamed: "joystickKnob3")
        joystickKnob.position = CGPoint(x: -430, y: -230)
        joystickKnob.setScale(2.0)
        joystickBase.alpha = 2.0
        joystickKnob.zPosition = 88
        joystickKnob.name = "joystickKnob3"
        
        self.joystickBase = joystickBase
        self.joystickKnob = joystickKnob
        
        let joystickTouchArea = SKShapeNode (circleOfRadius: 400)
        joystickTouchArea.position = joystickBase.position
        joystickTouchArea.zPosition = 19
        joystickTouchArea.strokeColor = .clear
        joystickTouchArea.fillColor = .clear
        joystickTouchArea.name = "joystickTouchArea"
        
        self.joystickTouchArea = joystickTouchArea
    }
}
