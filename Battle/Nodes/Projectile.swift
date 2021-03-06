//
//  Projectile.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-08.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class Projectile: SKSpriteNode {
    var initialSize: CGSize = CGSize(width: 4, height: 11)
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Tank")
    public var velocity: Double = 200
    public var shooter: Shooter = .friendly
    
    init() {
        let tankTexture = textureAtlas.textureNamed("projectile")
        super.init(texture: tankTexture, color: .clear, size: initialSize)
        
        self.physicsBody = SKPhysicsBody(texture: tankTexture, size: self.size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.projectile.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.boundary.rawValue | PhysicsCategory.tank.rawValue | PhysicsCategory.turret.rawValue | PhysicsCategory.powerup.rawValue | PhysicsCategory.obstacle.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 0
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1
        self.name = "projectile"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("Projectile Deinit")
    }
    
}
