//
//  Tank.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-08.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class Tank: SKSpriteNode {
    var initialSize: CGSize = CGSize(width: 66, height: 45)
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Tank")
    let type: TankType!
    
    var canShoot: Bool = true
    var direction: Direction = .idle
    public let movingSpeed: Double = 60
    
    var didFireAtPoint: Observable<CGPoint> = Observable(CGPoint.zero)
    
    init(type: TankType) {
        self.type = type
        let tankTexture: SKTexture
        if type == .friendly {
            tankTexture = textureAtlas.textureNamed("friendly")
        } else {
            tankTexture = textureAtlas.textureNamed("enemy")
        }
    
        super.init(texture: tankTexture, color: .clear, size: initialSize)
        
        self.physicsBody = SKPhysicsBody(texture: tankTexture, size: self.size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.tank.rawValue
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 10000000
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.allowsRotation = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        type = nil
        super.init(coder: aDecoder)
    }
    
    public func update(_ currentTime: TimeInterval, timeDelta: TimeInterval) {
        if direction != .idle {
            moveTank(timeDelta: timeDelta)
        }
    }
    
    private func moveTank(timeDelta: TimeInterval) {
        let distanceToTravel: CGFloat = CGFloat(timeDelta * self.movingSpeed)
        
        if direction == .right {
            self.position.x += distanceToTravel
        } else {
            self.position.x -= distanceToTravel
        }
    }
    
    public func fireTowards(point: CGPoint, screenSize: CGSize) {
        if canShoot {
            udpateStateForJustFired()
            fireStandardProjectile(point: point, screenSize: screenSize)
        }
    }
    
    private func udpateStateForJustFired() {
        canShoot = false
    }
    
    private func fireStandardProjectile(point: CGPoint, screenSize: CGSize) {
        guard let gameScene = self.parent as? GameScene else { fatalError() }
        
        let projectile = Projectile()
        
        let yPosition: CGFloat
        if type == .friendly {
            projectile.shooter = .friendly
            yPosition = position.y + (size.height/2) + 8
        } else {
            projectile.shooter = .enemy
            yPosition = position.y - (size.height/2) - 8
        }
        
        projectile.position = CGPoint(x: position.x, y: yPosition)
        
        let emissionAngle = MathHelper.calculateEmissionAngle(fromOrigin: CGPoint(x: self.position.x, y: yPosition), toPoint: point)
        projectile.zRotation = .pi/2 - emissionAngle
        
        let pointOffScreen = MathHelper.trajectoryEndPoint(fromOrigin: self.position, toPoint: point, screenSize: screenSize)
        
        // Observable For AI
        didFireAtPoint.value = pointOffScreen
        
        let distance = MathHelper.trajectoryDistance(pointOffScreen: pointOffScreen, origin: self.position)
        let duration = MathHelper.trajectoryDuration(distance: distance, speed: CGFloat(projectile.velocity))
        
        let projectileMoveTo = SKAction.move(to: pointOffScreen, duration: duration)
        gameScene.addChild(projectile)
        projectile.run(projectileMoveTo)
    }
    
    deinit {
        print("Tank Deinit: \(String(describing: self.name))")
    }
}

extension Tank {
    public func moveTo(point: CGPoint) {
        let distance = abs(self.position.x - point.x)
        let duration = Double(distance) / Double(movingSpeed)
        let moveAction = SKAction.move(to: point, duration: duration)
        self.run(moveAction)
    }
    
    public func firingPoint() -> CGPoint {
        let yPosition = position.y + (size.height/2) + 8
        return CGPoint(x: self.position.x, y: yPosition)
    }
}
