//
//  GameDirector.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-08.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import Foundation

class GameDirector {
    
    public func createComputerTank() -> Tank {
        let builder = TankBuilder()
        builder.addType(.enemy)
        
        let computer = builder.build()
        
        return computer
    }
    
    public func createHumanTank() -> Tank {
        let builder = TankBuilder()
        builder.addType(.friendly)
        
        let human = builder.build()
        
        return human
    }
}
