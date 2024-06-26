//
//  MultipeerModel.swift
//  MiniChallenge2
//
//  Created by Tania Cresentia on 12/06/24.
//

import Foundation
import SpriteKit

struct MPPlayerModel: Codable {
    enum Action: String, Codable {
        case start
        case move
        case sabotagedView
        case death
        case reset
        case end
//        case win
    }
    
    let action: Action
    let playerId: String
    let playerPosition: CGPoint
    let playerOrientation: String
    let isVulnerable: Bool
    let winnerId: String
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

struct MPMapModel: Codable {
    enum ActiveBombSite: String, Codable {
        case abc
        case bcd
        case cda
        case abd
    }
    
    let activeBombSite: ActiveBombSite
    let position: CGPoint
    let bombSiteTexttureName: String!
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

struct MPBombModel: Codable {
    enum BombEvent: String, Codable {
        case planting
        case cancelledPlanting
        case planted
        case approachedByPlayers
        case defusing
        case cancelledDefusing
        case defused
        case exploded
    }
    
    let bomb: BombEvent
    let playerBombCondition: String
    let winnerId: String
//    let time: Timer //(?) -> cannot conform to codable -> berarti timernya countdown di masing" service ketika bomb change state dari unplanted jadi planted
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
