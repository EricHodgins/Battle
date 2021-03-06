//
//  GameViewController.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-07.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//


import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

protocol AdMobViewable: class {
    func showBannerView()
    func removeBannerView()
}

class GameViewController: UIViewController {
    
    var bannerView: GADBannerView!
    public var showAdBanner = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuScene = MenuScene()
        menuScene.viewController = self
        
        let view = self.view as! SKView
        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
        
        menuScene.size = view.bounds.size
        view.presentScene(menuScene)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public func setupBannerAd() {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = "ca-app-pub-3236494717448231/9073192399"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    public func removeBannerAd() {
        bannerView.removeFromSuperview()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}


extension GameViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if showAdBanner {
            addBannerView(bannerView)
        }
    }
    
    private func addBannerView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        let guide: UILayoutGuide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }
}
