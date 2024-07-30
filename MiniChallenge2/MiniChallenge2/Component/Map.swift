//
//  Map.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 02/07/24.
//

import SpriteKit
import GameplayKit

class Map: SKScene{
    func setupMapPhysics(map: SKTileMapNode) {
        let tileMap = map // the tile map to be given physics body
        let tileSize = tileMap.tileSize // the size of each tile map
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width // half width of tile map
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height // half height of tile map
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    
                    let isEdgeTile = tileDefinition.userData?["AddBody"] as? Int
                    if isEdgeTile == 1 {
                        let tileArray = tileDefinition.textures //get the tile textures in array
                        let tileTexture = tileArray[0] //get the first texture
                        let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width/2)
                        let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height/2)
                        let tileNode = SKNode()
                        
                        tileNode.position = CGPoint(x: x, y: y)
                        tileNode.physicsBody = SKPhysicsBody(texture: tileTexture, size: tileTexture.size())
                        tileNode.physicsBody?.affectedByGravity = false
                        tileNode.physicsBody?.allowsRotation = false
                        tileNode.physicsBody?.restitution = 0
                        tileNode.physicsBody?.isDynamic = false
                        
                        //friction = semakin strict objectnya, sehingga lebih baik dibuat 0 saja
                        //tileNode.physicsBody?.friction = 20.0
                        
                        tileNode.physicsBody?.mass = 30.0
                        
                        tileNode.physicsBody?.categoryBitMask = BitMaskCategory.maze
                        tileNode.physicsBody?.collisionBitMask = BitMaskCategory.player1 | BitMaskCategory.player2
                        tileNode.physicsBody?.contactTestBitMask = BitMaskCategory.player1 | BitMaskCategory.player2
                        tileMap.addChild(tileNode)
                    }
                }
            }
        }
    }
}
