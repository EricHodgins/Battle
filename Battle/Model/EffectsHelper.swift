//
//  EffectsHelper.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-19.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit
import GameplayKit.GKRandomSource

class EffectsHelper {
    public static func screenShake(node: SKCameraNode, duration: Float) {
        let amplitudeX: Int = 10
        let amplitudeY: Int = 6
        let numberOfShakes = duration / 0.04
        var actions: [SKAction] = []
        
        let randomSource = GKRandomSource.sharedRandom()
        for _ in stride(from: 1, to: Int(numberOfShakes), by: 1) {
            let moveX = CGFloat(randomSource.nextInt(upperBound: amplitudeX) - (amplitudeX / 2))
            let moveY = CGFloat(randomSource.nextInt(upperBound: amplitudeY) - (amplitudeY / 2))
            let shakeAction = SKAction.moveBy(x: moveX, y: moveY, duration: 0.02)
            shakeAction.timingMode = .easeOut
            actions.append(shakeAction)
            actions.append(shakeAction.reversed())
        }
        
        let seq = SKAction.sequence(actions)
        node.run(seq)
    }
    
    public static func randomScale(withMinimum min: Float) -> CGFloat {
        let scaleFactor = Float.random(in: min ... 1.0)
        return CGFloat(scaleFactor)
    }
    
    public static func randomInt(max: Int) -> Int {
        let randomSource = GKRandomSource.sharedRandom()
        let randInt = randomSource.nextInt(upperBound: max)
        return randInt
    }
}
