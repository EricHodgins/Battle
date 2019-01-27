//
//  Background.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-21.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class Background: SKSpriteNode {
    let textureAtlas = SKTextureAtlas(named: "Background")
    let backgroundSize = CGSize(width: 1024, height: 768)
    var currentPositionY: CGFloat = 0
    
    public func spawn(parentNode: SKNode, imageName: String) {
        self.anchorPoint = CGPoint.zero
        self.position = CGPoint(x: 0, y: 0)
        self.zPosition = -1
        
        parentNode.addChild(self)
        
        let texture = textureAtlas.textureNamed(imageName)
        for i in -1...1 {
            let bgNode = SKSpriteNode(texture: texture)
            bgNode.size = backgroundSize
            bgNode.anchorPoint = CGPoint.zero
            bgNode.position = CGPoint(x: 0, y: i * Int(backgroundSize.height))
            self.addChild(bgNode)
        }
    
    }
    
    public func updateBackground(playerPositionY: CGFloat) {
        let deltaY = playerPositionY - currentPositionY
        if deltaY > backgroundSize.height {
            currentPositionY = playerPositionY
            self.position.y = currentPositionY
        }
    }
}
