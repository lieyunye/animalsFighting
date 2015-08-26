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
    case MessageTypeGameFlip
}

class Message : NSObject,NSCoding{
    
    var messageType : MessageType!
    var messageString : String!
    var animalPositions : [CGPoint]!
    var sourcePosition : CGPoint!
    var destinationPosition : CGPoint!
    var flipPosition : CGPoint!
    
    override init(){
        messageType = .MessageTypeGameBegin
        messageString = ""
        animalPositions = [CGPoint]()
        sourcePosition = CGPointZero
        destinationPosition = CGPointZero
        flipPosition = CGPointZero
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(messageString, forKey: "messageString")
        aCoder.encodeObject(messageType.rawValue, forKey: "messageType")
        let data = NSData(bytes: animalPositions, length: animalPositions.count * sizeof(CGPoint))
        aCoder.encodeObject(data, forKey: "animalPositions")
        aCoder.encodeCGPoint(sourcePosition, forKey: "sourcePosition")
        aCoder.encodeCGPoint(destinationPosition, forKey: "destinationPosition")
        aCoder.encodeCGPoint(flipPosition, forKey: "flipPosition")

    }
    
    @objc required init(coder aDecoder: NSCoder) {
        messageString = (aDecoder.decodeObjectForKey("messageString") as? String)!
        messageType = MessageType(rawValue: (aDecoder.decodeObjectForKey("messageType") as? Int)!)!
        let data : NSData = aDecoder.decodeObjectForKey("animalPositions") as! NSData
        let pointer = UnsafePointer<CGPoint>(data.bytes)
        let count = data.length / sizeof(CGPoint)
        let buffer = UnsafeBufferPointer<CGPoint>(start: pointer, count: count)
        animalPositions = [CGPoint](buffer)
        sourcePosition = aDecoder.decodeCGPointForKey("sourcePosition")
        destinationPosition = aDecoder.decodeCGPointForKey("destinationPosition")
        flipPosition = aDecoder.decodeCGPointForKey("flipPosition")
    }
    
}

class MessageTypeGameBegin:NSObject {
    var animalPositions :[CGPoint]!
    
    override init() {
        super.init()
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder){
        let data = NSData(bytes: animalPositions, length: animalPositions.count * sizeof(CGPoint))
        aCoder.encodeObject(data, forKey: "animalPositions")
    }
    
    @objc required init(coder aDecoder: NSCoder) {
        let data : NSData = aDecoder.decodeObjectForKey("animalPositions") as! NSData
        let pointer = UnsafePointer<CGPoint>(data.bytes)
        let count = data.length / sizeof(CGPoint)
        let buffer = UnsafeBufferPointer<CGPoint>(start: pointer, count: count)
        animalPositions = [CGPoint](buffer)
    }
}

class MessageTypeGameOver: Message {
    override init() {
        super.init()
    }

    @objc override func encodeWithCoder(aCoder: NSCoder){
    }
    
    @objc required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MessageTypeGamePlaying: NSObject {
    var sourcePosition:CGPoint!
    var destinationPosition : CGPoint!
    
    override init() {
        super.init()
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeCGPoint(sourcePosition, forKey: "sourcePosition")
        aCoder.encodeCGPoint(destinationPosition, forKey: "destinationPosition")
    }
    
    @objc required init(coder aDecoder: NSCoder) {
        sourcePosition = aDecoder.decodeCGPointForKey("sourcePosition")
        destinationPosition = aDecoder.decodeCGPointForKey("destinationPosition")
    }
}
