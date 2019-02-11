//
//  Turret.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-09.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit
import AVFoundation

class Turret: SKSpriteNode {
    
    private var musicPlayer = AVAudioPlayer()
    let turretHitSound = SKAction.playSoundFileNamed("TurretHit.wav", waitForCompletion: false)
    let turretShootSound = SKAction.playSoundFileNamed("TurretShooting.wav", waitForCompletion: false)
    
    enum RotateDirection {
        case left
        case right
    }
    
    var initialSize: CGSize = CGSize(width: 28, height: 24)
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Turret")
    
    public var rotationSpeed: CGFloat = 0.01 // (rad / sec )
    public var firingDelay: Double = 1.0
    
    private var currentTarget: Tank? = nil
    private var canFire: Bool = false
    public var targetAcquiredHandler: (() -> Void)? = nil
    
    public var didFire: Observable<Target> = Observable(Target(shooter: .friendly, wasHit: false))
    
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
        
        setupTurretMovingSound()
    }
    
    private func setupTurretMovingSound() {
        guard let turretMoveSoundPath = Bundle.main.path(forResource: "TurretMove.wav", ofType: nil) else { return }
        let url = URL(fileURLWithPath: turretMoveSoundPath)
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer.numberOfLoops = -1
            musicPlayer.prepareToPlay()
        } catch {
            print("couldn't load turret moving sound file")
        }
        
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
        
        playTurretMovingSound()
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
    
    private func playTurretMovingSound() {
        musicPlayer.play()
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
        currentTarget = nil
        targetAcquiredHandler()
        stopPlayingTurretMovingSound()
    }
    
    private func stopPlayingTurretMovingSound() {
        musicPlayer.stop()
    }
    
    public func fireExplosion() {
        guard let explosion = SKEmitterNode(fileNamed: "TurretFired") else { return }
        explosion.emissionAngle *= -1
        explosion.zPosition = 10
        explosion.position = CGPoint(x: 0.5, y: self.size.height)
        explosion.targetNode = self
        self.addChild(explosion)
        
        let delay = SKAction.wait(forDuration: 3.0)
        self.run(delay) {
            explosion.removeFromParent()
        }
        
        self.run(turretShootSound)
    }
    
    public func hasBeenHit(contactPoint: CGPoint) {
        guard let explosion = SKEmitterNode(fileNamed: "TurretHit") else { return }
        self.run(turretHitSound)
        
        let gamescene = self.parent as! GameScene
        explosion.position = gamescene.convert(contactPoint, to: self)
        explosion.zPosition = 10
        explosion.targetNode = self
        
        self.addChild(explosion)
        let delay = SKAction.wait(forDuration: 3.0)
        self.run(delay) {
            explosion.removeFromParent()
        }
    }
    
    deinit {
        print("Turret Deinit")
    }
}
