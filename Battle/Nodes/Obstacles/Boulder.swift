//
//  Boulder.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-28.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class Boulder: ObstacleSprite {
    var initialSize: CGSize = CGSize(width: 70, height: 74)

    init() {
        super.init(size: initialSize, textureName: "boulder")
        self.name = "obstacle_boulder"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func hasBeenHit(contactPoint: CGPoint) {
        guard let explosion = SKEmitterNode(fileNamed: "TurretHit") else { return }
        let gamescene = self.parent as! GameScene
        explosion.position = gamescene.convert(contactPoint, to: self)
        explosion.zPosition = 10
        explosion.targetNode = self
        
        self.addChild(explosion)
        let delay = SKAction.wait(forDuration: 3.0)
        self.run(delay) {
            explosion.removeFromParent()
        }
    }
    
    deinit {
        print("Boulder deinit")
    }
}
