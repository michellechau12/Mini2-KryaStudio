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
        case collide
        case sabotagedView
        case plantBomb
        case defuseBomb // ->delay 2 second if cancelled by FBI
        case death
        case reset
        case end
//        case win
    }
    
    let action: Action
    let playerId: String
    let playerPosition: CGPoint
    let playerTextureName: String! //FBI (pegang tang, pegang borgol); Terrorist (bomb, nothing, pentungan)
    
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
        case unplanted
        case planted
        case defused
    }
    
    let bomb: BombEvent
    let position: CGPoint
//    let time: Timer //(?) -> cannot conform to codable -> berarti timernya countdown di masing" service ketika bomb change state dari unplanted jadi planted
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
