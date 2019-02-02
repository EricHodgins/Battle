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
    
    public static func createDebris(gameScene: GameScene, atPosition point: CGPoint) {

        let numberOfItems = Int.random(in: 0 ... 20)
        
        for _ in 0 ... numberOfItems {
            let randomPiece = Int.random(in: 0 ... 4)
            let imageName = "log_fragment_" + "\(randomPiece)"
            let node = SKSpriteNode(imageNamed: imageName)
            node.position = point
            node.zPosition = 15
            node.name = "debris"
            gameScene.addChild(node)
            
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.frame.width/2)
            let randomDx = Int.random(in: -350 ... 350)
            let randomDy = Int.random(in: 200 ... 300)
            node.physicsBody?.velocity = CGVector(dx: randomDx, dy: randomDy)
            node.physicsBody?.affectedByGravity = false
            node.setScale(0.25)
            
            
//            guard let explosion = SKEmitterNode(fileNamed: "FireBall") else { return }
//            explosion.position = CGPoint(x: 0.5, y: 0.5)
//            explosion.zPosition = 20
//            explosion.targetNode = node
            
//            node.addChild(explosion)
            
            let delay = SKAction.wait(forDuration: 1.0)
            node.run(delay) {
                //explosion.removeFromParent()
                node.removeFromParent()
            }
        }
    }
}
