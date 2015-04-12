//
//  StartGameScene.swift
//  animalsFighting
//
//  Created by lieyunye on 4/11/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import SpriteKit

class StartGameScene: SKScene {
    
    
    override func didMoveToView(view: SKView) {
        var tap2Start:SKSpriteNode = SKSpriteNode(imageNamed: "TapToStart")
        self.addChild(tap2Start)
        tap2Start.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        startGame()
    }
    
    func startGame(){
        var gameScene:GameScene = GameScene.unarchiveFromFile("GameScene") as GameScene
        var reveal:SKTransition = SKTransition.doorsOpenHorizontalWithDuration(1)
        self.view?.presentScene(gameScene, transition: reveal)
    }
}

