//
//  TankAI.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-08.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit
import GameplayKit.GKRandomSource

class TankAI {
    weak private var gameScene: GameScene!
    private let human: Tank!
    private let computer: Tank!
    
    init(gameScene: GameScene) {
        self.gameScene = gameScene
        
        guard let human = gameScene.tank,
            let computer = gameScene.enemy else {
                fatalError("GameScene did not contain initailized Tanks for AI.")
        }
        
        self.human = human
        self.computer = computer
        
        setupHumanObserver()
    }
    
    private func setupHumanObserver() {
        guard let human = human else { fatalError("human was never found in gamescene") }
        
        human.didFireAtPoint.addObserver(self, removeIfExists: true, options: [.new]) { [unowned self] (pointOffScreen, change) in
            self.computer?.canShoot = true
            let fromPt = self.human.firingPoint()
            self.reactToHumanDidFire(atPoint: pointOffScreen, from: fromPt)
        }
    }
    
    private func updateTankStates() {
        computer.canShoot = false
        human.canShoot = true
    }
    
    private func reactToHumanDidFire(atPoint point: CGPoint, from: CGPoint) {
        
        let xIntersect: CGFloat
        
        fire(computer, fireAtHuman: human)
        
        if from.x < point.x {
            xIntersect = from.x + ((computer.position.y - from.y) / tan(MathHelper.angle(fromOrigin: from, toPoint: point)))
        } else {
            xIntersect = from.x - ((computer.position.y - from.y) / tan(MathHelper.angle(fromOrigin: from, toPoint: point)))
        }
        
        if xIntersect < computer.position.x + 50 && xIntersect > computer.position.x - 50 {
            if computer.position.x > gameScene.size.width / 2 {
                let moveToPt = CGPoint(x: computer.position.x - 100, y: computer.position.y)
                computer.moveTo(point: moveToPt)
            } else {
                let moveToPt = CGPoint(x: computer.position.x + 100, y: computer.position.y)
                computer.moveTo(point: moveToPt)
            }
        }
    }
    
    private func fire(_ computer: Tank, fireAtHuman human: Tank) {
        let delay = SKAction.wait(forDuration: randomDelayInSeconds())
        computer.run(delay) { [unowned self, unowned computer] in
            computer.fireTowards(point: self.randomlyChoosenTargetPosition(), screenSize: self.gameScene.size)
            self.updateTankStates()
        }
    }
    
    // up to 6.5 second delay
    private func randomDelayInSeconds() -> Double {
        let randomSource = GKRandomSource.sharedRandom()
        let randomSeconds = Float(randomSource.nextInt(upperBound: 6)) * randomSource.nextUniform() + 3.0
        return Double(randomSeconds)
    }
    
    private func randomlyChoosenTargetPosition() -> CGPoint {
        let targets = getTargetPositions()
        let randomSource = GKRandomSource.sharedRandom()
        let shuffledTargets = randomSource.arrayByShufflingObjects(in: targets)
        let targetPosition = shuffledTargets[0]
        return targetPosition as! CGPoint
    }
    
    private func getTargetPositions() -> [CGPoint] {
        guard let level = self.gameScene.level else { fatalError("No level was found grom gameScene.") }
        
        var targets: [CGPoint] = []
        for target in level.getTurrets() {
            targets.append(target.position)
        }

//        for powerup in level.getAllPowerUps() {
//            targets.append(powerup.position)
//        }

        targets.append(human.position)

        return targets
    }
    
    public func setupTurretsObserver() {
        guard let level = gameScene.level else { fatalError() }
        
        let turrets = level.getTurrets()
        for turret in turrets {
            turret.didFire.addObserver(self, removeIfExists: true, options: [.new]) { [unowned self, unowned turret] (target, _) in
                if target.shooter == .friendly {
                    self.reactToHumanDidFire(atPoint: self.computer.position, from: turret.position)
                }
            }
        }
    }
}
