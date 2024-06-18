//
//  GameSceneMaze.swift
//  MiniChallenge2
//
//  Created by Michelle Chau on 18/06/24.
//

import SpriteKit
import GameplayKit

class GameSceneMaze: SKScene {
    
    private var bombSites: [BombSiteModel] = []
    private let playerCatNode = SKSpriteNode(imageNamed: "player_cat")
    private let plantButton = SKSpriteNode(imageNamed: "plant_button")
    private var isBombPlanted = false
    
    override func didMove(to view: SKView) {
        setupPhysics()
        setupBombSites()
        setupPlayer()
        setupPlantButton()
    }
    
    func setupPhysics() {
        //contact delegate:
        
        //fbi node physics body:
        
        //terrorist node physics body:
        
        //map physics body:
        let map = childNode(withName: "Maze") as! SKTileMapNode
        
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
                        tileNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (tileTexture.size().width), height: tileTexture.size().height))
                        tileNode.physicsBody?.affectedByGravity = false
                        tileNode.physicsBody?.allowsRotation = false
                        tileNode.physicsBody?.restitution = 0
                        tileNode.physicsBody?.isDynamic = false
                        tileNode.physicsBody?.friction = 20.0
                        tileNode.physicsBody?.mass = 30.0
                        tileNode.physicsBody?.contactTestBitMask = 0
                        //                        tileNode.physicsBody?.fieldBitMask = 0
                        //                        tileNode.physicsBody?.collisionBitMask = 0
                        
                        tileMap.addChild(tileNode)
                    }
                }
            }
        }
    }
    
    // Setup bombsite
    func setupBombSites() {
        for child in self.children {
            if child.name == "BombSite" { //Di setup di MazeScene
                if let child = child as? SKSpriteNode {
                    let bombSitePosition = child.position
                    let bombSiteSize = child.size
                    let bombSite = BombSiteModel(
                        position: bombSitePosition,
                        size: bombSiteSize)
                    bombSites.append(bombSite)
                    
                    //Debugging print:
                    print("bombsite position is: \(bombSitePosition) and size is: \(bombSiteSize)")
                }
            }
        }
    }
    
    // Setup player
    func setupPlayer() {
        playerCatNode.size = CGSize(width: 50, height: 50)
        playerCatNode.position = CGPoint(x: -160, y: size.height-550)
        playerCatNode.zPosition = 1
        
        playerCatNode.physicsBody = SKPhysicsBody(rectangleOf: playerCatNode.size)
        playerCatNode.physicsBody?.isDynamic = true
        
        addChild(playerCatNode)
        
        // Debugging print:
        print("Player initial position: \(playerCatNode.position)")
    }
    
    //Setup plant button
    func setupPlantButton() {
        plantButton.size = CGSize(width: 150, height: 150)
        plantButton.zPosition = 2
        plantButton.alpha = 0.7
        addChild(plantButton)
        plantButton.isHidden = true
    }
    
    //Check if player enters the bombsite area
    func isPlayerInBombSite() -> Bool {
        for bombSite in bombSites {
            let bombSiteRect = CGRect(
                origin: CGPoint(
                    x: bombSite.position.x - bombSite.size.width/2,
                    y: bombSite.position.y - bombSite.size.height/2),
                size: bombSite.size)
            
            if bombSiteRect.contains(playerCatNode.position){
                // Debugging print:
                print("Player is in bomb site: \(playerCatNode.position)")
                return true
            }
        }
        return false
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        //If player enters bomsite, the plant button will appear
        if isPlayerInBombSite() && !isBombPlanted {
            let offset: CGFloat = 20.0
            plantButton.position = CGPoint(
                x: playerCatNode.position.x,
                y: playerCatNode.position.y + playerCatNode.size.height / 2 + plantButton.size.height / 2 + offset)
            plantButton.isHidden = false
            
            // Debugging print:
            print("Plant button is visible")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        if plantButton.contains(location) && !plantButton.isHidden && !isBombPlanted {
            let bombNode = SKSpriteNode(imageNamed: "bomb-on")
            bombNode.size = CGSize(width: 50, height: 50)
            bombNode.position = playerCatNode.position
            bombNode.zPosition = 3
            bombNode.name = "bomb"
            addChild(bombNode)
            
            isBombPlanted = true //Set to true so that player cant place multiple bombs
            plantButton.isHidden = true // Hide plant button after planting
            
            // Debugging print:
            print("Bomb planted at position: \(bombNode.position)")
        }
    }
    
}
