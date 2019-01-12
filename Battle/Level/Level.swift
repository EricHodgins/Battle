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
    public var numberOfTurrets: Int = 3
    
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
        let verticalSpacing: CGFloat = heightDiff / CGFloat(numberOfTurrets - 1)
        for i in stride(from: 0, to: numberOfTurrets, by: 1) {
            if i % 2 != 0 {
//                let randomYpos = gameScene.size.height * (1 / 3) + (CGFloat(i) * verticalSpacing)
//                powerUpYpositions.append(randomYpos)
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
    
    deinit {
        print("Level Deinit")
    }
}
