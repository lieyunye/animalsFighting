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

class StartGameScene: SKScene {
    
    var _delegate:StartGameSceneDelegate?
    
    var mcManager:MCManager?
    
    var gameScene:GameScene?
    
    var isConnected : Bool = false
    
    var indicator:UIActivityIndicatorView?
    
    let connectStateLabel = SKLabelNode(fontNamed:"Chalkduster")
    
    override func didMoveToView(view: SKView) {
        
        mcManager = MCManager.sharedInstance
        mcManager!.delegate = self
        
        connectStateLabel.fontSize = 25;
        connectStateLabel.fontColor = SKColor.whiteColor()
        connectStateLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        connectStateLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        connectStateLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        indicator?.center = self.view!.center
        self.view?.addSubview(indicator!)
        self.view?.bringSubviewToFront(indicator!)
        
        let tap2Create:SKSpriteNode = SKSpriteNode(imageNamed: TAPSTRING.TapToCreate.rawValue)
        tap2Create.name = TAPSTRING.TapToCreate.rawValue
        self.addChild(tap2Create)
        tap2Create.position = CGPointMake(CGRectGetMidX(self.frame)/2.0, CGRectGetMidY(self.frame))
        
        let tap2Start:SKSpriteNode = SKSpriteNode(imageNamed: TAPSTRING.TapToStart.rawValue)
        self.addChild(tap2Start)
        tap2Start.name = TAPSTRING.TapToStart.rawValue
        tap2Start.position = CGPointMake(CGRectGetMidX(self.frame) + CGRectGetMidX(self.frame)/2, CGRectGetMidY(self.frame))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAuthenticationViewController", name: PresentAuthenticationViewController, object: nil)
        
        //        GameKitHelper.sharedInstance.authenticateLocalPlayer()
        
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
                    print("gamescene is nil")
                }
            default :
                print("点在石头上了！！！")
            }
        }
    }
    
    func createMapAndSyncPositions(){
        gameScene = GameScene()
        gameScene?.size = self.frame.size
        let animalSize:CGSize = CGSizeMake(gameScene!.frame.size.width/8.0, gameScene!.frame.size.height/5.0)
        gameScene?.makeAnimalPositions(animalSize)
        gameScene?.animalPositionsFromNet = shuffleArray(gameScene!.animalPositions)
        gameScene?.gameSceneDelegate = self
        syncPositions()
        
    }
    
    func syncPositions(){
        let message = Message()
        message.messageType = MessageType.MessageTypeGameBegin
        message.animalPositions = gameScene?.animalPositionsFromNet
        mcManager?.sendData(message)
    }
    
    
    func startGame(positions:[CGPoint]){
        gameScene = GameScene()
        gameScene?.size = self.frame.size
        gameScene?.campSignType = CampSignType.CampSignTypeBlue
        gameScene?.animalPositionsFromNet = positions
        gameScene?.gameSceneDelegate = self
    }
    
    func push2Game(){
        let reveal:SKTransition = SKTransition.doorsOpenHorizontalWithDuration(1)
        self.view?.presentScene(gameScene!, transition: reveal)
    }
    
    func showAuthenticationViewController(){
        let gameKitHelper:GameKitHelper = GameKitHelper.sharedInstance
        gameKitHelper._multiplayerNetworking._delegate = self
        let vc:UIViewController! = self.view?.window?.rootViewController
        vc.presentViewController(gameKitHelper.authenticationViewController, animated: true) { () -> Void in
            
        }
    }
    
    func shuffleArray<T>(var array: Array<T>) -> Array<T>
    {
        for var index = array.count - 1; index > 0; index--
        {
            // Random int from 0 to index-1
            let j = Int(arc4random_uniform(UInt32(index-1)))
            
            // Swap two array elements
            // Notice '&' required as swap uses 'inout' parameters
            swap(&array[index], &array[j])
        }
        return array
    }
    
    
}

//MARK: - MCManagerDelegate
extension StartGameScene : MCManagerDelegate {
    func connectedStateChanged(connectedState: String) {
        switch connectedState {
        case ConnectState.ConnectStateConnecting.rawValue:
            showTips("连接中...")
            indicator?.startAnimating()
        case ConnectState.ConnectStateConnected.rawValue:
            showTips("连接成功")
            indicator?.stopAnimating()
        case ConnectState.ConnectStateNotConnected.rawValue:
            showTips("未连接")
            indicator?.stopAnimating()
        default:
            showTips("未知错误")
            indicator?.stopAnimating()
        }
    }
    
    func showTips(string:String){
        connectStateLabel.removeFromParent()
        self.removeAllActions()
        connectStateLabel.text = string;
        self.addChild(connectStateLabel)
        let action:SKAction = SKAction.waitForDuration(1)
        self.runAction(action, completion: { () -> Void in
            self.connectStateLabel.removeFromParent()
        })
    }
    
    func didRecivedData(manager: MCManager, message: Message) {
        let type : MessageType = message.messageType!
        switch type {
        case .MessageTypeGameBegin:
            startGame(message.animalPositions)
            
        case .MessageTypeGameOver:
            LogHelper.sharedInstance.log.warning("MessageTypeGameOver")

            
        case .MessageTypeGamePlaying:
            let before: Int = gameScene!.recivedDescArray.count
            let after: Int = message.descArray.count
            
            LogHelper.sharedInstance.log.debug("before + \(before) + after + \(after)")
            
            if before > after {
                for var i: Int = before / 2; i < after; i++ {
                    let orderMessage: OrderMessage = message.descArray[i]
                    handleMessagePlaying(orderMessage)
                }
            }else {
                for var i: Int = before; i < after; i++ {
                    let orderMessage: OrderMessage = message.descArray[i]
                    handleMessagePlaying(orderMessage)
                }
            }
            
            gameScene?.recivedDescArray = message.descArray
        case .MessageTypeGameUnkonw:
            LogHelper.sharedInstance.log.warning("MessageTypeGameUnkonw")
            
        }
    }
    func handleMessagePlaying(orderMessage: OrderMessage) {
        let orderMessageType: OrderMessageType = orderMessage.orderMessageType
        switch  orderMessageType {
        case .OrderMessageTypeMove:
            NSLog("recived destinationPosition++++++++++++++++++++++%@", NSStringFromCGPoint(orderMessage.destinationPosition))
            gameScene?.didAnimalMove(orderMessage.destinationPosition, isFromNet: true)
        case .OrderMessageTypeTap:
            let orderMessageTapType: OrderMessageTapType = orderMessage.orderMessageTapType
            switch orderMessageTapType {
            case .OrderMessageTapType2Select:
                gameScene?.setSelectNodeWithPosition(orderMessage.tapPosition)
            case .OrderMessageTapType2Flip:
                NSLog("recieved orderMessage.tapPosition++++++++++++++++++++++%@", NSStringFromCGPoint(orderMessage.tapPosition))
                gameScene?.didRecievedFilpPosition(orderMessage.tapPosition)
            case .OrderMessageTapTypeUnkonw:
                LogHelper.sharedInstance.log.warning("OrderMessageTapTypeUnkonw")
                NSLog("OrderMessageTapTypeUnkonw")
            }
        case .OrderMessageTypeUnkonw:
            LogHelper.sharedInstance.log.warning("OrderMessageTypeUnkonw")
            NSLog("%@", "OrderMessageTypeUnkonw")
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
        let message : Message = Message()
        message.messageType = MessageType.MessageTypeGamePlaying
        var orderMessage: OrderMessage = OrderMessage()
        orderMessage.orderMessageType = OrderMessageType.OrderMessageTypeMove
        //        orderMessage.sourcePosition = selectNodePosition
        orderMessage.destinationPosition = CGPoint(x: CGFloat(destinationPosizition.x), y: CGFloat(destinationPosizition.y))
        NSLog("send destinationPosition++++++++++++++++++++++%@", NSStringFromCGPoint(orderMessage.destinationPosition))
        
        
        gameScene?.sendDescArray.append(orderMessage)
        if gameScene?.sendDescArray.count > 4 {
            var tempArray: [OrderMessage] = [OrderMessage]()
            let n: Int = gameScene!.sendDescArray.count
            for var i: Int = 2; i < n; i++ {
                tempArray.append(gameScene!.sendDescArray[i])
            }
            gameScene?.sendDescArray = tempArray
        }
        message.descArray = gameScene?.sendDescArray
        mcManager?.sendData(message)
    }
    
    func didTapOnSpriteNode(position: CGPoint, orderMessageTapType:OrderMessageTapType) {
        let message : Message = Message()
        message.messageType = MessageType.MessageTypeGamePlaying
        var orderMessage: OrderMessage = OrderMessage()
        orderMessage.orderMessageType = OrderMessageType.OrderMessageTypeTap
        orderMessage.orderMessageTapType = orderMessageTapType
        orderMessage.tapPosition = position
        NSLog("orderMessage.tapPosition++++++++++++++++++++++%@", NSStringFromCGPoint(orderMessage.tapPosition))
        gameScene?.sendDescArray.append(orderMessage)
        if gameScene?.sendDescArray.count > 4 {
            var tempArray: [OrderMessage] = [OrderMessage]()
            let n: Int = gameScene!.sendDescArray.count
            for var i: Int = 2; i < n; i++ {
                tempArray.append(gameScene!.sendDescArray[i])
            }
            gameScene?.sendDescArray = tempArray
        }
        message.descArray = gameScene?.sendDescArray
        LogHelper.sharedInstance.log.debug("orderMessageType + " + String(orderMessage.orderMessageType.rawValue))
        mcManager?.sendData(message)
    }
}