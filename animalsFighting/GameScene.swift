//
//  GameScene.swift
//  animalsFighting
//
//  Created by lieyunye on 3/21/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let none      : UInt32 = 0x0
    static let redAnimal      : UInt32 = 0x1
    static let blueAnimal     : UInt32 = 0x10
}

 let blank:CGFloat = 0.0
let typeName:String = "animal"

class GameScene: SKScene,SKPhysicsContactDelegate{

    var animalsName:[String] = ["象","虎","狮","豹","狼","狗","蛇","鼠"]
    var animalsBackgroundColors = [UIColor]()
    var animalNodes = [AnimalSpriteNode]()
    var animalPositions = [CGPoint]()
    var selectedNode:AnimalSpriteNode!
    
    var waterSpriteNode:WaterSpriteNode!
    var gameStarted:Bool = false
    
    var redBlood:Int = 16
    var blueBlood:Int = 16
    
    var gameOver:Bool = false
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        physicsWorld.contactDelegate = self
        let animalSize:CGSize = CGSizeMake(self.frame.size.width/8.0, self.frame.size.width/8.0)
        let waterSpriteSize:CGSize = CGSizeMake(self.frame.size.width, self.frame.size.height - (animalSize.height * 4 + blank * 2))
        

        self.backgroundColor = UIColor.blackColor()

        for item in 0..<8 {
            animalsBackgroundColors.append(getRandomColor())
        }
        for row in 0..<2 {
            for col in 0..<8 {
                let redAnimalSprite = AnimalSpriteNode(color: UIColor(red: 1, green: 0, blue: 0, alpha: 0.5), size: animalSize)
                redAnimalSprite.power = 7-col
                redAnimalSprite .addAnimalName(animalsName[col], color: animalsBackgroundColors[col])
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
                let blueAnimalSprite = AnimalSpriteNode(color: UIColor(red: 0, green: 0, blue: 1, alpha: 0.5), size: animalSize)
                blueAnimalSprite.power = 7-col
                blueAnimalSprite .addAnimalName(animalsName[col], color: animalsBackgroundColors[col])
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
        
        
        waterSpriteNode = WaterSpriteNode(color: SKColor.greenColor(), size: waterSpriteSize)
        waterSpriteNode.name = "water"
        waterSpriteNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(waterSpriteNode)
        
        
        
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
    
    func getRandomColor() -> UIColor {
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        gameStarted = true
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            selectNodeForTouch(location)
        }
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
    
    
    func selectNodeForTouch(touchLocation:CGPoint){
        
        if selectedNode != nil && selectedNode.power > 0 && waterSpriteNode.frame.contains(touchLocation){
            println("其他动物不可进河")
            return
        }
        
        var touchedNode:SKNode = self.nodeAtPoint(touchLocation)
        
        var nodeObject:AnimalSpriteNode!

        
        var condition1:Bool = touchedNode.isKindOfClass(WaterSpriteNode)
        var condition2:Bool = selectedNode != nil
        var condition3:Bool = false
        if condition1 == false{
            if touchedNode.isKindOfClass(SKLabelNode){
                nodeObject = touchedNode.parent as? AnimalSpriteNode
            }else {
                nodeObject = touchedNode as? AnimalSpriteNode
            }
            if nodeObject != nil {
                condition3 = condition2 && (selectedNode.power == 0) && (nodeObject.power == 0)
            }
        }
        
        if condition1 || condition3{
            println("touch on WaterSpriteNode")
            if (selectedNode != nil && selectedNode.power == 0) {
                if selectedNode.power == 0 {//老鼠进河
                    var destinationPosition:CGPoint = touchLocation;
                    if waterSpriteNode.frame.contains(selectedNode.position) == false{//老鼠不在岸边
                        if touchLocation.y > selectedNode.position.y {
                            //下岸入河
                            if waterSpriteNode.frame.contains(CGPointMake(selectedNode.position.x, selectedNode.position.y+selectedNode.size.height)) == false{
                                return
                            }
                        }
                        
                        if touchLocation.y < selectedNode.position.y {
                            //上岸入河
                            if waterSpriteNode.frame.contains(CGPointMake(selectedNode.position.x, selectedNode.position.y-selectedNode.size.height)) == false{
                                return
                            }
                        }
                    }
                    
                    
                    if touchLocation.y + selectedNode.size.height/2 < waterSpriteNode.size.height + waterSpriteNode.frame.origin.y && touchLocation.y - selectedNode.size.height/2 > waterSpriteNode.frame.origin.y && touchLocation.x - selectedNode.size.height/2 > 0 && touchLocation.x + selectedNode.size.width/2 < waterSpriteNode.size.width{
                        println("good position")
                    }else {
                        if touchLocation.x - selectedNode.size.width < 0 {
                            destinationPosition.x = selectedNode.size.width/2
                        }
                        if touchLocation.x + selectedNode.size.width > waterSpriteNode.size.width {
                            destinationPosition.x = waterSpriteNode.size.width - selectedNode.size.width/2
                        }
                        if touchLocation.y - selectedNode.size.height < waterSpriteNode.frame.origin.y {
                            destinationPosition.y = waterSpriteNode.frame.origin.y + selectedNode.size.height/2
                        }
                        if touchLocation.y + selectedNode.size.height > waterSpriteNode.frame.origin.y + waterSpriteNode.size.height{
                            destinationPosition.y = waterSpriteNode.frame.origin.y + waterSpriteNode.size.height - selectedNode.size.height/2
                        }
                    }
                    
                    didAnimalMove(destinationPosition)
                }else {
                    self.selectedNode.removeAllActions()
                    self.selectedNode.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
                    println(self.selectedNode.position)
                    self.selectedNode = nil
                }
            }
            return
        }
       
        if selectedNode != nil && nodeObject != nil && selectedNode.physicsBody?.categoryBitMask == nodeObject.physicsBody?.categoryBitMask {
            if selectedNode.power == nodeObject.power {
                println("选中的sprite与点击的sprite相同")
                return;
            }
            println("同一阵营")
            selectedNode.removeAllActions()
            selectedNode.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
            selectedNode = nil;
        }

        if (selectedNode != nil) {
            if selectedNode.isEqual(nodeObject) == false {
                

                if waterSpriteNode.frame.contains(selectedNode.position){
                    
                    var destinationPosizition:CGPoint = touchLocation
                    if touchLocation.y > selectedNode.position.y && touchLocation.y > waterSpriteNode.size.height + waterSpriteNode.frame.origin.y{
                        println("上游岸")
                        
                        destinationPosizition.x = (CGFloat(Int(touchLocation.x / selectedNode.size.width))) * selectedNode.size.width + selectedNode.size.width/2
                        destinationPosizition.y = waterSpriteNode.frame.origin.y + waterSpriteNode.size.height + selectedNode.size.height/2
                    }
                    
                    if touchLocation.y < selectedNode.position.y && touchLocation.y < waterSpriteNode.frame.origin.y{
                        println("下游岸")
                        
                        destinationPosizition.x = (CGFloat(Int(touchLocation.x / selectedNode.size.width))) * selectedNode.size.width + selectedNode.size.width/2
                        destinationPosizition.y = waterSpriteNode.frame.origin.y - selectedNode.size.height/2

                    }
                    
                    didAnimalMove(destinationPosizition)
                    return
                }
                
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
        }else {
            selectedNode = nodeObject
            if (selectedNode == nil) {
                println("should selectd an animal fisrt")
                return
            }
            var sequence:SKAction = SKAction.sequence([SKAction.rotateByAngle(degToRad(-4.0), duration: 0.1),SKAction.rotateByAngle(0.0, duration: 0.1),SKAction.rotateByAngle(degToRad(4.0), duration: 0.1)])
            selectedNode.runAction(SKAction.repeatActionForever(sequence))
        }
    }
    
    func didAnimalMove(destinationPosizition:CGPoint){
        var touchedNode1:SKNode! = self.nodeAtPoint(destinationPosizition)
        if touchedNode1 is SKLabelNode {
            touchedNode1 = touchedNode1.parent as AnimalSpriteNode
        }
        if touchedNode1 is WaterSpriteNode {
            
            println("touchedNode1 is WaterSpriteNode")
        }
        
        var condition0:Bool = touchedNode1 is WaterSpriteNode
        var condition1:Bool = (touchedNode1 == nil)
        var condition2:Bool = (touchedNode1 is SKScene)
        var condition3:Bool = (condition0 == false && condition2 == false && touchedNode1 is AnimalSpriteNode && selectedNode.physicsBody?.categoryBitMask != touchedNode1.physicsBody?.categoryBitMask && ((selectedNode.power >= (touchedNode1 as AnimalSpriteNode).power)))
        if condition0 == false && condition2 == false && selectedNode.power == 7 && (touchedNode1 as AnimalSpriteNode).power == 0 {
            condition3 = false
        }
        var condition4:Bool = (condition0 == false && condition2 == false && selectedNode.power == 0 && (touchedNode1 as AnimalSpriteNode).power == 7)
        println(touchedNode1)
        
        if (condition0 || condition1 || condition2 || condition3 || condition4) {
            var moveAction:SKAction = SKAction.moveTo(destinationPosizition, duration:0.3)
            var doneAction:SKAction = SKAction.runBlock({ () -> Void in
                self.selectedNode.removeAllActions()
                self.selectedNode.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
                if touchedNode1 != nil && touchedNode1 is WaterSpriteNode == false{
                    if touchedNode1 is AnimalSpriteNode && (touchedNode1 as AnimalSpriteNode).physicsBody?.categoryBitMask == PhysicsCategory.redAnimal {
                        self.redBlood -= 1
                    }else if touchedNode1 is AnimalSpriteNode && (touchedNode1 as AnimalSpriteNode).physicsBody?.categoryBitMask == PhysicsCategory.blueAnimal {
                        self.blueBlood -= 1
                    }
                    touchedNode1.removeFromParent()
                }
                println(self.selectedNode.position)
                self.selectedNode = nil
                
                println(self.selectedNode)
            })
            var sequence:SKAction = SKAction.sequence([moveAction,doneAction])
            selectedNode.runAction(sequence)
            
        }
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
}
