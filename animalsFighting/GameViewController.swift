//
//  GameViewController.swift
//  animalsFighting
//
//  Created by lieyunye on 3/21/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector:"playerAuthenticated", name: LocalPlayerIsAuthenticated, object: nil)

        let scene:StartGameScene = StartGameScene()
        scene.size = self.view.frame.size
        
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        skView.ignoresSiblingOrder = false
        
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
//    - (void)playerAuthenticated {
//    
//    SKView *skView = (SKView*)self.view;
//    GameScene *scene = (GameScene*)skView.scene;
//    
//    _networkingEngine = [[MultiplayerNetworking alloc] init];
//    _networkingEngine.delegate = scene;
//    scene.networkingEngine = _networkingEngine;
//    
//    [[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self delegate:_networkingEngine];
//    }
    
    func playerAuthenticated() {
        
        GameKitHelper.sharedInstance.findMatchWithMinPlayers(2, maxPlayers:2, viewController: self)
        
    }
    
    
}
