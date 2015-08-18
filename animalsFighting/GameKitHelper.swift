//
//  GameKitHelper.swift
//  animalsFighting
//
//  Created by lieyunye on 5/21/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import GameKit

protocol GameKitHelperDelegate
{
    func matchStarted()
    func matchEnded()
    func matchDidReceiveDataFromPlayer(match:GKMatch,data:NSData,playerID:String)
}

let PresentAuthenticationViewController:String = "present_authentication_view_controller"
let LocalPlayerIsAuthenticated:String = "local_player_authenticated"

class GameKitHelper:NSObject,GKMatchmakerViewControllerDelegate, GKMatchDelegate{
    
    var match:GKMatch!
    var playersDict:Dictionary<String,GKPlayer>!
    var _matchStarted:Bool = false

    var _multiplayerNetworking:MultiplayerNetworking = MultiplayerNetworking()
    
    var delegate:GameKitHelperDelegate!

    
    var authenticationViewController:(UIViewController)!{
        willSet{
            if newValue != nil {
                self.authenticationViewController = newValue
                NSNotificationCenter.defaultCenter().postNotificationName(PresentAuthenticationViewController, object: self)
            }
        }
    }
    var lastError:NSError!{
        willSet{
            if newValue != nil {
                self.lastError = newValue
                print("GameKitHelper ERROR: \(self.lastError.userInfo?.description)")
            }
        }
    }
    var _enableGameCenter:Bool = true
    
    
    class var sharedInstance : GameKitHelper {
        struct Static {
            static let instance : GameKitHelper = GameKitHelper()
        }
        return Static.instance
    }
    
    func authenticateLocalPlayer(){
        var localPlayer:GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        if(localPlayer.authenticated){
            NSNotificationCenter.defaultCenter().postNotificationName(LocalPlayerIsAuthenticated, object: nil)
        }
        
        localPlayer.authenticateHandler = {(viewController:UIViewController!, error:NSError!) -> Void in
            //3
            self.lastError = error
            
            if(viewController != nil) {
                //4
                self.authenticationViewController = viewController
            } else if(localPlayer.authenticated) {
                //5
                self._enableGameCenter = true;
                NSNotificationCenter.defaultCenter().postNotificationName(LocalPlayerIsAuthenticated, object: nil)
            } else {
                //6
                self._enableGameCenter = false
                ;
            }
        }
    }
    
    func lookupPlayers(){
        print("Looking up \(match.playerIDs.count)")
        GKPlayer.loadPlayersForIdentifiers(match.playerIDs, withCompletionHandler: { (players, error) -> Void in
            if error != nil {
                print("Error retrieving player info:\(error.localizedDescription)")
                self._matchStarted = false
                self.delegate.matchEnded()
            }else {
                self.playersDict = Dictionary<String,GKPlayer>()
                for player in players {
                    self.playersDict[player.playerID]=player as? GKPlayer
                }
                self.playersDict[GKLocalPlayer.localPlayer().playerID] = GKLocalPlayer.localPlayer()
                self._matchStarted = true;
                self.delegate.matchStarted()
            }
        })
    }
    
    func findMatchWithMinPlayers(minPlayers:Int, maxPlayers:Int, viewController:UIViewController){
        
        if(!_enableGameCenter){
            return
        }
        _matchStarted = false
        self.match = nil
        
        self.delegate = _multiplayerNetworking
        
        viewController.dismissViewControllerAnimated(false, completion: nil);
        var request:GKMatchRequest = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        
        var mmvc:GKMatchmakerViewController = GKMatchmakerViewController(matchRequest: request)
        mmvc.matchmakerDelegate = self
        viewController.presentViewController(mmvc, animated: true, completion: nil)
    }

    
    // MARK: - GKMatchmakerViewControllerDelegate
    
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController!){
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFailWithError error: NSError!){
        viewController.dismissViewControllerAnimated(true, completion: nil)
        print("Error finding match: \(error.localizedDescription)")
    }
    
    // A peer-to-peer match has been found, the game should start
    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFindMatch match: GKMatch!){
        viewController.dismissViewControllerAnimated(true, completion: nil)
        self.match = match
        match.delegate = self
        if !_matchStarted && match.expectedPlayerCount == 0{
            lookupPlayers()
        }
    }
    
    // MARK: - GKMatchDelegate
    
    func match(match: GKMatch!, didReceiveData data: NSData!, fromPlayer playerID: String!){
        if (self.match != match) {
          return
        }
        self.delegate.matchDidReceiveDataFromPlayer(match, data: data, playerID: playerID)
    }

    func match(match: GKMatch!, player playerID: String!, didChangeState state: GKPlayerConnectionState){
        if (self.match != match) {
            return
        }
        
        switch state {
        case .StateUnknown:
            println("StateUnknown")
        case .StateConnected:
            println("StateConnected")
            if !_matchStarted && match.expectedPlayerCount == 0{
                lookupPlayers()
            }

        case .StateDisconnected:
            println("StateDisconnected")
            _matchStarted = false
            delegate.matchEnded()
        
        }
    }
    
    func match(match: GKMatch!, didFailWithError error: NSError!)
    {
        if (self.match != match) {
            return
        }
        println("Match failed with error:\(error.localizedDescription)")
        _matchStarted = false
        delegate.matchEnded()
        
        
    }
}