//
//  EndGameScene.swift
//  animalsFighting
//
//  Created by lieyunye on 4/11/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import SpriteKit
import GameKit
class EndGameScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        
        var lblTryAgain:SKLabelNode = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblTryAgain.fontSize = 30
        lblTryAgain.fontColor = SKColor.whiteColor()
        lblTryAgain.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        lblTryAgain.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblTryAgain.text = "Game Over! Tap To Try Again"
        self.addChild(lblTryAgain)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        startGame()
    }
    
    func startGame(){
        var gameScene:GameScene = GameScene.unarchiveFromFile("GameScene") as! GameScene
        var reveal:SKTransition = SKTransition.doorsOpenHorizontalWithDuration(1)
        self.view?.presentScene(gameScene, transition: reveal)
    }
    
}