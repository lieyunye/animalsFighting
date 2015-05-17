//
//  GameScene.swift
//  animalsFighting
//
//  Created by lieyunye on 3/21/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let none           : UInt32 = 0x0
    static let redAnimal      : UInt32 = 0x1
    static let blueAnimal     : UInt32 = 0x10
}

let blank:CGFloat = 0.0
let typeName:String = "animal"

class GameScene: SKScene,SKPhysicsContactDelegate,AnimalSpriteNodeDelegate
{
    var animalsName:[String] = ["elephant","tiger","lion","leopard","wolf","dog","snake","rate"]
    var animalsBackgroundColors = [UIColor]()
    var animalNodes = [AnimalSpriteNode]()
    var animalPositions = [CGPoint]()
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

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let animalSize:CGSize = CGSizeMake(self.frame.size.width/8.0, self.frame.size.width/8.0)
        physicsWorld.contactDelegate = self
        
        
        self.backgroundColor = UIColor.blackColor()
        
        let waterSpriteSize:CGSize = CGSizeMake(self.frame.size.width, self.frame.size.height - (animalSize.height * 4 + blank * 2))
        makeWaterNode(waterSpriteSize)
        
        for item in 0..<8 {
            animalsBackgroundColors.append(getRandomColor())
        }
        for row in 0..<2 {
            for col in 0..<8 {
                var texture:SKTexture = SKTexture(imageNamed: animalsName[col])
                let redAnimalSprite = AnimalSpriteNode(texture: texture,size: animalSize)
                redAnimalSprite.delegate = self
                redAnimalSprite.power = 7-col
                redAnimalSprite.physicsBody?.categoryBitMask = PhysicsCategory.redAnimal
                redAnimalSprite.physicsBody?.contactTestBitMask = PhysicsCategory.blueAnimal
                redAnimalSprite.physicsBody?.collisionBitMask = PhysicsCategory.none
                redAnimalSprite.physicsBody?.dynamic = true
                redAnimalSprite.physicsBody?.affectedByGravity = false
                redAnimalSprite.name = typeName
                var x:CGFloat = CGFloat(col)*animalSize.width + animalSize.width/2.0
                var y:CGFloat = CGFloat(row)*(animalSize.height + blank) + animalSize.height/2.0
                animalPositions.append(CGPointMake(x, y))
                self.addChild(redAnimalSprite)
            }
        }
        
        for row in 0..<2 {
            for col in 0..<8 {
                var nameString:String = animalsName[col] + "-1"
                let blueAnimalSprite = AnimalSpriteNode(texture: SKTexture(imageNamed: nameString),size: animalSize)
                blueAnimalSprite.delegate = self
                blueAnimalSprite.power = 7-col
                blueAnimalSprite.physicsBody?.categoryBitMask = PhysicsCategory.blueAnimal
                blueAnimalSprite.physicsBody?.contactTestBitMask = PhysicsCategory.redAnimal
                blueAnimalSprite.physicsBody?.collisionBitMask = PhysicsCategory.none
                blueAnimalSprite.physicsBody?.dynamic = true
                blueAnimalSprite.physicsBody?.affectedByGravity = false
                blueAnimalSprite.name = typeName
                
                var x:CGFloat = CGFloat(col)*animalSize.width + animalSize.width/2.0
                var y:CGFloat = (self.frame.size.height - (CGFloat(row)*(animalSize.height + blank) + animalSize.height/2.0))
                animalPositions.append(CGPointMake(x, y))
                self.addChild(blueAnimalSprite)
            }
        }
        
        animalPositions = shuffleArray(animalPositions)
        
        println(animalPositions)
        
        var index:Int = 0
        enumerateChildNodesWithName(typeName, usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            node.position = self.animalPositions[index]
            index++
        })
        
        
        makeCampSignView()
    }
    
    func makeWaterNode(waterSpriteSize:CGSize){
        waterSpriteNode = WaterSpriteNode(texture: SKTexture(imageNamed: "water"), size: waterSpriteSize)
//        waterSpriteNode = WaterSpriteNode(color: SKColor.greenColor(), size: waterSpriteSize)
        waterSpriteNode.name = "water"
        waterSpriteNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(waterSpriteNode)
    }
    
    func makeCampSignView(){
        campSignView = SKSpriteNode(color: SKColor.redColor(), size: CGSizeMake(100, 50))
        campSignView.position = CGPointMake(CGRectGetWidth(waterSpriteNode.frame)-50, CGRectGetMidY(waterSpriteNode.frame))
        self.addChild(campSignView)
    }
    
    // MARK: - Help method
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
    
    func getRandomColor() -> UIColor {
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    func degToRad(degree:CGFloat) -> CGFloat{
        return degree / CGFloat(180.0) * CGFloat(M_PI)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if gameStarted == false {
            println("game not start")
            return
        }
        println("Hit")
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if gameOver {
            return
        }
        if redBlood == 0 || blueBlood == 0{
            print("redBlood \(redBlood)")
            print("blueBlood \(blueBlood)")
            gameOver = true
            endGame()
        }
        
    }
    
    func endGame() {
        var startGameScene:StartGameScene = StartGameScene()
        startGameScene.size = self.frame.size
        var reveal:SKTransition = SKTransition.doorsCloseHorizontalWithDuration(1)
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
        var action:SKAction = SKAction.waitForDuration(1)
        self.runAction(action, completion: { () -> Void in
            myLabel.removeFromParent()
        })
    }
    
    func colorizeChoosenSpriteNodeWithColor(color:SKColor,touchLocation:CGPoint){
        if selectedNode != nil {
            var touchedNode:SKNode = self.nodeAtPoint(touchLocation)
            var nodeObject:AnimalSpriteNode!
            var condition:Bool = touchedNode.isKindOfClass(WaterSpriteNode)
            if condition == false{
                nodeObject = touchedNode.parent as? AnimalSpriteNode
            }
            if nodeObject != nil && selectedNode == nodeObject {
                var changeColorAction:SKAction = SKAction.colorizeWithColor(color, colorBlendFactor: 1.0, duration: 0.2)
                var selectAction:SKAction = SKAction.sequence([changeColorAction])
                selectedNode.runAction(selectAction, completion: { () -> Void in
                    self.selectedNode.color = color
                })
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        println("GameScene touchesBegan")

        gameStarted = true
        for touch: AnyObject in touches {
            if touch.tapCount == 1{
                let location = touch.locationInNode(self)
                selectNodeForTouch(location)
                colorizeChoosenSpriteNodeWithColor(SKColor(red: 0.26, green: 0.69, blue: 0.78, alpha: 1), touchLocation: location)
            }else {
                println("只支持单击")
            }
        }
    }
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            colorizeChoosenSpriteNodeWithColor(SKColor.clearColor(), touchLocation: location)
        }
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            colorizeChoosenSpriteNodeWithColor(SKColor.clearColor(), touchLocation: location)
        }
    }
    
    // MARK: - AnimalSpriteNodeDelegate
    func didTapOnSpriteNode(animalSpriteNode: AnimalSpriteNode) {
        cancleSelectedSprite()
        animalSpriteNode.flip()
    }
    
    // MARK: - Game method
    func selectNodeForTouch(touchLocation:CGPoint){
        
        var touchedNode:SKNode = self.nodeAtPoint(touchLocation)
        
        var nodeObject:AnimalSpriteNode!
        
        var condition1:Bool = touchedNode.isKindOfClass(WaterSpriteNode)
        var condition2:Bool = selectedNode != nil
        var condition3:Bool = false
        if condition1 == false{
            nodeObject = touchedNode.parent as? AnimalSpriteNode
        }
        
        if (condition2){
            if selectedNode.isEqual(nodeObject){
                println("点击了当前已选中的精灵")
                return
            }
            
            if (selectedNode.power == 0) {
                println("老鼠相关")
                if nodeObject != nil && selectedNode.physicsBody?.categoryBitMask == nodeObject.physicsBody?.categoryBitMask {
                    changeSelectedSprite(nodeObject)
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
                    println("其他动物不可进河")
                    return
                }
                println("点击另一精灵")
                if nodeObject != nil && selectedNode.physicsBody?.categoryBitMask == nodeObject.physicsBody?.categoryBitMask {
                    changeSelectedSprite(nodeObject)
                }else {
                    moveAndFight(touchLocation)
                }
            }
        }else {
            if nodeObject != nil {
                currentCategory = nodeObject.physicsBody?.categoryBitMask
                if lastCategory == currentCategory {
                    println("轮到对方啦")
                    showTips()
                    return
                }
                selectedNode = nodeObject
                if (selectedNode == nil) {
                    println("should selectd an animal fisrt")
                    return
                }
                var sequence:SKAction = SKAction.sequence([SKAction.rotateByAngle(degToRad(-4.0), duration: 0.1),SKAction.rotateByAngle(0.0, duration: 0.1),SKAction.rotateByAngle(degToRad(4.0), duration: 0.1)])
                selectedNode.runAction(SKAction.repeatActionForever(sequence))
            }
        }
    }
    
    func ratesMoveFromWaterToShore(touchLocation:CGPoint){
        var destinationPosizition:CGPoint = touchLocation
        if touchLocation.y > selectedNode.position.y && touchLocation.y > waterSpriteNode.size.height + waterSpriteNode.frame.origin.y{
            println("上游岸")
            
            destinationPosizition.x = (CGFloat(Int(touchLocation.x / selectedNode.size.width))) * selectedNode.size.width + selectedNode.size.width/2
            destinationPosizition.y = waterSpriteNode.frame.origin.y + waterSpriteNode.size.height + selectedNode.size.height/2
        }else if touchLocation.y < selectedNode.position.y && touchLocation.y < waterSpriteNode.frame.origin.y{
            println("下游岸")
            
            destinationPosizition.x = (CGFloat(Int(touchLocation.x / selectedNode.size.width))) * selectedNode.size.width + selectedNode.size.width/2
            destinationPosizition.y = waterSpriteNode.frame.origin.y - selectedNode.size.height/2
            
        }
        didAnimalMove(destinationPosizition)
    }
    
    func ratesMoveInWater(touchLocation:CGPoint){
        var destinationPosizition:CGPoint = touchLocation
        destinationPosizition =  bestDestinationInWater(touchLocation)
        didAnimalMove(destinationPosizition)
    }
    
    
    func bestDestinationInWater(touchLocation:CGPoint) -> CGPoint{
        
        var destinationPosizition:CGPoint = touchLocation

        if touchLocation.y + selectedNode.size.height/2 < waterSpriteNode.size.height + waterSpriteNode.frame.origin.y && touchLocation.y - selectedNode.size.height/2 > waterSpriteNode.frame.origin.y && touchLocation.x - selectedNode.size.height/2 > 0 && touchLocation.x + selectedNode.size.width/2 < waterSpriteNode.size.width{
            println("good position")
        }else {
            if touchLocation.x - selectedNode.size.width < 0 {
                destinationPosizition.x = selectedNode.size.width/2
            }
            if touchLocation.x + selectedNode.size.width > waterSpriteNode.size.width {
                destinationPosizition.x = waterSpriteNode.size.width - selectedNode.size.width/2
            }
            if touchLocation.y - selectedNode.size.height < waterSpriteNode.frame.origin.y {
                destinationPosizition.y = waterSpriteNode.frame.origin.y + selectedNode.size.height/2
            }
            if touchLocation.y + selectedNode.size.height > waterSpriteNode.frame.origin.y + waterSpriteNode.size.height{
                destinationPosizition.y = waterSpriteNode.frame.origin.y + waterSpriteNode.size.height - selectedNode.size.height/2
            }
        }
        
        return destinationPosizition
    }
    
    func ratesMoveFromShoreToWater(nodeObject:AnimalSpriteNode!,touchLocation:CGPoint){
        //老鼠进河
            var destinationPosition:CGPoint = bestDestinationInWater(touchLocation)
                if touchLocation.y > selectedNode.position.y {
                    //下岸入河
                    if waterSpriteNode.frame.contains(CGPointMake(selectedNode.position.x, selectedNode.position.y+selectedNode.size.height)){
                        println("老鼠在岸边")
                        didAnimalMove(destinationPosition)
                    }else {
                        moveAndFight(touchLocation)
                    }
                }
                if touchLocation.y < selectedNode.position.y {
                    //上岸入河
                    if waterSpriteNode.frame.contains(CGPointMake(selectedNode.position.x, selectedNode.position.y-selectedNode.size.height)){
                        didAnimalMove(destinationPosition)
                        println("老鼠在岸边")
                    }else {
                        moveAndFight(touchLocation)
                    }
                }
    }
    
    func moveAndFight(touchLocation:CGPoint){
        var xTouchOffset:CGFloat = touchLocation.x - selectedNode.position.x
        var yTouchOffset:CGFloat = touchLocation.y - selectedNode.position.y
        
        if fabs(xTouchOffset) - selectedNode.size.width/2.0 < 0 && fabs(yTouchOffset) - selectedNode.size.width/2.0 < 0 {
            println("移动距离上下左右不够一格")
            return;
        }
        
        if fabs(xTouchOffset) - selectedNode.size.width/2.0 > 0 && fabs(yTouchOffset) - selectedNode.size.width/2.0 > 0 {
            if waterSpriteNode.frame.contains(selectedNode.position) == false{
                println("不能对角线移动")
                return;
            }
        }
        
        if xTouchOffset > 0 && fabs(xTouchOffset) > fabs(yTouchOffset){
            println("right")
            var destinationPosizition:CGPoint = CGPointMake(selectedNode.position.x + selectedNode.size.width, selectedNode.position.y)
            
            didAnimalMove(destinationPosizition)
            
            return
            
        }
        
        if xTouchOffset < 0 && fabs(xTouchOffset) > fabs(yTouchOffset){
            println("left")
            var destinationPosizition:CGPoint = CGPointMake(selectedNode.position.x - selectedNode.size.width, selectedNode.position.y)
            
            didAnimalMove(destinationPosizition)
            
            return
            
        }
        if yTouchOffset > 0 && fabs(yTouchOffset) > fabs(xTouchOffset){
            println("up")
            var destinationPosizition:CGPoint = CGPointZero
            
            
            destinationPosizition = CGPointMake(selectedNode.position.x, selectedNode.position.y + selectedNode.size.width)
            if touchLocation.y - selectedNode.position.y > waterSpriteNode.frame.size.height + selectedNode.size.height/2 {
                var destinationPosizitionY = selectedNode.position.y + selectedNode.size.width + waterSpriteNode.frame.size.height
                destinationPosizition = CGPointMake(selectedNode.position.x, destinationPosizitionY)
            }
            
            var touchedNode1:SKNode! = self.nodeAtPoint(destinationPosizition)
            if touchedNode1 is WaterSpriteNode {
                destinationPosizition = CGPointMake(selectedNode.position.x, selectedNode.position.y + selectedNode.size.width)
            }
            println("\(destinationPosizition)")
            didAnimalMove(destinationPosizition)
            
            return
        }
        
        if yTouchOffset < 0 && fabs(yTouchOffset) > fabs(xTouchOffset){
            println("down")
            var destinationPosizition:CGPoint = CGPointZero
            
            destinationPosizition = CGPointMake(selectedNode.position.x, selectedNode.position.y - selectedNode.size.width)
            if fabs(touchLocation.y - selectedNode.position.y) > waterSpriteNode.frame.size.height + selectedNode.size.height/2 {
                var destinationPosizitionY = selectedNode.position.y - selectedNode.size.width - waterSpriteNode.frame.size.height
                destinationPosizition = CGPointMake(selectedNode.position.x, destinationPosizitionY)
            }
            var touchedNode1:SKNode! = self.nodeAtPoint(destinationPosizition)
            if touchedNode1 is WaterSpriteNode {
                destinationPosizition = CGPointMake(selectedNode.position.x, selectedNode.position.y - selectedNode.size.width)
            }
            println("\(destinationPosizition)")
            didAnimalMove(destinationPosizition)
            
            return
        }
    }
    
    
    func changeSelectedSprite(nodeObject:AnimalSpriteNode!){
        println("同一阵营")
        cancleSelectedSprite()
        selectedNode = nodeObject
        var sequence:SKAction = SKAction.sequence([SKAction.rotateByAngle(degToRad(-4.0), duration: 0.1),SKAction.rotateByAngle(0.0, duration: 0.1),SKAction.rotateByAngle(degToRad(4.0), duration: 0.1)])
        selectedNode.runAction(SKAction.repeatActionForever(sequence))
    }
    
    func cancleSelectedSprite()
    {
        if selectedNode != nil {
            selectedNode.removeAllActions()
            selectedNode.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
            selectedNode = nil;
        }
    }
    
    func didAnimalMove(var destinationPosizition:CGPoint){
        var touchedNode1:SKNode! = self.nodeAtPoint(destinationPosizition)
        if touchedNode1.parent is AnimalSpriteNode {
            destinationPosizition = touchedNode1.parent!.position
            touchedNode1 = touchedNode1.parent
        }
        if touchedNode1 is WaterSpriteNode {
            
            println("touchedNode1 is WaterSpriteNode")
        }
        
        var condition0:Bool = touchedNode1 is WaterSpriteNode
        var condition1:Bool = (touchedNode1 == nil)
        var condition2:Bool = (touchedNode1 is SKScene)
        var condition3:Bool = (condition0 == false && condition2 == false && touchedNode1 is AnimalSpriteNode && selectedNode.physicsBody?.categoryBitMask != touchedNode1.physicsBody?.categoryBitMask && ((selectedNode.power >= (touchedNode1 as! AnimalSpriteNode).power)))
        if condition0 == false && condition2 == false && selectedNode.power == 7 && (touchedNode1 as! AnimalSpriteNode).power == 0 {
            condition3 = false
        }
        var condition4:Bool = (condition0 == false && condition2 == false && selectedNode.power == 0 && (touchedNode1 as! AnimalSpriteNode).power == 7)
        
        if (condition0 || condition1 || condition2 || condition3 || condition4) {
            var moveAction:SKAction = SKAction.moveTo(destinationPosizition, duration:0.3)
            var doneAction:SKAction = SKAction.runBlock({ () -> Void in
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
            var sequence:SKAction = SKAction.sequence([moveAction,doneAction])
            selectedNode.runAction(sequence)
            
        }
    }
}
