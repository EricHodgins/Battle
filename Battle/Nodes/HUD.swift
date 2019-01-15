//
//  HUD.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-14.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class HUD: SKSpriteNode {
    var textureAtlas = SKTextureAtlas(named: "HUD")
    let initialSize = CGSize(width: 200, height: 60)
    var backgroundHealthNode: SKShapeNode!
    var healthNode: SKShapeNode!
    let percentText = SKLabelNode(fontNamed: "Arial Rounded MT Bold")
    
    init() {
        let backgroundTexture = textureAtlas.textureNamed("background")
        super.init(texture: backgroundTexture, color: .clear, size: initialSize)
        anchorPoint = CGPoint(x: 0, y: 1)
        zPosition = 5
        setupHudNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupHudNodes() {
        let healthRect = CGRect(x: 10, y: -30 - 3, width: 180, height: 6)
        backgroundHealthNode = SKShapeNode(rect: healthRect, cornerRadius: 8)
        backgroundHealthNode.fillColor = UIColor(displayP3Red: 151/255.0, green: 198/255.0, blue: 250/255.0, alpha: 1.0)
        backgroundHealthNode.zPosition = 10
        
        healthNode = SKShapeNode(rect: healthRect, cornerRadius: 8)
        healthNode.fillColor = UIColor(displayP3Red: 98/255.0, green: 168/255.0, blue: 246/255.0, alpha: 1.0)
        healthNode.zPosition = 20
        
        percentText.text = "100 %"
        percentText.fontSize = 12
        percentText.position = CGPoint(x: 30, y: -20)
        
        self.addChild(backgroundHealthNode)
        self.addChild(healthNode)
        self.addChild(percentText)
    }
    
}
