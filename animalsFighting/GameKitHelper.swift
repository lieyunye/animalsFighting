//
//  GameKitHelper.swift
//  animalsFighting
//
//  Created by lieyunye on 5/21/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import GameKit

let PresentAuthenticationViewController:String = "present_authentication_view_controller"

class GameKitHelper{
    
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
        localPlayer.authenticateHandler = {(viewController:UIViewController!, error:NSError!) -> Void in
            //3
            self.lastError = error
            
            if(viewController != nil) {
                //4
                self.authenticationViewController = viewController
            } else if(localPlayer.authenticated) {
                //5
                self._enableGameCenter = true;
            } else {
                //6
                self._enableGameCenter = false
                ;
            }
        }
    }
}