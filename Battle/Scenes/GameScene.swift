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
    let tankInitialYpos: CGFloat = 100
    var enemy: Tank!
    
    var tankAI: TankAI? = nil
    var level: Level!
    
    var leftControl: Control!
    var rightControl: Control!
    
    var hud: HUD!
    let background = Background()
    
    let boundary = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        build()
        backgroundColor = .black
        self.physicsWorld.contactDelegate = self
        
        lastUpdateTime = 0.0
    }
    
    private func build() {
        self.camera = cam
        level = Level(gameScene: self)
        
        tank = gameDirector.createHumanTank()
        enemy = gameDirector.createComputerTank()
        
        tank.position = CGPoint(x: self.size.width/2, y: tankInitialYpos)
        enemy.position = CGPoint(x: self.size.width/2, y: self.size.height - 100)
        enemy.zRotation += .pi
        
        tankAI = TankAI(gameScene: self)
        tankAI?.setupTurretsObserver()
        
        self.addChild(self.camera!)
        self.camera!.zPosition = 50
        self.camera?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(tank)
        self.addChild(enemy)
        
        let yPosition: CGFloat = -self.size.height/2 + 40
        leftControl = Control(direction: .left)
        leftControl.anchorPoint = CGPoint.zero
        leftControl.position = CGPoint(x: -self.size.width/2, y: yPosition)
        rightControl = Control(direction: .right)
        rightControl.anchorPoint = CGPoint.zero
        rightControl.position = CGPoint(x: self.size.width/2 - leftControl.size.width, y: yPosition)
        
        hud = HUD(playerTank: tank, enemyTank: enemy)
        hud.position = CGPoint(x: -self.size.width/2, y: self.size.height/2)
        
        cam.addChild(hud)
        cam.addChild(leftControl)
        cam.addChild(rightControl)
        
        background.spawn(parentNode: self, imageName: "background_main")
        
        let boundarySize = CGSize(width: self.size.width, height: self.size.height + 500)
        let origin = CGPoint(x: 0, y: (cam.position.y) - self.size.height/2 - 250)
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: origin, size: boundarySize))
        boundary.physicsBody?.categoryBitMask = PhysicsCategory.boundary.rawValue
        
        self.addChild(boundary)
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
            if touchedPt.y >= tank.position.y {
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
            if touchedPt.y <= tank.position.y {
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
    
    override func didSimulatePhysics() {
        if tank.hasDefeatedEnemy {
            cam.position.y = (self.frame.height / 2) + tank.position.y - tankInitialYpos
            boundary.position = CGPoint(x: 0, y: (cam.position.y) - self.size.height/2)
            background.updateBackground(playerPositionY: tank.position.y)
        }
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
        let projectileMask = PhysicsCategory.projectile.rawValue
        let tankMask = PhysicsCategory.tank.rawValue
        let obstacleMask = PhysicsCategory.obstacle.rawValue
        
        if (contact.bodyA.categoryBitMask & projectileMask) > 0 || (contact.bodyB.categoryBitMask & projectileMask) > 0 {
            handleProjectile(contact: contact)
        }
        
        if (contact.bodyA.categoryBitMask & tankMask) > 0 || (contact.bodyB.categoryBitMask & tankMask) > 0 {
            handleTank(contact: contact)
        }
        
        if (contact.bodyA.categoryBitMask & obstacleMask) > 0 || (contact.bodyB.categoryBitMask & obstacleMask) > 0 {
            handleObstacle(contact: contact)
        }
    }
    
    private func handleProjectile(contact: SKPhysicsContact) {
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
                    tank.hasBeenHitBy(projectile: projectile, contact: contact) { [unowned self] health in
                        if health <= 0 {
                            self.enemy.hasDefeatedEnemy = true
                        }
                    }
                } else if tank.type == .enemy {
                    tank.hasBeenHitBy(projectile: projectile, contact: contact) { [unowned self] health in
                        if health <= 0 {
                            self.enemy.removeFromParent()
                            self.enemy = nil
                            self.tank.hasDefeatedEnemy = true
                            let delay = SKAction.wait(forDuration: 0.1)
                            self.run(delay, completion: { [unowned self] in
                                self.level.roundComplete = true
                            })
                            self.level.removePowerups()
                        }
                    }
                }
            case PhysicsCategory.turret.rawValue:
                let shooter = projectile.shooter
                projectile.removeFromParent()
                if let turret = otherBody.node as? Turret {
                    turret.hasBeenHit(contactPoint: contact.contactPoint)
                    turretHitSequence(turret: turret, shooter: shooter)
                }
            case PhysicsCategory.powerup.rawValue:
                let powerupNode = otherBody.node as! PowerupSprite
                powerupNode.addFlashTo(gameScene: self, atPoint: contact.contactPoint)
                
                if projectile.shooter == .friendly {
                    tank.addPowerup(powerup: powerupNode)
                } else {
                    enemy.addPowerup(powerup: powerupNode)
                }
                
                if tank.hasDefeatedEnemy == false {
                    level.reSpawnPowerup(previousPowerup: powerupNode)
                }
                projectile.removeFromParent()
                powerupNode.removeFromParent()
            case PhysicsCategory.obstacle.rawValue:
                print("projectile hit boulder")
                let boulder = otherBody.node as! Boulder
                boulder.hasBeenHit(contactPoint: contact.contactPoint)
                projectile.removeFromParent()
            default:
                print("unknown contact hit between: \(String(describing: otherBody.node?.name)) & \(String(describing: projectileBody.node?.name)) ")
            }
        }
    }
    
    private func handleTank(contact: SKPhysicsContact) {
        let otherBody: SKPhysicsBody
        let tankBody: SKPhysicsBody
        let tankMask = PhysicsCategory.tank.rawValue
        
        if (contact.bodyA.categoryBitMask & tankMask) > 0 {
            otherBody = contact.bodyB
            tankBody = contact.bodyA
        } else {
            otherBody = contact.bodyA
            tankBody = contact.bodyB
        }
        
        if let tank = tankBody.node as? Tank {
            switch otherBody.categoryBitMask {
            case PhysicsCategory.obstacle.rawValue:
                EffectsHelper.screenShake(node: self.camera!, duration: 3)
                let boulder = otherBody.node as! Boulder
                tank.hasBeenHitBy(obstacle: boulder, contact: contact) { (health) in
                    if health <= 0 {
                        //MARK: - TODO
                    }
                }
            default:
                print("unknown contact hit between: \(String(describing: otherBody.node?.name)) & \(String(describing: tankBody.node?.name)) ")
            }
        }
        
    }
    
    private func handleObstacle(contact: SKPhysicsContact) {
        let otherBody: SKPhysicsBody
        let obstacleBody: SKPhysicsBody
        let obstacleMask = PhysicsCategory.obstacle.rawValue
        
        if (contact.bodyA.categoryBitMask & obstacleMask) > 0 {
            otherBody = contact.bodyB
            obstacleBody = contact.bodyA
        } else {
            otherBody = contact.bodyA
            obstacleBody = contact.bodyB
        }
        
        switch otherBody.categoryBitMask {
        case PhysicsCategory.boundary.rawValue:
            obstacleBody.node?.removeFromParent()
        default:
            print("unknown contact hit between: \(String(describing: otherBody.node?.name)) & \(String(describing: obstacleBody.node?.name)) ")
        }
    }
    
    private func turretHitSequence(turret: Turret, shooter: Shooter) {
        if shooter == .friendly {
            guard enemy != nil else { return }
            turret.aimAt(self.enemy) { [unowned self, unowned turret] in
                guard self.enemy != nil else { return }
                self.turretFire(turret: turret, target: self.enemy, shooter: shooter)
            }
        } else {
            guard tank != nil else { return }
            turret.aimAt(self.tank) { [unowned self, unowned turret] in
                guard self.tank != nil else { return }
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
