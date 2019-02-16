//
//  MenuScene.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-07.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    weak var viewController: GameViewController?
    
    let textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "HUD")
    let playButton = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.black
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        let backgroundTexture = Background()
        backgroundTexture.spawn(parentNode: self, imageName: "background_main")
        
        let title = SKLabelNode(fontNamed: "Arial Rounded MT Bold")
        title.text = "BATTLE"
        title.position = CGPoint(x: size.width/2, y: size.height - 200)
        title.fontSize = 60
        self.addChild(title)
        
        let highScore = SKLabelNode(fontNamed: "Arial Rounded MT Bold")
        let highest = highestRound()
        highScore.text = "Record: \(highest)"
        highScore.position = CGPoint(x: size.width/2, y: title.position.y - 70)
        highScore.fontSize = 30
        self.addChild(highScore)
        
        playButton.texture = textureAtlas.textureNamed("play_idle")
        playButton.size = CGSize(width: 84, height: 49)
        playButton.name = "play"
        playButton.zPosition = 5
        playButton.position = CGPoint(x: size.width/2, y: highScore.position.y - 90)
        self.addChild(playButton)
        
        viewController?.showAdBanner = true
        viewController?.setupBannerAd()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodeTouched = atPoint(location)
            if nodeTouched.name == "play" {
                viewController?.removeBannerAd()
                viewController?.showAdBanner = false
                let gameScene = GameScene(size: self.size)
                gameScene.viewController = viewController
                self.view?.presentScene(gameScene)
            }
        }
    }
    
    private func highestRound() -> Int {
        let defaults = UserDefaults.standard
        let round = defaults.integer(forKey: "Round") // returns 0 if key does not exist
        return round
    }
 
    deinit {
        print("MenuScene deinit.")
    }
    
}
