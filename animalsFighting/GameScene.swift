//
//  GameScene.swift
//  animalsFighting
//
//  Created by lieyunye on 3/21/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import SpriteKit
import GameKit


struct PhysicsCategory {
    static let none           : UInt32 = 0x0
    static let redAnimal      : UInt32 = 0x1
    static let blueAnimal     : UInt32 = 0x10
}

enum CampSignType : String {
    case CampSignTypeRed = "CampSignTypeRed"
    case CampSignTypeBlue = "CampSignTypeBlue"
}

let blank:CGFloat = 0.0
let typeName:String = "animal"

protocol GameSceneDelegate {
    func didTapOnSpriteNode(position:CGPoint, orderMessageTapType:OrderMessageTapType)
    func didMoveItem(selectNodePosition:CGPoint, destinationPosizition:CGPoint)
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var animalsName:[String] = ["elephant","tiger","lion","leopard","wolf","dog","snake","rate"]
    var animalPositions = [CGPoint]()
    var animalPositionsFromNet = [CGPoint]()
    var selectedNode:AnimalSpriteNode!
    
    var waterSpriteNode:WaterSpriteNode!
    var campSignView:SKSpriteNode!
    var gameStarted:Bool = false
    
    var redBlood:Int = 16
    var blueBlood:Int = 16
    var gameOver:Bool = false
    
    var campLabel:SKLabelNode!
    
    var lastCategory:UInt32! = PhysicsCategory.none
    var currentCategory:UInt32! = PhysicsCategory.none

    var gameSceneDelegate:GameSceneDelegate?
    
    var sendDescArray: [OrderMessage]! = [OrderMessage]()
    var recivedDescArray: [OrderMessage]! = [OrderMessage]()
    
    var campSignType:CampSignType = CampSignType.CampSignTypeRed
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor.blackColor()
        
        let animalSize:CGSize = CGSizeMake(self.frame.size.width/8.0, self.frame.size.height/5.0)
        let waterSpriteSize:CGSize = CGSizeMake(self.frame.size.width, self.frame.size.height/5.0)
        makeWaterNode(waterSpriteSize)
        makeAnimalNodes(animalSize)
        
        if animalPositionsFromNet.count != 0 {
            animalPositions = animalPositionsFromNet
        }
        refreshAnimalsPostion()
        makeCampSignView()
        setCampSignTypeIdentifier()
    }
    
    //MARK: - SKPhysicsContactDelegate
    func didBeginContact(contact: SKPhysicsContact) {
        if gameStarted == false {
            print("game not start")
            return
        }
        print("Hit")
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if gameOver {
            return
        }
        if redBlood == 0 || blueBlood == 0{
            print("redBlood \(redBlood)", terminator: "")
            print("blueBlood \(blueBlood)", terminator: "")
            gameOver = true
            endGame()
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("GameScene touchesBegan")
        
        if MCManager.sharedInstance.connectState == ConnectState.ConnectStateConnected {
            gameStarted = true
            for touch: AnyObject in touches {
                if touch.tapCount == 1{
                    let location = touch.locationInNode(self)
                    selectNodeForTouch(location, isFromNet: false)
                    colorizeChoosenSpriteNodeWithColor(SKColor(red: 0.26, green: 0.69, blue: 0.78, alpha: 1), touchLocation: location)
                }else {
                    print("只支持单击")
                }
            }
        }else {
            LogHelper.sharedInstance.log.warning("网络未连接")
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if MCManager.sharedInstance.connectState == ConnectState.ConnectStateConnected {
            for touch: AnyObject in touches! {
                let location = touch.locationInNode(self)
                colorizeChoosenSpriteNodeWithColor(SKColor.clearColor(), touchLocation: location)
            }
        }else {
            LogHelper.sharedInstance.log.warning("网络未连接")
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if MCManager.sharedInstance.connectState == ConnectState.ConnectStateConnected {
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
                colorizeChoosenSpriteNodeWithColor(SKColor.clearColor(), touchLocation: location)
            }
        }else {
            LogHelper.sharedInstance.log.warning("网络未连接")
        }
    }
}

extension GameScene : AnimalSpriteNodeDelegate {
    // MARK: - AnimalSpriteNodeDelegate
    
    func didTapOnSpriteNode(animalSpriteNode: AnimalSpriteNode){
        if MCManager.sharedInstance.connectState == ConnectState.ConnectStateConnected {
            cancleSelectedSprite()
            animalSpriteNode.flip()
            self.gameSceneDelegate?.didTapOnSpriteNode(animalSpriteNode.position, orderMessageTapType: OrderMessageTapType.OrderMessageTapType2Flip)
        }else {
            LogHelper.sharedInstance.log.warning("网络未连接")
        }
    }
    
    func didRecievedFilpPosition(position:CGPoint){
        let animalPicSpriteNode : AnimalPicSpriteNode = self.nodeAtPoint(position) as! AnimalPicSpriteNode
        let animalSpriteNode:AnimalSpriteNode? = (animalPicSpriteNode.parent as! AnimalSpriteNode)
        if animalSpriteNode == nil {
            print("网络传输不合法的当前node坐标")
        }else {
            cancleSelectedSprite()
            animalSpriteNode!.flip()
        }
        
    }
}

extension GameScene {
    
    func makeAnimalPositions(animalSize:CGSize){
        for row in 0..<2 {
            for col in 0..<8 {
                let x:CGFloat = CGFloat(col)*animalSize.width + animalSize.width/2.0
                let y:CGFloat = CGFloat(row)*(animalSize.height + blank) + animalSize.height/2.0
                animalPositions.append(CGPointMake(x, y))
            }
        }
        
        for row in 0..<2 {
            for col in 0..<8 {
                let x:CGFloat = CGFloat(col)*animalSize.width + animalSize.width/2.0
                let y:CGFloat = (self.frame.size.height - (CGFloat(row)*(animalSize.height + blank) + animalSize.height/2.0))
                animalPositions.append(CGPointMake(x, y))
            }
        }
    }
    
    func makeAnimalNodes(animalSize:CGSize) {
        for row in 0..<2 {
            for col in 0..<8 {
                let texture:SKTexture = SKTexture(imageNamed: animalsName[col])
                let redAnimalSprite = AnimalSpriteNode(texture: texture,size: animalSize)
                redAnimalSprite.delegate = self
                redAnimalSprite.power = 7-col
                redAnimalSprite.physicsBody?.categoryBitMask = PhysicsCategory.redAnimal
                redAnimalSprite.physicsBody?.contactTestBitMask = PhysicsCategory.blueAnimal
                redAnimalSprite.physicsBody?.collisionBitMask = PhysicsCategory.none
                redAnimalSprite.physicsBody?.dynamic = true
                redAnimalSprite.physicsBody?.affectedByGravity = false
                redAnimalSprite.name = typeName
                redAnimalSprite.animalname = animalsName[col] + "-" + CampSignType.CampSignTypeRed.rawValue + "-" + "\(row)"
                self.addChild(redAnimalSprite)
            }
        }
        
        for row in 0..<2 {
            for col in 0..<8 {
                let nameString:String = animalsName[col] + "-1"
                let blueAnimalSprite = AnimalSpriteNode(texture: SKTexture(imageNamed: nameString),size: animalSize)
                blueAnimalSprite.delegate = self
                blueAnimalSprite.power = 7-col
                blueAnimalSprite.physicsBody?.categoryBitMask = PhysicsCategory.blueAnimal
                blueAnimalSprite.physicsBody?.contactTestBitMask = PhysicsCategory.redAnimal
                blueAnimalSprite.physicsBody?.collisionBitMask = PhysicsCategory.none
                blueAnimalSprite.physicsBody?.dynamic = true
                blueAnimalSprite.physicsBody?.affectedByGravity = false
                blueAnimalSprite.name = typeName
                blueAnimalSprite.animalname = animalsName[col] + "-" + CampSignType.CampSignTypeBlue.rawValue + "-" + "\(row)"
                self.addChild(blueAnimalSprite)
            }
        }
    }
    
    
    func refreshAnimalsPostion() {
        var index:Int = 0
        enumerateChildNodesWithName(typeName, usingBlock: { (node: SKNode, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            node.position = self.animalPositions[index]
            index++
        })
    }
    
    func makeWaterNode(waterSpriteSize:CGSize) {
        waterSpriteNode = WaterSpriteNode(texture: SKTexture(imageNamed: "water"), size: waterSpriteSize)
        waterSpriteNode.name = "water"
        waterSpriteNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(waterSpriteNode)
    }
    
    func makeCampSignView(){
        campSignView = SKSpriteNode(color: SKColor.redColor(), size: CGSizeMake(100, 50))
        campSignView.position = CGPointMake(CGRectGetWidth(waterSpriteNode.frame)-50, CGRectGetMidY(waterSpriteNode.frame))
        self.addChild(campSignView)
    }
    
    func setCampSignTypeIdentifier() {
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.fontSize = 25;
        myLabel.fontColor = SKColor.whiteColor()
        myLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        myLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        myLabel.position = CGPointMake(70, CGRectGetMidY(waterSpriteNode.frame))
        if campSignType == CampSignType.CampSignTypeRed {
            myLabel.text = "对方执白棋";
        }else {
            myLabel.text = "对方执绿棋";
        }
        self.addChild(myLabel)
    }
    
    // MARK: - Help method
    
    func degToRad(degree:CGFloat) -> CGFloat{
        return degree / CGFloat(180.0) * CGFloat(M_PI)
    }

    func endGame() {
        let startGameScene:StartGameScene = StartGameScene()
        startGameScene.size = self.frame.size
        let reveal:SKTransition = SKTransition.doorsCloseHorizontalWithDuration(1)
        self.view?.presentScene(startGameScene, transition: reveal)
    }
    
    func showTips(){
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "轮到对方啦";
        myLabel.fontSize = 65;
        myLabel.fontColor = SKColor.whiteColor()
        myLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        myLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel)
        let action:SKAction = SKAction.waitForDuration(1)
        self.runAction(action, completion: { () -> Void in
            myLabel.removeFromParent()
        })
    }
    
    func colorizeChoosenSpriteNodeWithColor(color:SKColor,touchLocation:CGPoint){
        if selectedNode != nil {
            let touchedNode:SKNode = self.nodeAtPoint(touchLocation)
            var nodeObject:AnimalSpriteNode!
            let condition:Bool = touchedNode.isKindOfClass(WaterSpriteNode)
            if condition == false{
                nodeObject = touchedNode.parent as? AnimalSpriteNode
            }
            if nodeObject != nil && selectedNode == nodeObject {
                let changeColorAction:SKAction = SKAction.colorizeWithColor(color, colorBlendFactor: 1.0, duration: 0.2)
                let selectAction:SKAction = SKAction.sequence([changeColorAction])
                selectedNode.runAction(selectAction, completion: { () -> Void in
                    self.selectedNode.color = color
                })
            }
        }
    }
    
    // MARK: - Game method
    
    func setSelectNodeWithPosition(position:CGPoint) {
        let animalPicSpriteNode : AnimalPicSpriteNode = self.nodeAtPoint(position) as! AnimalPicSpriteNode
        let selectedNodeFromNet:AnimalSpriteNode = animalPicSpriteNode.parent as! AnimalSpriteNode
        changeSelectedSprite(selectedNodeFromNet, isFromNet: true)
    }
    
    func selectNodeForTouch(touchLocation:CGPoint, isFromNet:Bool){
        
        let touchedNode:SKNode = self.nodeAtPoint(touchLocation)
        
        var nodeObject:AnimalSpriteNode!
        
        let condition1:Bool = touchedNode.isKindOfClass(WaterSpriteNode)
        let condition2:Bool = selectedNode != nil
        if condition1 == false{
            nodeObject = touchedNode.parent as? AnimalSpriteNode
        }
        
        if (condition2){
            if selectedNode.isEqual(nodeObject){
                print("点击了当前已选中的精灵")
                return
            }
            
            if (selectedNode.power == 0) {
                print("老鼠相关")
                if nodeObject != nil && selectedNode.physicsBody?.categoryBitMask == nodeObject.physicsBody?.categoryBitMask {
                    changeSelectedSprite(nodeObject, isFromNet: isFromNet)
                }else if waterSpriteNode.frame.contains(selectedNode.position) && waterSpriteNode.frame.contains(touchLocation) == false{
                    ratesMoveFromWaterToShore(touchLocation)
                }else if (waterSpriteNode.frame.contains(selectedNode.position) && waterSpriteNode.frame.contains(touchLocation)){
                    ratesMoveInWater(touchLocation)
                }else if (waterSpriteNode.frame.contains(selectedNode.position) == false && waterSpriteNode.frame.contains(touchLocation)) {
                    ratesMoveFromShoreToWater(nodeObject,touchLocation: touchLocation)
                }else {
                    moveAndFight(touchLocation)
                }
            }else {
                if (waterSpriteNode.containsPoint(touchLocation)) {
                    print("其他动物不可进河")
                    return
                }
                print("点击另一精灵")
                if nodeObject != nil && selectedNode.physicsBody?.categoryBitMask == nodeObject.physicsBody?.categoryBitMask {
                    changeSelectedSprite(nodeObject, isFromNet: isFromNet)
                }else {
                    moveAndFight(touchLocation)
                }
            }
        }else {
            changeSelectedSprite(nodeObject, isFromNet: isFromNet)
        }
    }
    
    func ratesMoveFromWaterToShore(touchLocation:CGPoint){
        var destinationPosizition:CGPoint = touchLocation
        if touchLocation.y > selectedNode.position.y && touchLocation.y > waterSpriteNode.size.height + waterSpriteNode.frame.origin.y{
            print("上游岸")
            
            destinationPosizition.x = (CGFloat(Int(touchLocation.x / selectedNode.size.width))) * selectedNode.size.width + selectedNode.size.width/2.0
            destinationPosizition.y = waterSpriteNode.frame.origin.y + waterSpriteNode.size.height + selectedNode.size.height/2.0
        }else if touchLocation.y < selectedNode.position.y && touchLocation.y < waterSpriteNode.frame.origin.y{
            print("下游岸")
            
            destinationPosizition.x = (CGFloat(Int(touchLocation.x / selectedNode.size.width))) * selectedNode.size.width + selectedNode.size.width/2.0
            destinationPosizition.y = waterSpriteNode.frame.origin.y - selectedNode.size.height/2.0
            
        }
        didAnimalMove(destinationPosizition, isFromNet: false)
    }
    
    func ratesMoveInWater(touchLocation:CGPoint){
        var destinationPosizition:CGPoint = touchLocation
        destinationPosizition =  bestDestinationInWater(touchLocation)
        didAnimalMove(destinationPosizition, isFromNet: false)
    }
    
    func bestDestinationInWater(touchLocation:CGPoint) -> CGPoint{
        
        var destinationPosizition:CGPoint = touchLocation
        
        if touchLocation.y + selectedNode.size.height/2 < waterSpriteNode.size.height + waterSpriteNode.frame.origin.y && touchLocation.y - selectedNode.size.height/2 > waterSpriteNode.frame.origin.y && touchLocation.x - selectedNode.size.height/2 > 0 && touchLocation.x + selectedNode.size.width/2 < waterSpriteNode.size.width{
            print("good position")
        }else {
            if touchLocation.x - selectedNode.size.width < 0 {
                destinationPosizition.x = selectedNode.size.width/2.0
            }
            if touchLocation.x + selectedNode.size.width > waterSpriteNode.size.width {
                destinationPosizition.x = waterSpriteNode.size.width - selectedNode.size.width/2.0
            }
            if touchLocation.y - selectedNode.size.height < waterSpriteNode.frame.origin.y {
                destinationPosizition.y = waterSpriteNode.frame.origin.y + selectedNode.size.height/2.0
            }
            if touchLocation.y + selectedNode.size.height > waterSpriteNode.frame.origin.y + waterSpriteNode.size.height{
                destinationPosizition.y = waterSpriteNode.frame.origin.y + waterSpriteNode.size.height - selectedNode.size.height/2.0
            }
        }
        
        return destinationPosizition
    }
    
    func ratesMoveFromShoreToWater(nodeObject:AnimalSpriteNode!,touchLocation:CGPoint){
        //老鼠进河
        let destinationPosition:CGPoint = bestDestinationInWater(touchLocation)
        if touchLocation.y > selectedNode.position.y {
            //下岸入河
            if waterSpriteNode.frame.contains(CGPointMake(selectedNode.position.x, selectedNode.position.y+selectedNode.size.height)){
                print("老鼠在岸边")
                didAnimalMove(destinationPosition,isFromNet: false)
            }else {
                moveAndFight(touchLocation)
            }
        }
        if touchLocation.y < selectedNode.position.y {
            //上岸入河
            if waterSpriteNode.frame.contains(CGPointMake(selectedNode.position.x, selectedNode.position.y-selectedNode.size.height)){
                didAnimalMove(destinationPosition, isFromNet: false)
                print("老鼠在岸边")
            }else {
                moveAndFight(touchLocation)
            }
        }
    }
    
    func moveAndFight(touchLocation:CGPoint){
        let xTouchOffset:CGFloat = touchLocation.x - selectedNode.position.x
        let yTouchOffset:CGFloat = touchLocation.y - selectedNode.position.y
        
        if fabs(xTouchOffset) - selectedNode.size.width/2.0 < 0 && fabs(yTouchOffset) - selectedNode.size.width/2.0 < 0 {
            print("移动距离上下左右不够一格")
            return;
        }
        
        if fabs(xTouchOffset) - selectedNode.size.width/2.0 > 0 && fabs(yTouchOffset) - selectedNode.size.width/2.0 > 0 {
            if waterSpriteNode.frame.contains(selectedNode.position) == false{
                print("不能对角线移动")
                return;
            }
        }
        
        if xTouchOffset > 0 && fabs(xTouchOffset) > fabs(yTouchOffset){
            print("right")
            let destinationPosizition:CGPoint = CGPointMake(selectedNode.position.x + selectedNode.size.width, selectedNode.position.y)
            
            didAnimalMove(destinationPosizition, isFromNet: false)
            
            return
            
        }
        
        if xTouchOffset < 0 && fabs(xTouchOffset) > fabs(yTouchOffset){
            print("left")
            let destinationPosizition:CGPoint = CGPointMake(selectedNode.position.x - selectedNode.size.width, selectedNode.position.y)
            didAnimalMove(destinationPosizition, isFromNet: false)
            return
        }
        if yTouchOffset > 0 && fabs(yTouchOffset) > fabs(xTouchOffset){
            print("up")
            var destinationPosizition:CGPoint = CGPointZero
            
            destinationPosizition = CGPointMake(selectedNode.position.x, selectedNode.position.y + selectedNode.size.width)
            if touchLocation.y - selectedNode.position.y > waterSpriteNode.frame.size.height + selectedNode.size.height/2 {
                let destinationPosizitionY = selectedNode.position.y + selectedNode.size.width + waterSpriteNode.frame.size.height
                destinationPosizition = CGPointMake(selectedNode.position.x, destinationPosizitionY)
            }
            
            let touchedNode1:SKNode! = self.nodeAtPoint(destinationPosizition)
            if touchedNode1 is WaterSpriteNode {
                destinationPosizition = CGPointMake(selectedNode.position.x, selectedNode.position.y + selectedNode.size.width)
            }
            print("\(destinationPosizition)")
            didAnimalMove(destinationPosizition, isFromNet: false)
            return
        }
        
        if yTouchOffset < 0 && fabs(yTouchOffset) > fabs(xTouchOffset){
            print("down")
            var destinationPosizition:CGPoint = CGPointZero
            
            destinationPosizition = CGPointMake(selectedNode.position.x, selectedNode.position.y - selectedNode.size.width)
            if fabs(touchLocation.y - selectedNode.position.y) > waterSpriteNode.frame.size.height + selectedNode.size.height/2 {
                let destinationPosizitionY = selectedNode.position.y - selectedNode.size.width - waterSpriteNode.frame.size.height
                destinationPosizition = CGPointMake(selectedNode.position.x, destinationPosizitionY)
            }
            let touchedNode1:SKNode! = self.nodeAtPoint(destinationPosizition)
            if touchedNode1 is WaterSpriteNode {
                destinationPosizition = CGPointMake(selectedNode.position.x, selectedNode.position.y - selectedNode.size.width)
            }
            print("\(destinationPosizition)")
            didAnimalMove(destinationPosizition, isFromNet: false)
            return
        }
    }
    
    func changeSelectedSprite(nodeObject:AnimalSpriteNode!, isFromNet:Bool){
        if nodeObject != nil {
            currentCategory = nodeObject.physicsBody?.categoryBitMask
            if lastCategory == currentCategory {
                print("轮到对方啦")
                showTips()
                return
            }
            print("同一阵营")
            cancleSelectedSprite()
            selectedNode = nodeObject
            let sequence:SKAction = SKAction.sequence([SKAction.rotateByAngle(degToRad(-4.0), duration: 0.1),SKAction.rotateByAngle(0.0, duration: 0.1),SKAction.rotateByAngle(degToRad(4.0), duration: 0.1)])
            selectedNode.runAction(SKAction.repeatActionForever(sequence))
            if isFromNet == false {
                gameSceneDelegate?.didTapOnSpriteNode(selectedNode.position, orderMessageTapType: OrderMessageTapType.OrderMessageTapType2Select)
            }
        }
    }
    
    func cancleSelectedSprite(){
        if selectedNode != nil {
            selectedNode.removeAllActions()
            selectedNode.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
            selectedNode = nil;
        }
    }
    
    func didAnimalMove(var destinationPosizition:CGPoint, isFromNet:Bool){
        
        LogHelper.sharedInstance.log.debug("didAnimalMove")
        
        var touchedNode1:SKNode! = self.nodeAtPoint(destinationPosizition)
        if touchedNode1.parent is AnimalSpriteNode {
            destinationPosizition = touchedNode1.parent!.position
            touchedNode1 = touchedNode1.parent
        }
        if touchedNode1 is WaterSpriteNode {
            
            print("touchedNode1 is WaterSpriteNode")
        }
        
        let condition0:Bool = touchedNode1 is WaterSpriteNode
        let condition1:Bool = (touchedNode1 == nil)
        let condition2:Bool = (touchedNode1 is SKScene)
        var condition3:Bool = (condition0 == false && condition2 == false && touchedNode1 is AnimalSpriteNode && selectedNode.physicsBody?.categoryBitMask != touchedNode1.physicsBody?.categoryBitMask && ((selectedNode.power >= (touchedNode1 as! AnimalSpriteNode).power)))
        if condition0 == false && condition2 == false && selectedNode.power == 7 && (touchedNode1 as! AnimalSpriteNode).power == 0 {
            condition3 = false
        }
        let condition4:Bool = (condition0 == false && condition2 == false && selectedNode.power == 0 && (touchedNode1 as! AnimalSpriteNode).power == 7)
        
        if (condition0 || condition1 || condition2 || condition3 || condition4) {
            let moveAction:SKAction = SKAction.moveTo(destinationPosizition, duration:0.3)
            let doneAction:SKAction = SKAction.runBlock({ () -> Void in
                if touchedNode1 != nil{
                    self.lastCategory = self.selectedNode.physicsBody?.categoryBitMask
                    if touchedNode1 is WaterSpriteNode {
                        
                        if self.campSignView.color == SKColor.redColor(){
                            self.campSignView.color = SKColor.blueColor()
                        }else {
                            self.campSignView.color = SKColor.redColor()
                        }
                        
                    }else {
                        if touchedNode1 is AnimalSpriteNode && (touchedNode1 as! AnimalSpriteNode).physicsBody?.categoryBitMask == PhysicsCategory.redAnimal {
                            self.redBlood -= 1
                            self.campSignView.color = SKColor.redColor()
                            touchedNode1.removeFromParent()
                        }else if touchedNode1 is AnimalSpriteNode && (touchedNode1 as! AnimalSpriteNode).physicsBody?.categoryBitMask == PhysicsCategory.blueAnimal {
                            self.blueBlood -= 1
                            self.campSignView.color = SKColor.blueColor()
                            touchedNode1.removeFromParent()
                        }else {
                            if self.campSignView.color == SKColor.redColor(){
                                self.campSignView.color = SKColor.blueColor()
                            }else {
                                self.campSignView.color = SKColor.redColor()
                            }
                        }
                    }
                }
                self.cancleSelectedSprite()
            })
            if isFromNet == false {
                self.gameSceneDelegate?.didMoveItem(self.selectedNode.position, destinationPosizition: destinationPosizition)
            }
            let sequence:SKAction = SKAction.sequence([moveAction,doneAction])
            selectedNode.runAction(sequence)
            
        }
    }
}


