//
//  PowerupHealthBoost.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-22.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class PowerupHealthBoost: PowerupSprite {
    
    init() {
        super.init(textureName: "health_boost")
        self.name = PowerupType.healthBoost.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("Powerup Deinit: Health Boost")
    }
}
