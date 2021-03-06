//
//  PowerupSprite.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-22.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class PowerupSprite: SKSpriteNode {
    var initialSize: CGSize = CGSize(width: 28, height: 24)
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Powerup")
    
    init(textureName: String) {
        let texture = textureAtlas.textureNamed(textureName)
        super.init(texture: texture, color: .clear, size: initialSize)
        
        self.physicsBody = SKPhysicsBody(texture: texture, size: self.size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.powerup.rawValue
        self.physicsBody?.affectedByGravity = false
        
        pulse()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func pulse() {
        let pulseInGroup = SKAction.group([
            SKAction.fadeAlpha(to: 0.6, duration: 1.0),
            SKAction.scale(to: 0.8, duration: 1.0)
            ])
        
        let pulseOutGroup = SKAction.group([
            SKAction.fadeAlpha(to: 1, duration: 1),
            SKAction.scale(to: 1, duration: 1)
            ])
        
        let pulseSequence = SKAction.sequence([
            pulseInGroup, pulseOutGroup
            ])
        
        let pulseAction = SKAction.repeatForever(pulseSequence)
        self.run(pulseAction)
    }
    
    public func addFlashTo(gameScene: GameScene, atPoint point: CGPoint) {
        guard let flash = SKEmitterNode(fileNamed: "PowerupHit") else { return }
        flash.position = point
        
        let delay = SKAction.wait(forDuration: 2)
        gameScene.run(delay) {
            flash.removeFromParent()
        }

        gameScene.addChild(flash)
    }
}
