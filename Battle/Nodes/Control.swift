//
//  Control.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-13.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class Control: SKSpriteNode {

    var initialSize: CGSize = CGSize(width: 100, height: 50)
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Controls")
    
    private let idleTexture: SKTexture!
    private let pressedTexture: SKTexture!
    
    init(direction: Direction) {
        if direction == .left {
            self.idleTexture = textureAtlas.textureNamed("move_left_idle")
            self.pressedTexture = textureAtlas.textureNamed("move_left_pressed")
        } else {
            self.idleTexture = textureAtlas.textureNamed("move_right_idle")
            self.pressedTexture = textureAtlas.textureNamed("move_right_pressed")
        }

        super.init(texture: idleTexture, color: .clear, size: initialSize)
        zPosition = 10
        self.name = "player_control"
    }
    
    required init?(coder aDecoder: NSCoder) {
        idleTexture = nil
        pressedTexture = nil
        super.init(coder: aDecoder)
    }
    
    public func isPressed() {
        self.texture = pressedTexture
    }
    
    public func isIdle() {
        self.texture = idleTexture
    }
}
