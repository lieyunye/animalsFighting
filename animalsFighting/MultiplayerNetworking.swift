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
        print("matchStarted")
//        var data:NSData = "matchStarted".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        let message : Message = Message()
//        message._messageString = "matchStarted"
//        message._messageType = MessageType.MessageTypeGameBegin
//        message.sourcePosition = CGPoint(x: 1,y: 1)
//        message.destinationPosition = CGPoint(x: 2, y: 2)
        sendData(message)
    }
    
    func matchEnded()
    {
        print("matchEnded")
        _delegate.matchEnded()
    }
    
    func matchDidReceiveDataFromPlayer(match:GKMatch,data:NSData,playerID:String)
    {
        print("data:\(data)")
//        var string:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        var message : Message = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Message

        _delegate.matchDidReceiveDataFromPlayer(match, data: data, playerID: playerID)
    }
    
    func sendData(message:Message)
    {
        var error:NSError?
//        var data = NSData(bytes: &message, length: sizeof(Message))
        let data = NSKeyedArchiver.archivedDataWithRootObject(message)
        let success: Bool
        do {
            try GameKitHelper.sharedInstance.match.sendDataToAllPlayers(data, withDataMode: GKMatchSendDataMode.Reliable)
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        if error != nil || !success {
            print("\n[Easy Game Center] Fail sending data all Player\n")
        }else {
            print("\n[Easy Game Center] Succes sending data all Player \n")
        }
    }
}