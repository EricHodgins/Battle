//
//  Tank.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-08.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class Tank: SKSpriteNode {
    var initialSize: CGSize = CGSize(width: 66, height: 45)
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Tank")
    
    var direction: Direction = .idle
    public let movingSpeed: Double = 60
    
    init() {
        let tankTexture = textureAtlas.textureNamed("friendly")
        super.init(texture: tankTexture, color: .clear, size: initialSize)
        
        self.physicsBody = SKPhysicsBody(texture: tankTexture, size: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 10000000
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.allowsRotation = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func update(_ currentTime: TimeInterval, timeDelta: TimeInterval) {
        if direction != .idle {
            moveTank(timeDelta: timeDelta)
        }
    }
    
    private func moveTank(timeDelta: TimeInterval) {
        let distanceToTravel: CGFloat = CGFloat(timeDelta * self.movingSpeed)
        
        if direction == .right {
            self.position.x += distanceToTravel
        } else {
            self.position.x -= distanceToTravel
        }
    }
}
