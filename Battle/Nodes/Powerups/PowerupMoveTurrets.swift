//
//  PowerupMoveTurrets.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-22.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class PowerupMoveTurrets: PowerupSprite {
    
    init() {
        super.init(textureName: "move_turrets")
        self.name = PowerupType.moveTurrets.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("Powerup Deinit: Move Turrets")
    }
}
