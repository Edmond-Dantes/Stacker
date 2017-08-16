//
//  GameScene.swift
//  Stacker
//
//  Created by Edmond Akpan on 2017/08/16.
//  Copyright © 2017 Edmond Akpan. All rights reserved.
//

import SpriteKit
import GameplayKit

extension CGFloat{
    
    func abs()->CGFloat{
        var tempSelf = self
        if self < 0.0 {
            tempSelf = -self
        }
        return tempSelf
    }
    
}

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    //private var label : SKLabelNode?
    //private var spinnyNode : SKShapeNode?
    
    private var world : SKNode!
    
    private var box : SKSpriteNode?
    private var boxNodeCopy : SKSpriteNode?
    private var floorLine : SKShapeNode?
    //private var boxJoint : SKPhysicsJointLimit?
    private var touchNode : SKShapeNode?//SKNode?
    
    private var scoreLabel : SKLabelNode?
    
    private var w : CGFloat!
    
    private let worldMovementBoxLimit:CGFloat = 5
    private let worldMovementTiming: TimeInterval = 0.2
    private var worldMovementAction: SKAction!
    
    override func sceneDidLoad() {
        
        self.world = SKNode()
        self.addChild(world)
        
        self.lastUpdateTime = 0
        
        //create box
        w = (self.size.width + self.size.height) * 0.05
        self.box = SKSpriteNode.init(color: UIColor.yellow, size: CGSize.init(width: w, height: w))
        self.box?.position = CGPoint(x: 0, y: 0)
        self.box?.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: w, height: w))
        self.box?.physicsBody?.collisionBitMask = 1
        //create floorLine
        var points = [CGPoint(x: -w/4, y: -self.size.height/3),
                      CGPoint(x: w/4, y: -self.size.height/3)]
        self.floorLine = SKShapeNode(points: &points,
                                     count: points.count)
        let ground = SKShapeNode(splinePoints: &points,
                                 count: points.count)
        self.floorLine?.physicsBody = SKPhysicsBody(edgeChainFrom: ground.path!)
        self.floorLine?.physicsBody?.collisionBitMask = 1
        
        //create touchNode
        self.touchNode = SKShapeNode(circleOfRadius: 100)//SKNode()
        self.touchNode?.strokeColor = UIColor.blue
        self.touchNode?.physicsBody = SKPhysicsBody(circleOfRadius: 100)
        self.touchNode?.physicsBody?.affectedByGravity = false
        self.touchNode?.physicsBody?.allowsRotation = false
        self.touchNode?.physicsBody?.collisionBitMask = 0
        self.touchNode?.physicsBody?.categoryBitMask = 2
        self.touchNode?.physicsBody?.isDynamic = false
        
        //create scoreLabel
        self.scoreLabel = SKLabelNode(text: "1")
        self.scoreLabel?.fontSize = w
        self.scoreLabel?.fontColor = UIColor.blue
        self.scoreLabel?.color = UIColor.white
        self.scoreLabel?.position = CGPoint(x: 0, y: -self.size.height * 0.4)
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        self.touchNode?.position = self.convert(pos, to: self.world)
        
        self.boxNodeCopy = self.box?.copy() as? SKSpriteNode
        self.boxNodeCopy?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.boxNodeCopy?.zRotation = 0
        self.boxNodeCopy?.physicsBody?.angularVelocity = 0
        self.boxNodeCopy?.physicsBody?.isDynamic = false
        self.boxNodeCopy?.physicsBody?.affectedByGravity = false
        self.boxNodeCopy?.position = self.convert(CGPoint(x: pos.x, y: pos.y + self.size.height * 0.05), to: self.world)
        self.world.addChild(self.boxNodeCopy!)
        self.currentBoxCount += 1
        
        scoreLabel?.removeFromParent()
        //self.world.addChild(self.scoreLabel!)
        self.addChild(self.scoreLabel!)
        
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        self.touchNode?.position = self.convert(pos, to: self.world)
        self.boxNodeCopy?.position = self.convert(CGPoint(x: pos.x, y: pos.y + self.size.height * 0.05), to: self.world)
        self.boxNodeCopy?.zRotation = 0
        self.boxNodeCopy?.physicsBody?.angularVelocity = 0
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        //self.physicsWorld.remove(self.boxJoint!)
        self.boxNodeCopy?.physicsBody?.isDynamic = true
        self.boxNodeCopy?.physicsBody?.affectedByGravity = true
        self.touchNode?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.boxNodeCopy?.zRotation = 0
        self.boxNodeCopy?.physicsBody?.angularVelocity = 0
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    var hasGameStarted : Bool = false
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        
        
        if !hasGameStarted{
            self.world.addChild(self.box!)
            self.currentBoxCount += 1
            self.world.addChild(self.floorLine!)
            self.world.addChild(self.touchNode!)
            self.world.addChild(self.scoreLabel!)
            //self.scoreLabel?.position =
            hasGameStarted = true
        }
        
        if !self.world.hasActions() {
            
            worldMovementAction = SKAction.move(to: CGPoint(x: self.world.position.x, y: -w * (self.currentBoxCount - self.worldMovementBoxLimit) ), duration: self.worldMovementTiming)
            if self.currentBoxCount >= self.worldMovementBoxLimit{
                let checkPoint = CGPoint(x: 0, y: -w * (self.currentBoxCount - self.worldMovementBoxLimit))
                shouldUpdateWorldPosition = true
                if self.world.position != checkPoint{
                    self.world.run(worldMovementAction){
                        self.world.removeAllActions()
                        self.shouldUpdateWorldPosition = false
                    }
                }
            }else if self.currentBoxCount < self.worldMovementBoxLimit{
                //let checkPoint = CGPoint(x: 0, y: 0)
                if shouldUpdateWorldPosition{
                    self.world.removeAllActions()
                    self.shouldUpdateWorldPosition = false
                    self.world.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.worldMovementTiming)){
                        self.world.removeAllActions()
                    }
                }
                
                
            }
            
        }else if shouldUpdateWorldPosition && self.currentBoxCount < self.worldMovementBoxLimit{
            self.world.removeAllActions()
            self.shouldUpdateWorldPosition = false
            self.world.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: self.worldMovementTiming)){
                self.world.removeAllActions()
            }
        }else if self.currentBoxCount == self.worldMovementBoxLimit{
            self.world.removeAllActions()
            shouldUpdateWorldPosition = true
            //let checkPoint = CGPoint(x: 0, y: -w * (self.currentBoxCount - self.worldMovementBoxLimit))
            
            /*if self.world.position == checkPoint || !shouldUpdateWorldPosition{
                self.world.removeAllActions()
            }*/
        }
        
    
    
        
        
        
        
        
    }
    
    override func didEvaluateActions() {
        
       /* if self.currentBoxCount < self.worldMovementBoxLimit{
            self.world.position = CGPoint(x: 0, y: 0)
        }else{
            self.world.position = CGPoint(x: self.world.position.x, y: -w * (self.currentBoxCount - self.worldMovementBoxLimit))
        }*/
        
        
    }
    var hasLost:Bool = false //gameover
    var shouldUpdateWorldPosition : Bool = false
    var currentBoxCount:CGFloat = 0
    override func didSimulatePhysics() {
        
        for child in self.world.children{
            if child != self.touchNode && child != self.floorLine && child != self.scoreLabel{
                child.physicsBody?.isDynamic = true
            }
            let sceneCGRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2 + self.world.position.y) , size: CGSize(width: self.size.width, height: self.size.height - self.world.position.y * 2))
            if !sceneCGRect.contains(child.position){
                if child != self.touchNode && child != self.floorLine && child != self.scoreLabel{
                    if child == self.boxNodeCopy || child == self.box{
                        if boxNodeCopy != nil{
                            if child == self.boxNodeCopy{
                                //self.scoreLabel?.removeFromParent()
                            }
                        }else{
                            if child == self.box{
                                //self.scoreLabel?.removeFromParent()
                            }
                        }
                    }
                    child.removeFromParent()
                    self.currentBoxCount -= 1
                    if self.currentBoxCount < 0{
                        self.currentBoxCount = CGFloat(self.world.children.count) - 2
                    }
                }
                //print(self.world.children.count)
            }
        }
        
        print(self.currentBoxCount)
        let score = Int(self.currentBoxCount)
        self.scoreLabel?.text = "\(score)"
        /*
        if let b = boxNodeCopy{
            self.scoreLabel?.position = b.position
            self.scoreLabel?.position.y -= w/3
            self.scoreLabel?.zRotation = b.zRotation
        }else{
            self.scoreLabel?.position = self.box!.position
            self.scoreLabel?.position.y -= w/3
            self.scoreLabel?.zRotation = self.box!.zRotation
        }
        
        */
        
        
    }
    
    
    
}
