//
//  Message.swift
//  animalsFighting
//
//  Created by lieyunye on 8/10/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import Foundation
import GameKit

enum MessageType : Int {
    case MessageTypeGameBegin
    case MessageTypeGameOver
    case MessageTypeGamePlaying
}

class Message : NSObject,NSCoding{
    
    var _messageType : MessageType?
    var _messageString : String?
    var sourcePosition:CGPoint!
    var destinationPosition : CGPoint!
    
    override init(){}
    
    @objc func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(_messageString, forKey: "_messageString")
        aCoder.encodeObject(_messageType?.rawValue, forKey: "_messageType")        
        aCoder.encodeCGPoint(sourcePosition, forKey: "sourcePosition")
        aCoder.encodeCGPoint(destinationPosition, forKey: "destinationPosition")
    }
    
    @objc required init(coder aDecoder: NSCoder) {
        _messageString = aDecoder.decodeObjectForKey("_messageString") as? String
        _messageType = aDecoder.decodeObjectForKey("_messageType") as? MessageType
        sourcePosition = aDecoder.decodeCGPointForKey("sourcePosition")
        destinationPosition = aDecoder.decodeCGPointForKey("destinationPosition")
    }
    
}