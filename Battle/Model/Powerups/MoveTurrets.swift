//
//  MoveTurrets.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-22.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class MoveTurrets {
    var type: PowerupType = PowerupType.moveTurrets
}

extension MoveTurrets: Powerup {
    func activate(tank: Tank, pointFiredAt point: CGPoint, screenSize: CGSize) {
        
    }
}
