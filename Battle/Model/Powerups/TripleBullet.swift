//
//  TripleBullet.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-21.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class TripleBullet {
    var type: PowerupType = PowerupType.tripleBullet
}

extension TripleBullet: Powerup {
    func activate(tank: Tank, pointFiredAt point: CGPoint, screenSize: CGSize) {
        for offsetX in stride(from: -100, to: 200, by: 100) {
            let xPoint = CGPoint(x: point.x + CGFloat(offsetX), y: point.y)
            tank.fireStandardProjectile(point: xPoint, screenSize: screenSize)
        }
    }
}
