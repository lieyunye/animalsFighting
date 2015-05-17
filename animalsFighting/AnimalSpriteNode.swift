//
//  AnimalSpriteNode.swift
//  animalsFighting
//
//  Created by lieyunye on 3/21/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import SpriteKit

protocol AnimalSpriteNodeDelegate
{
    func didTapOnSpriteNode(animalSpriteNode:AnimalSpriteNode)
}

class AnimalSpriteNode: SKSpriteNode {
    
    var power:Int!
    var hasFliped:Bool = false
    var animalTexture:SKTexture!
    var delegate:AnimalSpriteNodeDelegate!
    var backgroud:SKSpriteNode!
    var foregroud:AnimalPicSpriteNode!
    
    init(texture: SKTexture!, size: CGSize){
        super.init(texture: nil, color: nil, size: size)
        animalTexture = texture;
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        userInteractionEnabled = true
        
        backgroud = SKSpriteNode(color: nil, size: size)
        backgroud.userInteractionEnabled = false
        self.addChild(backgroud)
        
        foregroud = AnimalPicSpriteNode(texture: SKTexture(imageNamed:"card_back"), size: size)
        self.addChild(foregroud)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        println("AnimalSpriteNode touchesBegan")
        for touch: AnyObject in touches {
            if touch.tapCount == 1{
                delegate.didTapOnSpriteNode(self)
            }else {
                println("只支持单击")
            }
        }
    }
    
    func flip() {
        let firstHalfFlip = SKAction.scaleXTo(0.0, duration: 0.4)
        let secondHalfFlip = SKAction.scaleXTo(1.0, duration: 0.4)
        setScale(1.0)
        if hasFliped == false{
            runAction(firstHalfFlip){
                self.foregroud.texture = self.animalTexture
                self.hasFliped = true
                self.userInteractionEnabled = false
                self.runAction(secondHalfFlip)
            }
            
        }
    }
    
}
