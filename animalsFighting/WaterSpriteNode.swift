//
//  WaterSpriteNode.swift
//  animalsFighting
//
//  Created by lieyunye on 3/28/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import SpriteKit

class WaterSpriteNode: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCodeing not supported")
    }
    
    init(color:UIColor,size:CGSize){
        super.init(texture: nil, color: color, size: size)
    }
}
