//
//  Turret.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-09.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class Turret: SKSpriteNode {
    
    enum RotateDirection {
        case left
        case right
    }
    
    var initialSize: CGSize = CGSize(width: 28, height: 24)
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Turret")
    
    var rotationSpeed: CGFloat = 0.01 // (rad / sec )
    var firingDelay: Double = 3
    var currentTarget: Tank? = nil
    private var canFire: Bool = false
    private var targetAcquiredHandler: (() -> Void)? = nil
    
    public var wasHit: Observable<Target> = Observable(Target(shooter: .friendly, wasHit: false))
    
    init() {
        let turretTexture = textureAtlas.textureNamed("turret")
        super.init(texture: turretTexture, color: .clear, size: initialSize)
        
        self.physicsBody = SKPhysicsBody(texture: turretTexture, size: self.size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.turret.rawValue
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 10
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.allowsRotation = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func aimAt(_ target: Tank, completion: @escaping (() -> Void)) {
        self.canFire = true
        self.currentTarget = target
        self.targetAcquiredHandler = completion
    }
    
    public func update(_ currentTime: TimeInterval, timeDelta: TimeInterval) {
        guard let target = currentTarget else { return }
        
        var targetAngle = MathHelper.rotationAngle(fromOrigin: self.position, toPoint: target.position)
        
        targetAngle = normalizeAngle(targetAngle)
        zRotation = normalizeAngle(zRotation)

        let diff = targetAngle - zRotation
        if diff >= 0 {
            if abs(diff) < .pi {
                rotateLeft(toTarget: targetAngle)
            } else {
                rotateRight(toTarget: targetAngle)
            }
        } else {
            if abs(diff) < .pi {
                rotateRight(toTarget: targetAngle)
            } else {
                rotateLeft(toTarget: targetAngle)
            }
        }
    }
    
    private func rotateLeft(toTarget target: CGFloat) {
        zRotation += rotationSpeed
        let diff = abs(zRotation - target)
        if diff > (.pi / 2) { return }
        if zRotation >= target {
            zRotation = target
            hasRotatedToTarget()
        }
    }
    
    private func rotateRight(toTarget target: CGFloat) {
        zRotation -= rotationSpeed
        let diff = abs(zRotation - target)
        if diff > (.pi / 2) { return }
        if zRotation <= target {
            zRotation = target
            hasRotatedToTarget()
        }
    }
    
    private func normalizeAngle(_ angle: CGFloat) -> CGFloat {
        let two_pi: CGFloat = 2 * .pi
        var normalized_angle: CGFloat = angle
        if angle > two_pi {
            normalized_angle = angle - two_pi
        } else if angle < -two_pi {
            normalized_angle = angle + two_pi
        }
        
        if normalized_angle < 0 {
            normalized_angle += (2 * .pi)
        }
        
        return normalized_angle
    }
    
    private func hasRotatedToTarget() {
        guard canFire else { return }
        guard let targetAcquiredHandler = targetAcquiredHandler else { return }
        canFire = false
        targetAcquiredHandler()
    }
    
    deinit {
        print("Turret Deinit")
    }
}
