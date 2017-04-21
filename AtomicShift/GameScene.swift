//
//  GameScene.swift
//  Atomic Shift
//
//  Created by Ryan Grogger on 4/13/17.
//  Copyright © 2017 Ryan Grogger. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,SKPhysicsContactDelegate
{
    var positiveWall:SKSpriteNode!
    var negativeWall:SKSpriteNode!
    var circle: SKSpriteNode!
    var stars:SKSpriteNode!
    var wallSwitch:SKSpriteNode!
    
    var count = 0
    
    override func didMove(to view: SKView)
    {
        self.physicsWorld.contactDelegate = self
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        createPositiveWall()
        createNegativeWall()
        createCircle()
        createBackground()
        createSwitch()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if (count % 2 == 0)
        {
            circle.texture = SKTexture(imageNamed: "Negative Charge")
        }
        else
        {
            circle.texture = SKTexture(imageNamed: "Positive Charge")
        }
        createGravity()
        count += 1
        print("tapped")
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
            if (contact.bodyA.node?.name == "wallSwitch")
            {
                print("Wall Switched")
                positiveWall.name = "negative"
                contact.bodyA.node?.removeFromParent()
                createGravity()
            }
            else if (contact.bodyB.node?.name == "wallSwitch")
            {
                print("Wall Switched")
                positiveWall.name = "negative"
                contact.bodyB.node?.removeFromParent()
                createGravity()
            }
            print("didBegin executed")
    }

    func createGravity()
    {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        if ((count % 2 == 0) && (positiveWall.name == "positive"))
        {
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 9.8)
        }
        else if ((count % 2 == 0) && (positiveWall.name == "negative"))
        {
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)        }
        else if ((count % 2 == 1) && (positiveWall.name == "positive"))
        {
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        }
        else
        {
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 9.8)
        }
    }

    func createPositiveWall()
    {
        positiveWall = SKSpriteNode(color: UIColor.red, size: (CGSize(width: frame.width, height: frame.height/64)))
        positiveWall.position = CGPoint(x: frame.midX, y: frame.maxY - 490)
        positiveWall.physicsBody = SKPhysicsBody(rectangleOf: positiveWall.size)
        positiveWall.physicsBody?.affectedByGravity = false
        positiveWall.physicsBody?.isDynamic = false
        positiveWall.name = "positive"
        
        addChild(positiveWall)
    }
    
    func createNegativeWall()
    {
        negativeWall = SKSpriteNode(color:UIColor.blue, size: (CGSize(width: frame.width, height: frame.height/64)))
        negativeWall.position = CGPoint(x: frame.midX, y: frame.minY + 466)
        negativeWall.physicsBody = SKPhysicsBody(rectangleOf: negativeWall.size)
        negativeWall.physicsBody?.affectedByGravity = false
        negativeWall.physicsBody?.isDynamic = false
        
        addChild(negativeWall)
    }
    
    func createCircle()
    {
        circle = SKSpriteNode(imageNamed: "Positive Charge")
        circle.size = CGSize(width: 50, height: 40)
        circle.position = CGPoint(x: frame.midX - 250, y: frame.midY)
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        circle.physicsBody?.allowsRotation = false
        circle.physicsBody?.isDynamic = true
        
        addChild(circle)
    }
    
    func createBackground()
    {
        stars = SKSpriteNode(imageNamed: "background")
        stars.position = CGPoint(x: frame.midX, y: frame.midY)
        stars.size = CGSize(width: frame.width, height: frame.height)
        stars.zPosition = -1
        
        addChild(stars)
    }

    func createSwitch()
    {
        wallSwitch = SKSpriteNode(imageNamed: "Wall Swap Item")
        wallSwitch.position = CGPoint(x: frame.midX, y: frame.midY)
        wallSwitch.size = CGSize(width: 100, height: 75)
        wallSwitch.physicsBody = SKPhysicsBody(circleOfRadius: 23)
        wallSwitch.name = "wallSwitch"
        
        addChild(wallSwitch)
        
        wallSwitch.physicsBody?.affectedByGravity = true
        wallSwitch.physicsBody?.applyImpulse(CGVector(dx: -10, dy: 0))
        wallSwitch.physicsBody?.isDynamic = true
    }
}
