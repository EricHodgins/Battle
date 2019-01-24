//
//  Level.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-09.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit
import GameplayKit.GKRandomSource

class Level {
    weak var gameScene: GameScene?
    private var turrets: [Turret] = []
    public var numberOfTurrets: Int = 2
    
    public var numberOfPowerups: Int = 2
    private var powerupYpositions: [CGFloat] = []
    
    private var lastPowerupSprite: PowerupSprite!
    private let powerupSpawnTime: TimeInterval = 5.0
    
    init(gameScene: GameScene) {
        self.gameScene = gameScene
        buildLevel()
    }
    
    public func getTurrets() -> [Turret] {
        return turrets
    }
    
    private func buildLevel() {
        guard let gameScene = self.gameScene else { fatalError() }
        
        let heightDiff = (gameScene.size.height * (2 / 3)) - (gameScene.size.height * (1 / 3))
        let verticalSpacing: CGFloat = heightDiff / CGFloat(numberOfTurrets + numberOfPowerups - 1)
        for i in stride(from: 0, to: numberOfTurrets + numberOfPowerups, by: 1) {
            if i % 2 != 0 {
                let randomYpos = gameScene.size.height * (1 / 3) + (CGFloat(i) * verticalSpacing)
                powerupYpositions.append(randomYpos)
                let powerupTripleBullet = PowerupTripleBullet()
                powerupTripleBullet.position = CGPoint(x: randomXposition(), y: randomYpos)
                gameScene.addChild(powerupTripleBullet)
            } else {
                let turret = Turret()
                turret.position.x = randomXposition()
                turret.position.y = gameScene.size.height * (1 / 3) + (CGFloat(i) * verticalSpacing)
                turrets.append(turret)
                gameScene.addChild(turret)
            }
        }
    }
    
    private func randomXposition() -> CGFloat {
        guard let gameScene = self.gameScene else { fatalError() }
        
        let randomSource = GKRandomSource.sharedRandom()
        let minX = Int(gameScene.size.width * 0.05)
        let maxX = Int(gameScene.size.width * 0.95)
        let randomX = CGFloat((Float(randomSource.nextInt(upperBound: maxX - minX))) + Float(minX))
        return randomX
    }
    
    public func update(_ currentTime: TimeInterval, timeDelta: TimeInterval) {
        for turret in turrets {
            turret.update(currentTime, timeDelta: timeDelta)
        }
    }
    
    public func moveTurrets() {
        for turret in turrets {
            let newPosition = CGPoint(x: randomXposition(), y: turret.position.y)
            let moveAction = SKAction.move(to: newPosition, duration: 3)
            turret.run(moveAction)
        }
    }
    
    public func reSpawnPowerup(previousPowerup: PowerupSprite) {
        guard lastPowerupSprite != previousPowerup else { return }
        lastPowerupSprite = previousPowerup
        
        guard let gameScene = self.gameScene else { fatalError() }
        
        let randomPowerup = getRandomPowerup()
        randomPowerup.position = CGPoint(x: randomXposition(), y: previousPowerup.position.y)
        let delay = SKAction.wait(forDuration: powerupSpawnTime)
        let add = SKAction.run { [unowned gameScene] in
            gameScene.addChild(randomPowerup)
        }
        let seq = SKAction.sequence([delay, add])
        gameScene.run(seq)
    }
    
    private func getRandomPowerup() -> PowerupSprite {
        let allPowerupTypes = [PowerupType.tripleBullet, PowerupType.healthBoost, PowerupType.moveTurrets]
        let randomSource = GKRandomSource.sharedRandom()
        let randomIdx = randomSource.nextInt(upperBound: allPowerupTypes.count)
        let powerupType = allPowerupTypes[randomIdx]
        
        switch powerupType {
        case .healthBoost:
            return PowerupHealthBoost()
        case .moveTurrets:
            return PowerupMoveTurrets()
        case .tripleBullet:
            return PowerupTripleBullet()
        }
    }
    
    deinit {
        print("Level Deinit")
    }
}
