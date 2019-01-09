//
//  TankBuilder.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-08.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class TankBuilder {
    private var type: TankType = .friendly
    
    
    public func addType(_ type: TankType) {
        self.type = type
    }
    
    public func build() -> Tank {
        let tank = Tank(type: self.type)
        tank.name = type.rawValue
        
        return tank
    }
}
