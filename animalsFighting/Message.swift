//
//  Message.swift
//  animalsFighting
//
//  Created by lieyunye on 8/10/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import Foundation
import GameKit

enum ConnectState : String {
    case ConnectStateConnecting = "ConnectStateConnecting"
    case ConnectStateConnected = "ConnectStateConnected"
    case ConnectStateNotConnected = "ConnectStateNotConnected"
    case ConnectStateUnkown = "ConnectStateUnkown"
}


enum OrderMessageTapType: Int {
    case OrderMessageTapTypeUnkonw
    case OrderMessageTapType2Select
    case OrderMessageTapType2Flip
}

enum OrderMessageType: Int {
    case OrderMessageTypeUnkonw
    case OrderMessageTypeTap
    case OrderMessageTypeMove
}

struct OrderMessage {
    var orderMessageType: OrderMessageType!
    var orderMessageTapType: OrderMessageTapType!
    var tapPosition: CGPoint!
    var sourcePosition: CGPoint!
    var destinationPosition: CGPoint!
    var destinationPositionXXXXXX: CGFloat!
    var destinationPositionYYYYYY: CGFloat!

    init() {
        orderMessageType = OrderMessageType.OrderMessageTypeUnkonw
        orderMessageTapType = OrderMessageTapType.OrderMessageTapTypeUnkonw
        tapPosition = CGPointZero
        sourcePosition = CGPointZero
        destinationPosition = CGPointZero
        
        destinationPositionXXXXXX = 0.00000
        destinationPositionYYYYYY = 0.00000
    }
}

enum MessageType : Int {
    case MessageTypeGameUnkonw
    case MessageTypeGameBegin
    case MessageTypeGamePlaying
    case MessageTypeGameOver
}

class Message : NSObject,NSCoding{
    
    var messageType : MessageType!
    var animalPositions : [CGPoint]!
    var descArray: [OrderMessage]!
    
    override init(){
        messageType = .MessageTypeGameUnkonw
        animalPositions = [CGPoint]()
        descArray = [OrderMessage]()
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(messageType.rawValue, forKey: "messageType")
        let data = NSData(bytes: animalPositions, length: animalPositions.count * sizeof(CGPoint))
        aCoder.encodeObject(data, forKey: "animalPositions")
        
        let descData = NSData(bytes: descArray, length: descArray.count * sizeof(OrderMessage))
        aCoder.encodeObject(descData, forKey: "descArray")

    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        messageType = MessageType(rawValue: (aDecoder.decodeObjectForKey("messageType") as? Int)!)!
        
        let data : NSData = aDecoder.decodeObjectForKey("animalPositions") as! NSData
        let pointer = UnsafePointer<CGPoint>(data.bytes)
        let count = data.length / sizeof(CGPoint)
        let buffer = UnsafeBufferPointer<CGPoint>(start: pointer, count: count)
        animalPositions = [CGPoint](buffer)
        
        let descData: NSData = aDecoder.decodeObjectForKey("descArray") as! NSData
        let descPointer = UnsafePointer<OrderMessage>(descData.bytes)
        let descCount = descData.length / sizeof(OrderMessage)
        let descBuffer = UnsafeBufferPointer<OrderMessage>(start: descPointer, count: descCount)
        descArray = [OrderMessage](descBuffer)
    }
    
}
