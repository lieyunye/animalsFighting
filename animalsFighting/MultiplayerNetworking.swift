//
//  MultiplayerNetworking.swift
//  animalsFighting
//
//  Created by lieyunye on 7/13/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import Foundation
import UIKit
import GameKit
import MultipeerConnectivity





protocol MultiplayerNetworkingDelegate
{
    func matchEnded()
    func matchDidReceiveDataFromPlayer(match:GKMatch,data:NSData,playerID:String)

}

class MultiplayerNetworking:GameKitHelperDelegate{
        
    var _delegate:MultiplayerNetworkingDelegate!

    func matchStarted()
    {
        println("matchStarted")
//        var data:NSData = "matchStarted".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        var message : Message = Message()
        message._messageString = "matchStarted"
        message._messageType = MessageType.MessageTypeGameBegin
        message.sourcePosition = CGPoint(x: 1,y: 1)
        message.destinationPosition = CGPoint(x: 2, y: 2)
        sendData(message)
    }
    
    func matchEnded()
    {
        println("matchEnded")
        _delegate.matchEnded()
    }
    
    func matchDidReceiveDataFromPlayer(match:GKMatch,data:NSData,playerID:String)
    {
        println("data:\(data)")
//        var string:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        var message : Message = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Message

        _delegate.matchDidReceiveDataFromPlayer(match, data: data, playerID: playerID)
    }
    
    func sendData(var message:Message)
    {
        var error:NSError?
//        var data = NSData(bytes: &message, length: sizeof(Message))
        var data = NSKeyedArchiver.archivedDataWithRootObject(message)
        let success = GameKitHelper.sharedInstance.match.sendDataToAllPlayers(data, withDataMode: GKMatchSendDataMode.Reliable, error: &error)
        if error != nil || !success {
            println("\n[Easy Game Center] Fail sending data all Player\n")
        }else {
            println("\n[Easy Game Center] Succes sending data all Player \n")
        }
    }
}