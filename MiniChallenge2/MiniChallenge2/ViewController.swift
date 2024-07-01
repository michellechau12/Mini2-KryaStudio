//
//  ViewController.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 28/06/24.
//

import SwiftUI
import SpriteKit

struct SpriteView: UIViewRepresentable {
    var gameScene: GameScene

    class Coordinator: NSObject {
        var parent: SpriteView

        init(parent: SpriteView) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> SKView {
        let skView = SKView(frame: UIScreen.main.bounds)
        skView.isMultipleTouchEnabled = true
        
        // Present the scene
        skView.presentScene(gameScene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        // Update the view if needed
    }
}
