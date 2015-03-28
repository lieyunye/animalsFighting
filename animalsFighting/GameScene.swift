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

class GameScene: SKScene,SKPhysicsContactDelegate{

    var animalsName:[String] = ["象","虎","狮","豹","狼","狗","蛇","鼠"]
    var animalsBackgroundColors = [UIColor]()
    var selectedNode:AnimalSpriteNode!
    
    var waterSpriteNode:WaterSpriteNode!
    var gameStarted:Bool = false
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        physicsWorld.contactDelegate = self
        let animalSize:CGSize = CGSizeMake(self.frame.size.width/8.0, self.frame.size.width/8.0)
        let waterSpriteSize:CGSize = CGSizeMake(self.frame.size.width, self.frame.size.height - (animalSize.height * 4 + 10 * 2))
        

        self.backgroundColor = UIColor.blackColor()

        for item in 0..<8 {
            animalsBackgroundColors.append(getRandomColor())
        }
        for row in 0..<2 {
            for col in 0..<8 {
                let redAnimalSprite = AnimalSpriteNode(color: animalsBackgroundColors[col], size: animalSize)
                redAnimalSprite .addAnimalName(animalsName[col], color: UIColor.orangeColor())
                redAnimalSprite.physicsBody?.categoryBitMask = PhysicsCategory.redAnimal
                redAnimalSprite.physicsBody?.contactTestBitMask = PhysicsCategory.blueAnimal
                redAnimalSprite.physicsBody?.collisionBitMask = PhysicsCategory.none
                redAnimalSprite.physicsBody?.dynamic = true
                redAnimalSprite.physicsBody?.affectedByGravity = false
                redAnimalSprite.name = animalsName[col]
                
                var x:CGFloat = CGFloat(col)*animalSize.width + animalSize.width/2.0
                var y:CGFloat = CGFloat(row)*(animalSize.height + 10) + animalSize.height/2.0
                redAnimalSprite.position = CGPointMake(x, y)
                self.addChild(redAnimalSprite)
            }
        }
        
        for row in 0..<2 {
            for col in 0..<8 {
                let blueAnimalSprite = AnimalSpriteNode(color: animalsBackgroundColors[col], size: animalSize)
                blueAnimalSprite .addAnimalName(animalsName[col], color: UIColor.yellowColor())
                blueAnimalSprite.physicsBody?.categoryBitMask = PhysicsCategory.blueAnimal
                blueAnimalSprite.physicsBody?.contactTestBitMask = PhysicsCategory.redAnimal
                blueAnimalSprite.physicsBody?.collisionBitMask = PhysicsCategory.none
                blueAnimalSprite.physicsBody?.dynamic = true
                blueAnimalSprite.physicsBody?.affectedByGravity = false
                blueAnimalSprite.name = animalsName[col]

                
                var x:CGFloat = CGFloat(col)*animalSize.width + animalSize.width/2.0
                var y:CGFloat = (self.frame.size.height - (CGFloat(row)*(animalSize.height + 10) + animalSize.height/2.0))
                blueAnimalSprite.position = CGPointMake(x, y)
                self.addChild(blueAnimalSprite)
            }
        }
        
        waterSpriteNode = WaterSpriteNode(color: SKColor.greenColor(), size: waterSpriteSize)
        waterSpriteNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(waterSpriteNode)
        
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
    }
    
    func selectNodeForTouch(touchLocation:CGPoint){
        

        var touchedNode:SKNode = self.nodeAtPoint(touchLocation)
        if touchedNode.isKindOfClass(WaterSpriteNode) {
            println("touch on WaterSpriteNode")
            if (selectedNode != nil) {
                selectedNode.removeAllActions()
                selectedNode.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
                selectedNode = nil
            }
            return
        }
        var nodeObject:AnimalSpriteNode?
        if touchedNode.isKindOfClass(SKLabelNode){
            nodeObject = touchedNode.parent as? AnimalSpriteNode
        }else {
            nodeObject = touchedNode as? AnimalSpriteNode
        }
        if (selectedNode != nil) {
//            if selectedNode.physicsBody?.categoryBitMask == nodeObject.physicsBody?.categoryBitMask {
//                println("同一阵营")
//                return
//            }
            if selectedNode.isEqual(nodeObject) == false {

                var xTouchOffset:CGFloat = touchLocation.x - selectedNode.position.x
                var yTouchOffset:CGFloat = touchLocation.y - selectedNode.position.y
                
                if fabs(xTouchOffset) - selectedNode.size.width/2.0 < 0 && fabs(yTouchOffset) - selectedNode.size.width/2.0 < 0 {
                    println("移动距离上下左右不够一格")
                    return;
                }
                
                if fabs(xTouchOffset) - selectedNode.size.width/2.0 > 0 && fabs(yTouchOffset) - selectedNode.size.width/2.0 > 0 {
                    println("不能对角线移动")
                    return;
                }
                
                if xTouchOffset > 0 && fabs(xTouchOffset) > fabs(yTouchOffset){
                    println("right")
                    var destinationPosizition:CGPoint = CGPointMake(selectedNode.position.x + selectedNode.frame.size.width, selectedNode.position.y)
                    
                    var touchedNode:SKNode? = self.nodeAtPoint(destinationPosizition)
                    if (touchedNode == nil) {
                        var moveAction:SKAction = SKAction.moveTo(destinationPosizition, duration:0.3)
                        selectedNode.runAction(moveAction)
                        selectedNode.removeAllActions()
                        selectedNode.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
                    }
                    
                    return
                    
                }
                
                if xTouchOffset < 0 && fabs(xTouchOffset) > fabs(yTouchOffset){
                    println("left")
                    var destinationPosizition:CGPoint = CGPointMake(selectedNode.position.x - selectedNode.frame.size.width, selectedNode.position.y)
                    
                    var touchedNode:SKNode? = self.nodeAtPoint(destinationPosizition)
                    if (touchedNode == nil) {
                        var moveAction:SKAction = SKAction.moveTo(destinationPosizition, duration:0.3)
                        selectedNode.runAction(moveAction)
                        selectedNode.removeAllActions()
                        selectedNode.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
                    }
                    return
                    
                }
                if yTouchOffset > 0 && fabs(yTouchOffset) > fabs(xTouchOffset){
                    println("up")
                    
                    var destinationPosizition:CGPoint = CGPointMake(selectedNode.position.x, selectedNode.position.y + selectedNode.frame.size.width)
                    if touchLocation.y - selectedNode.position.y > waterSpriteNode.frame.size.height + selectedNode.frame.size.height/2 {
                        destinationPosizition = CGPointMake(selectedNode.position.x, selectedNode.position.y + selectedNode.frame.size.width + waterSpriteNode.frame.size.height)
                    }
                    
                    var touchedNode1:SKNode! = self.nodeAtPoint(destinationPosizition)
                    if touchedNode1 is SKLabelNode {
                        touchedNode1 = touchedNode1.parent as AnimalSpriteNode
                    }
                    
                    if (touchedNode1 == nil || selectedNode.physicsBody?.categoryBitMask != touchedNode1.physicsBody?.categoryBitMask) {
                        var moveAction:SKAction = SKAction.moveTo(destinationPosizition, duration:0.3)
                        var doneAction:SKAction = SKAction.runBlock({ () -> Void in
                            self.selectedNode.removeAllActions()
                            self.selectedNode.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
                        })
                        var sequence:SKAction = SKAction.sequence([moveAction,doneAction])
                        selectedNode.runAction(sequence)

                    }
                    return
                }
                
                if yTouchOffset < 0 && fabs(yTouchOffset) > fabs(xTouchOffset){
                    println("down")
                    var destinationPosizition:CGPoint = CGPointMake(selectedNode.position.x, selectedNode.position.y - selectedNode.frame.size.width)
                    
                    var touchedNode:SKNode? = self.nodeAtPoint(destinationPosizition)
                    if (touchedNode == nil) {
                        var moveAction:SKAction = SKAction.moveTo(destinationPosizition, duration:0.3)
                        selectedNode.runAction(moveAction)
                        selectedNode.removeAllActions()
                        selectedNode.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
                    }
                    return
                }
                
                
//                if fabs(xTouchOffset) - selectedNode.frame.size.width - selectedNode.size.width/2.0 > 0 {
//                    println("移动距离左右超出两格")
//                    
//                    
//                    return;
//                }
//                
//                if fabs(yTouchOffset) - selectedNode.frame.size.width - selectedNode.size.width/2.0 > 0 {
//                    println("移动距离上下超出两格")
//                    return;
//                }
                
                
                
//                var moveAction:SKAction = SKAction.moveTo(nodeObject.position, duration:0.3)
//                var doneAction:SKAction = SKAction.runBlock({ () -> Void in
//                    nodeObject.removeFromParent()
//                    self.selectedNode = nil
//                })
//                var sequence:SKAction = SKAction.sequence([moveAction,doneAction])
//                selectedNode.runAction(moveAction)
            }
        }else {
            selectedNode = nodeObject
            var sequence:SKAction = SKAction.sequence([SKAction.rotateByAngle(degToRad(-4.0), duration: 0.1),SKAction.rotateByAngle(0.0, duration: 0.1),SKAction.rotateByAngle(degToRad(4.0), duration: 0.1)])
            selectedNode.runAction(SKAction.repeatActionForever(sequence))
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
