//
//  Boulder.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-28.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class Boulder: SKSpriteNode {
    var initialSize: CGSize = CGSize(width: 70, height: 74)
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Obstacles")
    
    init() {
        let texture = textureAtlas.textureNamed("boulder")
        super.init(texture: texture, color: .clear, size: initialSize)
        
        self.physicsBody = SKPhysicsBody(texture: texture, size: initialSize)
        self.physicsBody?.categoryBitMask = PhysicsCategory.obstacle.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = PhysicsCategory.tank.rawValue | PhysicsCategory.boundary.rawValue
        self.physicsBody?.affectedByGravity = false
        self.name = "boulder"
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
