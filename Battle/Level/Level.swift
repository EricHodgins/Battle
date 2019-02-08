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
    
    public var numberOfPowerups: Int = 1
    private var powerupYpositions: [CGFloat] = []
    
    private var lastPowerupSprite: PowerupSprite!
    private let powerupSpawnTime: TimeInterval = 5.0
    private var tankIsInMotion: Bool = false
    private var obstacleSpawnTime: TimeInterval = 1.0
    private var lastObstacleSpawnTime: TimeInterval = 0.0
    
    public var roundComplete: Bool = false
    private var round: Int = 0
    
    private var lastTankIsInMotionTimeInterval: TimeInterval = 0.0
    private var tankIsInMotionDuration: TimeInterval = 5.0
    
    init(gameScene: GameScene) {
        self.gameScene = gameScene
        buildLevel()
    }
    
    public func getTurrets() -> [Turret] {
        return turrets
    }
    
    public func buildLevel() {
        guard let gameScene = self.gameScene else { fatalError() }
        round += 1
        showRound()
        
        let heightDiff = (gameScene.size.height * (2 / 3)) - (gameScene.size.height * (1 / 3))
        let verticalSpacing: CGFloat = heightDiff / CGFloat(numberOfTurrets + numberOfPowerups - 1)
        let adjustedYPositionForCam: CGFloat
        if gameScene.cam.position.y <= 0 {
            adjustedYPositionForCam = gameScene.size.height / 2
        } else {
            adjustedYPositionForCam = gameScene.cam.position.y
        }
        
        for i in stride(from: 0, to: numberOfTurrets + numberOfPowerups, by: 1) {
            if i % 2 != 0 {
                let randomYpos = adjustedYPositionForCam - (gameScene.size.height / 2) + (gameScene.size.height * (1 / 3) + (CGFloat(i) * verticalSpacing)) //+ gameScene.cam.position.y - (gameScene.size.height / 2)
                powerupYpositions.append(randomYpos)
                let powerupTripleBullet = PowerupTripleBullet()
                powerupTripleBullet.position = CGPoint(x: randomXposition(), y: randomYpos)
                gameScene.addChild(powerupTripleBullet)
            } else {
                let turret = Turret()
                turret.position.x = randomXposition()
                turret.position.y = adjustedYPositionForCam - (gameScene.size.height / 2) + gameScene.size.height * (1 / 3) + (CGFloat(i) * verticalSpacing) //+ gameScene.cam.position.y - (gameScene.size.height / 2)
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
        
        if roundComplete {
            for turret in turrets {
                addDisappearSmoke(atPosition: turret.position)
                turret.removeFromParent()
                turret.targetAcquiredHandler = nil
            }
            roundComplete = false
            tankIsInMotion = true
            turrets = []
        }
        
        if tankIsInMotion {
            
            if lastTankIsInMotionTimeInterval == 0.0 {
                lastTankIsInMotionTimeInterval = currentTime
            }
            
            if lastObstacleSpawnTime == 0.0 {
                lastObstacleSpawnTime = currentTime
            }
            
            // 1. Spawn obstacle
            if (currentTime - lastObstacleSpawnTime) > obstacleSpawnTime {
                lastObstacleSpawnTime = currentTime
                spawnObstacle()
            }
            
            // 2. Check tank is in motion time duration
            if (currentTime - lastTankIsInMotionTimeInterval) > tankIsInMotionDuration {
                guard let gamescene = gameScene else { return }
                let tank = gamescene.tank!

                tankIsInMotion = false
                tank.hasDefeatedEnemy = false
                removeObstacles()
                removePowerups()
                gamescene.reBuildEnemy()
                
                lastTankIsInMotionTimeInterval = 0.0
            }
        }
    }
    
    private func spawnObstacle() {
        guard let gamescene = self.gameScene  else { return }
        
        let cam = gamescene.cam
        let yPosition = cam.position.y + (gamescene.size.height / 2) + 100
        let randInt = EffectsHelper.randomInt(max: 100)
        if randInt % 2 == 0 {
            let boulder = Boulder()
            let randomScale = EffectsHelper.randomScale(withMinimum: 0.3)
            boulder.position = CGPoint(x: randomXposition(), y: yPosition)
            gamescene.addChild(boulder)
            boulder.setScale(randomScale)
        } else {
            let woodStack = WoodStack()
            let randomScale = EffectsHelper.randomScale(withMinimum: 0.3)
            woodStack.position = CGPoint(x: randomXposition(), y: yPosition)
            gamescene.addChild(woodStack)
            woodStack.setScale(randomScale)
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
    
    public func removeObstacles() {
        guard let gamescene = gameScene else { return }
        
        gamescene.enumerateChildNodes(withName: "obstacle*") { [unowned self] (node, _) in
            self.addDisappearSmoke(atPosition: node.position)
            node.removeFromParent()
        }
    }
    
    public func removePowerups() {
        guard let gamescene = gameScene else { return }
        
        gamescene.enumerateChildNodes(withName: PowerupType.tripleBullet.rawValue) { [unowned self] (node, _) in
            self.addDisappearSmoke(atPosition: node.position)
            node.removeFromParent()
        }
        
        gamescene.enumerateChildNodes(withName: PowerupType.healthBoost.rawValue) { [unowned self] (node, _) in
            self.addDisappearSmoke(atPosition: node.position)
            node.removeFromParent()
        }
        
        gamescene.enumerateChildNodes(withName: PowerupType.moveTurrets.rawValue) { [unowned self] (node, _) in
            self.addDisappearSmoke(atPosition: node.position)
            node.removeFromParent()
        }
    }
    
    private func addDisappearSmoke(atPosition position: CGPoint) {
        if let smoke = SKEmitterNode(fileNamed: "DisappearSmoke"),
           let gamescene = gameScene {
            smoke.position = position
            smoke.zPosition = 10
            
            gamescene.addChild(smoke)
            
            let delay = SKAction.wait(forDuration: 10.0)
            gamescene.run(delay) {
                smoke.removeFromParent()
            }
        }
    }
    
    public func showRound() {
        guard let gamescene = gameScene else { return }
        var centerPosition = CGPoint(x: gamescene.cam.position.x, y: gamescene.cam.position.y)
        
        if gamescene.cam.position == CGPoint.zero {
            centerPosition = CGPoint(x: gamescene.size.width/2, y: gamescene.size.height/2)
        }
        
        let numberNode = SKLabelNode(fontNamed: "Arial Rounded MT Bold")
        numberNode.text = "\(self.round)"
        numberNode.fontSize = 80
        numberNode.position = centerPosition
        gamescene.addChild(numberNode)
        
        let fade = SKAction.fadeAlpha(to: 0.1, duration: 0.5)
        let normal = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        
        let sequence = SKAction.sequence([fade, normal])
        let fadeInOut = SKAction.repeat(sequence, count: 5)
        numberNode.run(fadeInOut) {
            numberNode.removeFromParent()
        }
    }
    
    deinit {
        print("Level Deinit")
    }
}
