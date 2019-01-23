//
//  PowerupTripleBullet.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-14.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class PowerupTripleBullet: PowerupSprite {
    
    init() {
        super.init(textureName: "triple_bullet")
        self.name = PowerupType.tripleBullet.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("Powerup Deinit: Triple Bullet")
    }
}
