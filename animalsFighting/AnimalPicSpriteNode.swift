//
//  AnimalPicSpriteNode.swift
//  animalsFighting
//
//  Created by lieyunye on 5/16/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import SpriteKit

class AnimalPicSpriteNode: SKSpriteNode {

    init(texture: SKTexture!, size: CGSize){
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        userInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}