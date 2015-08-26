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

enum TAPSTRING : String {
    case TapToCreate = "TapToCreate"
    case TapToStart = "TapToStart"
}

class StartGameScene: SKScene, MultiplayerNetworkingDelegate, MCManagerDelegate, GameSceneDelegate {
    
    var _delegate:StartGameSceneDelegate?
    
    var mcManager:MCManager?
    
    var gameScene:GameScene?
    
    var isConnected : Bool = false
    
    override func didMoveToView(view: SKView) {
        
        mcManager = MCManager()
        mcManager!.delegate = self
        
        var tap2Create:SKSpriteNode = SKSpriteNode(imageNamed: TAPSTRING.TapToCreate.rawValue)
        tap2Create.name = TAPSTRING.TapToCreate.rawValue
        self.addChild(tap2Create)
        tap2Create.position = CGPointMake(CGRectGetMidX(self.frame)/2.0, CGRectGetMidY(self.frame))
        
        var tap2Start:SKSpriteNode = SKSpriteNode(imageNamed: TAPSTRING.TapToStart.rawValue)
        self.addChild(tap2Start)
        tap2Start.name = TAPSTRING.TapToStart.rawValue
        tap2Start.position = CGPointMake(CGRectGetMidX(self.frame) + CGRectGetMidX(self.frame)/2, CGRectGetMidY(self.frame))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAuthenticationViewController", name: PresentAuthenticationViewController, object: nil)
        
//        GameKitHelper.sharedInstance.authenticateLocalPlayer()
        
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touchedNode:SKNode?
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            touchedNode = self.nodeAtPoint(location)
        }
        if touchedNode is SKSpriteNode {
            let str : String = touchedNode!.name!
            switch str {
            case TAPSTRING.TapToCreate.rawValue :
                createMapAndSyncPositions()
                push2Game()
            case TAPSTRING.TapToStart.rawValue :
                if gameScene != nil {
                    push2Game()
                }else {
                    println("gamescene is nil")
                }
            default :
                println("点在石头上了！！！")
            }
        }
    }
    
    func createMapAndSyncPositions(){
        gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene
        let animalSize:CGSize = CGSizeMake(gameScene!.frame.size.width/8.0, gameScene!.frame.size.width/8.0)
        gameScene?.makeAnimalPositions(animalSize)
        gameScene?.animalPositionsFromNet = shuffleArray(gameScene!.animalPositions)
        gameScene?.gameSceneDelegate = self
        syncPositions()
    }
    
    func syncPositions(){
        let message = Message()
        message.messageType = MessageType.MessageTypeGameBegin
        message.messageString = "sss"
        message.animalPositions = gameScene?.animalPositionsFromNet
        mcManager?.sendData(message)
    }

    
    func startGame(positions:[CGPoint]){
        gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene
        let animalSize:CGSize = CGSizeMake(gameScene!.frame.size.width/8.0, gameScene!.frame.size.width/8.0)
        gameScene?.animalPositionsFromNet = positions
        gameScene?.gameSceneDelegate = self
    }
    
    func push2Game(){
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
    
    func shuffleArray<T>(var array: Array<T>) -> Array<T>
    {
        for var index = array.count - 1; index > 0; index--
        {
            // Random int from 0 to index-1
            var j = Int(arc4random_uniform(UInt32(index-1)))
            
            // Swap two array elements
            // Notice '&' required as swap uses 'inout' parameters
            swap(&array[index], &array[j])
        }
        return array
    }
    
    
}

//MARK: - MCManagerDelegate
extension StartGameScene : MCManagerDelegate {
    func connectedDevicesChanged(manager: MCManager, connectedDevices: [String]) {
        
    }
    
    func didRecivedData(manager: MCManager, message: Message) {
        let type : MessageType = message.messageType!
        switch type {
            case .MessageTypeGameBegin:
                let messageBegin:Message = message as Message
                startGame(messageBegin.animalPositions)
                break
            case .MessageTypeGameOver:
                let messageOver:Message = message as Message
                break
            case .MessageTypeGamePlaying:
                let messagePlaying:Message = message as Message
                gameScene?.setSelectNodeWithPosition(messagePlaying.sourcePosition)
                gameScene?.didAnimalMove(messagePlaying.destinationPosition, isFromNet: true)
                
                println("selectNodePosition+++++\(messagePlaying.sourcePosition)destinationPosizition++++++++\(messagePlaying.destinationPosition)")
                break
            case .MessageTypeGameFlip:
                let messagePlaying:Message = message as Message
                gameScene?.didRecievedFilpPosition(message.flipPosition)
                break
        }
        
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
        message.messageString = "move"
        message.messageType = MessageType.MessageTypeGamePlaying
        message.sourcePosition = selectNodePosition
        message.destinationPosition = destinationPosizition
        
        println("selectNodePosition+++++\(selectNodePosition)destinationPosizition++++++++\(destinationPosizition)")
        mcManager?.sendData(message)
    }
    
    func didTapOnSpriteNode(position: CGPoint) {
        var message : Message = Message()
        message.messageString = "flip"
        message.messageType = MessageType.MessageTypeGameFlip
        message.flipPosition = position
        mcManager?.sendData(message)
    }
}