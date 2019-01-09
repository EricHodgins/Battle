//
//  Turret.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-09.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class Turret: SKSpriteNode {
    
    var initialSize: CGSize = CGSize(width: 28, height: 24)
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Turret")
    
    public var wasHit: Observable<Target> = Observable(Target(shooter: .friendly, wasHit: false))
    
    init() {
        let turretTexture = textureAtlas.textureNamed("turret")
        super.init(texture: turretTexture, color: .clear, size: initialSize)
        
        self.physicsBody = SKPhysicsBody(texture: turretTexture, size: self.size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.turret.rawValue
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 10
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.allowsRotation = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
