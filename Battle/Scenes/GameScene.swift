//
//  GameScene.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-07.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var lastUpdateTime: TimeInterval!
    let gameDirector: GameDirector = GameDirector()
    var tank: Tank!
    var enemy: Tank!
    
    var tankAI: TankAI? = nil
    var level: Level!
    
    override func didMove(to view: SKView) {
        build()
        backgroundColor = .black
        self.physicsWorld.contactDelegate = self
        
        lastUpdateTime = 0.0
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = PhysicsCategory.boundary.rawValue
        
    }
    
    private func build() {
        level = Level(gameScene: self)
        
        tank = gameDirector.createHumanTank()
        enemy = gameDirector.createComputerTank()
        
        tank.position = CGPoint(x: self.size.width/2, y: 100)
        enemy.position = CGPoint(x: self.size.width/2, y: self.size.height - 100)
        enemy.zRotation += .pi
        
        tankAI = TankAI(gameScene: self)
        tankAI?.setupTurretsObserver()
        
        self.addChild(tank)
        self.addChild(enemy)
    }
    
    private func moveTank(touchingPoint: CGPoint) {
        if touchingPoint.x >= self.size.width / 2 {
            tank.direction = .right
        } else {
            tank.direction = .left
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchedPt = touch.location(in: self)
            if touchedPt.y >= 200 {
                tank.fireTowards(point: touchedPt, screenSize: self.size)
            } else {
                moveTank(touchingPoint: touchedPt)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchedPt = touch.location(in: self)
            if touchedPt.y <= 200 {
                moveTank(touchingPoint: touchedPt)
            }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        tank.direction = .idle
        //goToMenuScene()
    }
    
    private func goToMenuScene() {
        self.view?.presentScene(MenuScene(size: self.size))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0.0 {
            lastUpdateTime = currentTime
        }

        let timeDelta = currentTime - lastUpdateTime

        tank.update(currentTime, timeDelta: timeDelta)
        level.update(currentTime, timeDelta: timeDelta)
        
        lastUpdateTime = currentTime
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let otherBody: SKPhysicsBody
        let projectileBody: SKPhysicsBody
        let projectileMask = PhysicsCategory.projectile.rawValue
        
        if (contact.bodyA.categoryBitMask & projectileMask) > 0 {
            otherBody = contact.bodyB
            projectileBody = contact.bodyA
        } else {
            otherBody = contact.bodyA
            projectileBody = contact.bodyB
        }
        
        if let projectile = projectileBody.node as? Projectile {
            switch otherBody.categoryBitMask {
            case PhysicsCategory.boundary.rawValue:
                projectile.removeFromParent()
            case PhysicsCategory.tank.rawValue:
                projectile.removeFromParent()
            case PhysicsCategory.turret.rawValue:
                let shooter = projectile.shooter
                projectile.removeFromParent()
                if let turret = otherBody.node as? Turret {
                    turretHitSequence(turret: turret, shooter: shooter)
                }
            default:
                print("unknown contact hit between: \(String(describing: otherBody.node?.name)) & \(String(describing: projectileBody.node?.name)) ")
            }
        }
    }
    
    private func turretHitSequence(turret: Turret, shooter: Shooter) {
        //turret.wasHit.value = Target(shooter: shooter, wasHit: true)
        
        if shooter == .friendly {
            turret.aimAt(self.enemy)
        } else {
            turret.aimAt(self.tank)
        }
//        let newProjectile = Projectile()
//        newProjectile.velocity *= 2
//        newProjectile.shooter = shooter
//
//        let delay = SKAction.wait(forDuration: 3)
//        let fire = SKAction.run {
//            var goToPt = CGPoint.zero
//            if shooter == .friendly {
//                goToPt = self.enemy.position
//            } else {
//                goToPt = self.tank.position
//            }
//        }
    }
    
    deinit {
        print("GameScene deinit.")
    }
}
