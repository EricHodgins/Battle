//
//  MenuScene.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-07.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    let textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "HUD")
    let playButton = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let title = SKLabelNode(fontNamed: "Arial Rounded MT Bold")
        title.text = "BATTLE"
        title.position = CGPoint(x: 0, y: 100)
        title.fontSize = 60
        self.addChild(title)
        
        playButton.texture = textureAtlas.textureNamed("play_idle")
        playButton.size = CGSize(width: 84, height: 49)
        playButton.name = "play"
        playButton.zPosition = 5
        self.addChild(playButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodeTouched = atPoint(location)
            if nodeTouched.name == "play" {
                self.view?.presentScene(GameScene(size: self.size))
            }
        }
    }
    
    deinit {
        print("MenuScene deinit.")
    }
    
}
