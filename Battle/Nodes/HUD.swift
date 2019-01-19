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
    
    private var friendlyTurnIndicatorNode: SKSpriteNode!
    private var enemyTurnIndicatorNode: SKSpriteNode!
    
    var player: Tank!
    var enemyTank: Tank!
    let dangerLevel: Int = 25
    
    init(playerTank: Tank, enemyTank: Tank) {
        let friendlyTurnTexture = textureAtlas.textureNamed("friendlys_turn")
        let enemiesTurnTexture = textureAtlas.textureNamed("enemies_turn")
        
        let turnIndicatorSize = CGSize(width: 12, height: 12)
        let healthIndicatorSize = CGSize(width: 183, height: 9)
        let backgroundHealthTexture = textureAtlas.textureNamed("background_health_indicator")
        let healthTexture = textureAtlas.textureNamed("health_level")
        let dangerTexture = textureAtlas.textureNamed("health_level_danger")
        
        friendlyTurnIndicatorNode = SKSpriteNode(texture: friendlyTurnTexture, color: .clear, size: turnIndicatorSize)
        enemyTurnIndicatorNode = SKSpriteNode(texture: enemiesTurnTexture, color: .clear, size: turnIndicatorSize)
        backgroundHealthNode = SKSpriteNode(texture: backgroundHealthTexture, color: .clear, size: healthIndicatorSize)
        healthNode = SKSpriteNode(texture: healthTexture, color: .clear, size: healthIndicatorSize)
        healthNodeDanger = SKSpriteNode(texture: dangerTexture, color: .clear, size: healthIndicatorSize)
        
        self.player = playerTank
        self.enemyTank = enemyTank
        
        let backgroundTexture = textureAtlas.textureNamed("background")
        super.init(texture: backgroundTexture, color: .clear, size: initialSize)
        anchorPoint = CGPoint(x: 0, y: 1)
        zPosition = 5
        setupHudNodes()
        setupPlayerObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupPlayerObserver() {
        player.wasHit.addObserver(self, removeIfExists: true, options: [.new]) { [unowned self] tankHit, _ in
            self.tankHit(health: tankHit.health)
        }
    }
    
    private func setupEnemyObserver() {
        enemyTank.wasHit.addObserver(self, removeIfExists: true, options: [.new]) { [unowned self] tankHit, _ in
            self.enemyHit(health: tankHit.health)
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
        healthNodeDanger.alpha = 0.0
        
        percentText.text = "100 %"
        percentText.fontSize = 12
        percentText.position = CGPoint(x: 30, y: -20)
        
        let turnIndicatorPosition = CGPoint(x: 150, y: -15)
        friendlyTurnIndicatorNode.position = turnIndicatorPosition
        friendlyTurnIndicatorNode.alpha = 1.0
        enemyTurnIndicatorNode.position = turnIndicatorPosition
        enemyTurnIndicatorNode.alpha = 0.0
        
        self.addChild(backgroundHealthNode)
        self.addChild(healthNode)
        self.addChild(healthNodeDanger)
        self.addChild(percentText)
        self.addChild(friendlyTurnIndicatorNode)
        self.addChild(enemyTurnIndicatorNode)
        
    }
    
    public func updateWhoIsShooterIndicator(tank: Tank) {
        if tank.name == "friendly" {
            friendlyTurnIndicatorNode.alpha = 1.0
            enemyTurnIndicatorNode.alpha = 0.0
        } else {
            enemyTurnIndicatorNode.alpha = 1.0
            friendlyTurnIndicatorNode.alpha = 0.0
        }
    }
    
    private func tankHit(health: Int) {
        guard health >= 0 else { return }
        
        let to: CGFloat = CGFloat(health) / 100
        let scaleX = SKAction.scaleX(to: to, duration: 1.5)
        
        if health <= dangerLevel {
            healthNode.alpha = 0.0
            healthNodeDanger.alpha = 1.0
            healthNodeDanger.run(scaleX)
        } else {
            healthNode.alpha = 1.0
            healthNodeDanger.alpha = 0.0
            healthNode.run(scaleX)
        }
        
        percentText.text = "\(health) %"
        
        if health <= 0 {
            gameOver()
            return
        }
    }
    
    private func enemyHit(health: Int) {
        
    }
    
    private func gameOver() {
        print("GAME OVER")
        let delay = SKAction.wait(forDuration: 3)
        let goToMenu = SKAction.run { [unowned self] in
            let gameScene = self.parent as! GameScene
            gameScene.goToMenuScene()
        }
        let sequence = SKAction.sequence([
            delay, goToMenu
        ])
        
        self.run(sequence)
    }
    
    deinit {
        print("HUD Deinit")
    }
    
}
