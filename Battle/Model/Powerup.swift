//
//  Powerup.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-21.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

protocol Powerup: class {
    var type: PowerupType {get set}
    func activate(tank: Tank, pointFiredAt point: CGPoint, screenSize: CGSize)
}
