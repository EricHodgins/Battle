//
//  HealthBoost.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-22.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class HealthBoost {
    var type: PowerupType = PowerupType.healthBoost
}

extension HealthBoost: Powerup {
    func activate(tank: Tank, pointFiredAt point: CGPoint, screenSize: CGSize) {
        tank.health = 100
        tank.removeDangerSmoke()
    }
}
