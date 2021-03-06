//
//  Types.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-08.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

enum TankType: String {
    case friendly = "friendly"
    case enemy = "enemy"
}

enum PhysicsCategory: UInt32 {
    case boundary = 1
    case tank = 2
    case projectile = 4
    case turret = 8
    case powerup = 16
    case tankRecoverMode = 32
    case obstacle = 64
}

enum Shooter {
    case friendly
    case enemy
}

enum PowerupType: String {
    case tripleBullet = "powerup_triple_bullet"
    case healthBoost = "powerup_health_boost"
    case moveTurrets = "powerup_move_turrets"
}

struct Target {
    var shooter: Shooter
    var wasHit: Bool
}

struct TankHit {
    var health: Int
}
