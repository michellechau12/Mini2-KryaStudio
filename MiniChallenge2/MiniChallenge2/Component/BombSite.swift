//
//  BombSite.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit

class BombSite: SKScene{
    
    var bombSites: [BombSiteModel] = []
    
    func setupBombSites(child: SKSpriteNode) {
//        for child in self.children {
//            if child.name == "BombSite" { //Di setup di MazeScene
//                if let child = child as? SKSpriteNode {
                    let bombSitePosition = child.position
                    let bombSiteSize = child.size
                    let bombSite = BombSiteModel(
                        position: bombSitePosition,
                        size: bombSiteSize)
                    bombSites.append(bombSite)
                    
                    //Debugging print:
                    print("bombsite position is: \(bombSitePosition) and size is: \(bombSiteSize)")
//                }
//            }
//        }
    }
    
}
