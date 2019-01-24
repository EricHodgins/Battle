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
    
    let cam = SKCameraNode()
    
    var lastUpdateTime: TimeInterval!
    let gameDirector: GameDirector = GameDirector()
    var tank: Tank!
    var enemy: Tank!
    
    var tankAI: TankAI? = nil
    var level: Level!
    
    var leftControl: Control!
    var rightControl: Control!
    
    var hud: HUD!
    let background = Background()
    
    override func didMove(to view: SKView) {
        build()
        backgroundColor = .black
        self.physicsWorld.contactDelegate = self
        
        lastUpdateTime = 0.0
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = PhysicsCategory.boundary.rawValue
        
    }
    
    private func build() {
        self.camera = cam
        level = Level(gameScene: self)
        
        tank = gameDirector.createHumanTank()
        enemy = gameDirector.createComputerTank()
        
        tank.position = CGPoint(x: self.size.width/2, y: 100)
        enemy.position = CGPoint(x: self.size.width/2, y: self.size.height - 100)
        enemy.zRotation += .pi
        
        tankAI = TankAI(gameScene: self)
        tankAI?.setupTurretsObserver()
        
        self.addChild(self.camera!)
        self.camera!.zPosition = 50
        self.camera?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(tank)
        self.addChild(enemy)
        
        let yPosition: CGFloat = 40
        leftControl = Control(direction: .left)
        leftControl.anchorPoint = CGPoint.zero
        leftControl.position = CGPoint(x: 0, y: yPosition)
        rightControl = Control(direction: .right)
        rightControl.anchorPoint = CGPoint.zero
        rightControl.position = CGPoint(x: self.size.width - leftControl.size.width, y: yPosition)
        self.addChild(leftControl)
        self.addChild(rightControl)
        
        hud = HUD(playerTank: tank, enemyTank: enemy)
        hud.position = CGPoint(x: 10, y: self.size.height)
        self.addChild(hud)
        
        background.spawn(parentNode: self, imageName: "background_main")
    }
    
    private func moveTank(touchingPoint: CGPoint) {
        if touchingPoint.x >= self.size.width / 2 {
            rightControl.isPressed()
            leftControl.isIdle()
            tank.direction = .right
        } else {
            leftControl.isPressed()
            rightControl.isIdle()
            tank.direction = .left
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchedPt = touch.location(in: self)
            let node = atPoint(touchedPt)
            if touchedPt.y >= 200 {
                tank.fireTowards(point: touchedPt, screenSize: self.size)
            } else if node.name == "player_control" {
                node.convert(touchedPt, to: self)
                moveTank(touchingPoint: touchedPt)
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
        leftControl.isIdle()
        rightControl.isIdle()
        //goToMenuScene()
    }
    
    public func goToMenuScene() {
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
    
    func didEnd(_ contact: SKPhysicsContact) {
        
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
                let tank = otherBody.node as! Tank
                projectile.removeFromParent()
                if tank.type == .friendly {
                    EffectsHelper.screenShake(node: self.camera!, duration: 3)
                    tank.hasBeenHitBy(projectile: projectile, contact: contact)
                } else if tank.type == .enemy {
                    tank.hasBeenHitBy(projectile: projectile, contact: contact)
                }
            case PhysicsCategory.turret.rawValue:
                let shooter = projectile.shooter
                projectile.removeFromParent()
                if let turret = otherBody.node as? Turret {
                    turretHitSequence(turret: turret, shooter: shooter)
                }
            case PhysicsCategory.powerup.rawValue:
                let powerupNode = otherBody.node as! PowerupSprite
                if projectile.shooter == .friendly {
                    tank.addPowerup(powerup: powerupNode)
                } else {
                    enemy.addPowerup(powerup: powerupNode)
                }
                
                level.reSpawnPowerup(previousPowerup: powerupNode)
                projectile.removeFromParent()
                powerupNode.removeFromParent()
            default:
                print("unknown contact hit between: \(String(describing: otherBody.node?.name)) & \(String(describing: projectileBody.node?.name)) ")
            }
        }
    }
    
    private func turretHitSequence(turret: Turret, shooter: Shooter) {
        if shooter == .friendly {
            turret.aimAt(self.enemy) { [unowned self, unowned turret] in
                self.turretFire(turret: turret, target: self.enemy, shooter: shooter)
            }
        } else {
            turret.aimAt(self.tank) { [unowned self, unowned turret] in
                self.turretFire(turret: turret, target: self.tank, shooter: shooter)
            }
        }
    }
    
    private func turretFire(turret: Turret, target: Tank, shooter: Shooter) {
        let newProjectile = Projectile()
        newProjectile.zRotation = turret.zRotation
        newProjectile.velocity *= 2
        newProjectile.shooter = shooter
        
        let startPt = turret.convert(CGPoint(x: 0, y: 25), to: self)
        let endPt = MathHelper.trajectoryEndPoint(fromOrigin: startPt, toPoint: target.position, screenSize: self.size)
        let distance = MathHelper.trajectoryDistance(pointOffScreen: endPt, origin: startPt)
        let duration = MathHelper.trajectoryDuration(distance: distance, speed: CGFloat(newProjectile.velocity))
        
        let fireDelay = SKAction.wait(forDuration: turret.firingDelay)
        let fireProjectile = SKAction.run { // self, turret already unowned
            turret.didFire.value = Target(shooter: shooter, wasHit: true)
            turret.fireExplosion()
            self.addChild(newProjectile)
            newProjectile.position = startPt
            let moveAction = SKAction.move(to: endPt, duration: duration)
            newProjectile.run(moveAction)
        }
        
        let sequence = SKAction.sequence([
            fireDelay,
            fireProjectile,
        ])
        
        self.run(sequence)
    }
    
    deinit {
        print("GameScene deinit.")
    }
}
