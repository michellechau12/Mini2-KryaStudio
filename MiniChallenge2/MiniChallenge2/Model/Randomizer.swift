//
//  Randomizer.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 17/06/24.
//

import Foundation

class Randomizer {
    static func randomizeRole() -> String {
        let roles = ["fbi", "terrorist"]
        return roles.randomElement()!
    }
}
