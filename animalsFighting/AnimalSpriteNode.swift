//
//  AnimalSpriteNode.swift
//  animalsFighting
//
//  Created by lieyunye on 3/21/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import SpriteKit

class AnimalSpriteNode: SKSpriteNode {
    
    var power:Int!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCodeing not supported")
    }
    
    init(color:UIColor,size:CGSize){
        super.init(texture: nil, color: color, size: size)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
    }
    
    func addAnimalName(animalName:String,color:UIColor){
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = animalName;
        myLabel.fontSize = 65;
        myLabel.fontColor = color
        myLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        myLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel)
    }
    
}
