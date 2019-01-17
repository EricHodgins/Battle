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
    var backgroundHealthNode: SKSpriteNode!
    var healthNode: SKSpriteNode!
    var healthNodeDanger: SKSpriteNode!
    let percentText = SKLabelNode(fontNamed: "Arial Rounded MT Bold")
    
    let player: Tank!
    let dangerLevel: Int = 25
    
    init(playerTank: Tank) {
        let healthIndicatorSize = CGSize(width: 183, height: 9)
        let dangerLevelSize = CGSize(width: healthIndicatorSize.width * (CGFloat(dangerLevel) / 100), height: 9)
        let backgroundHealthTexture = textureAtlas.textureNamed("background_health_indicator")
        let healthTexture = textureAtlas.textureNamed("health_level")
        let dangerTexture = textureAtlas.textureNamed("health_level_danger")
        
        backgroundHealthNode = SKSpriteNode(texture: backgroundHealthTexture, color: .clear, size: healthIndicatorSize)
        healthNode = SKSpriteNode(texture: healthTexture, color: .clear, size: healthIndicatorSize)
        healthNodeDanger = SKSpriteNode(texture: dangerTexture, color: .clear, size: dangerLevelSize)
        
        self.player = playerTank
        
        let backgroundTexture = textureAtlas.textureNamed("background")
        super.init(texture: backgroundTexture, color: .clear, size: initialSize)
        anchorPoint = CGPoint(x: 0, y: 1)
        zPosition = 5
        setupHudNodes()
        setupPlayerObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        player = nil
        super.init(coder: aDecoder)
    }
    
    private func setupPlayerObserver() {
        player.wasHit.addObserver(self, removeIfExists: true, options: [.new]) { [unowned self] tankHit, _ in
            self.tankHit(health: tankHit.health)
        }
    }
    
    func setupHudNodes() {
        let offsetPt = CGPoint(x: 8, y: -30 - 3)
        backgroundHealthNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        backgroundHealthNode.position = offsetPt
        backgroundHealthNode.zPosition = 10
        
        healthNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthNode.position = offsetPt
        healthNode.zPosition = 20
        
        healthNodeDanger.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthNodeDanger.position = offsetPt
        healthNodeDanger.zPosition = 20
        
        percentText.text = "100 %"
        percentText.fontSize = 12
        percentText.position = CGPoint(x: 30, y: -20)
        
        self.addChild(backgroundHealthNode)
        self.addChild(healthNode)
        self.addChild(percentText)
        
    }
    
    private func tankHit(health: Int) {
        guard health > 0 else {
            print("GAME OVER")
            let gameScene = self.parent as! GameScene
            gameScene.goToMenuScene()
            return
        }
        
        if health <= dangerLevel {
            healthNode.removeFromParent()
            self.addChild(healthNodeDanger)
        }

        let to: CGFloat = CGFloat(health) / 100
        let scaleX = SKAction.scaleX(to: to, duration: 1.5)
        healthNode.run(scaleX)
        percentText.text = "\(health) %"
    }
    
    deinit {
        print("HUD Deinit")
    }
    
}
