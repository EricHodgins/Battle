//
//  WoodStack.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-30.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class WoodStack: ObstacleSprite {
    var initialSize: CGSize = CGSize(width: 70, height: 74)
    
    init() {
        super.init(size: initialSize, textureName: "wood_stack")
        self.name = "obstacle_woodstack"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("WoodStack deinit")
    }
}

