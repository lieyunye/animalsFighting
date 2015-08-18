//
//  StartGameScene.swift
//  animalsFighting
//
//  Created by lieyunye on 4/11/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import SpriteKit
import GameKit

protocol StartGameSceneDelegate
{
    func didRecivedData()
    func matchDidReceiveDataFromPlayer(match:GKMatch,data:NSData,playerID:String)

}

class StartGameScene: SKScene, MultiplayerNetworkingDelegate, MCManagerDelegate, GameSceneDelegate {
    
    var _delegate:StartGameSceneDelegate?
    
    var mcManager:MCManager?
    
    var gameScene:GameScene?
    
    override func didMoveToView(view: SKView) {
        
        mcManager = MCManager()
        mcManager!.delegate = self
        
        var tap2Start:SKSpriteNode = SKSpriteNode(imageNamed: "TapToStart")
        self.addChild(tap2Start)
        tap2Start.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAuthenticationViewController", name: PresentAuthenticationViewController, object: nil)
        
//        GameKitHelper.sharedInstance.authenticateLocalPlayer()
        
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        startGame()

    }
    
    func startGame(){
        gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene
        gameScene?.gameSceneDelegate = self
        _delegate = gameScene
        var reveal:SKTransition = SKTransition.doorsOpenHorizontalWithDuration(1)
        self.view?.presentScene(gameScene, transition: reveal)
    }
    
    func showAuthenticationViewController(){
        var gameKitHelper:GameKitHelper = GameKitHelper.sharedInstance
        gameKitHelper._multiplayerNetworking._delegate = self
        var vc:UIViewController! = self.view?.window?.rootViewController
        vc.presentViewController(gameKitHelper.authenticationViewController, animated: true) { () -> Void in
            
        }

    }
    
    
}

//MARK: - MCManagerDelegate
extension StartGameScene : MCManagerDelegate {
    func connectedDevicesChanged(manager: MCManager, connectedDevices: [String]) {
        
    }
    
    func didRecivedData(manager: MCManager, message: Message) {
        gameScene?.setSelectNodeWithPosition(message.sourcePosition)
        gameScene?.didAnimalMove(message.destinationPosition)
    }
}

//MARK: - MultiplayerNetworkingDelegate
extension StartGameScene : MultiplayerNetworkingDelegate {
    func matchEnded() {
        
    }
    
    func matchDidReceiveDataFromPlayer(match:GKMatch,data:NSData,playerID:String)
    {
        
    }
}

//MARK: - GameSceneDelegate
extension StartGameScene : GameSceneDelegate {
    func didMoveItem(selectNodePosition: CGPoint, destinationPosizition: CGPoint) {
        var message : Message = Message()
        message._messageString = "move"
        message._messageType = MessageType.MessageTypeGamePlaying
        message.sourcePosition = selectNodePosition
        message.destinationPosition = destinationPosizition
        mcManager?.sendData(message)
    }
}