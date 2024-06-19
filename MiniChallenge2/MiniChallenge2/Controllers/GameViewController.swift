//
//  GameViewController.swift
//  MiniChallenge2
//
//  Created by Michelle Chau on 18/06/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let scene = GameScene(size: CGSize(width: 2388, height: 1668))
        let skView = self.view as! SKView
        let scene = SKScene(fileNamed: "MazeScene")
        
        scene?.scaleMode = .aspectFill
        skView.showsPhysics = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
        
        
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }
}
