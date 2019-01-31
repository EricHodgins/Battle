//
//  ObstacleSprite.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-30.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class ObstacleSprite: SKSpriteNode {
    
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Obstacles")
    
    init(size: CGSize, textureName: String) {
        let texture = textureAtlas.textureNamed(textureName)
        super.init(texture: texture, color: .clear, size: size)
        
        self.physicsBody = SKPhysicsBody(texture: texture, size: size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.obstacle.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = PhysicsCategory.tank.rawValue | PhysicsCategory.boundary.rawValue
        self.physicsBody?.affectedByGravity = false
        self.name = "obstacle"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
