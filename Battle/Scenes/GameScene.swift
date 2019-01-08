//
//  GameScene.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-07.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var lastUpdateTime: TimeInterval!
    
    let tank = Tank()
    
    override func didMove(to view: SKView) {
        lastUpdateTime = 0.0
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        tank.position = CGPoint(x: self.size.width/2, y: 100)
        self.addChild(tank)
    }
    
    private func moveTank(touchingPoint: CGPoint) {
        if touchingPoint.x >= self.size.width / 2 {
            tank.direction = .right
        } else {
            tank.direction = .left
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchedPt = touch.location(in: self)
            moveTank(touchingPoint: touchedPt)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchedPt = touch.location(in: self)
            moveTank(touchingPoint: touchedPt)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        self.view?.presentScene(MenuScene(size: self.size))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0.0 {
            lastUpdateTime = currentTime
        }
        
        let timeDelta = currentTime - lastUpdateTime
        
        tank.update(currentTime, timeDelta: timeDelta)
        
        lastUpdateTime = currentTime
    }
    
    deinit {
        print("GameScene deinit.")
    }
}
