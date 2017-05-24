//
//  GameScene.swift
//  Atomic Shift
//
//  Created by Ryan Grogger on 4/13/17.
//  Copyright © 2017 Ryan Grogger. All rights reserved.
//

//timer.invaladate 



import SpriteKit
import GameplayKit

class GameScene: SKScene,SKPhysicsContactDelegate
{
    var positiveWall:SKSpriteNode!
    var negativeWall:SKSpriteNode!
    var circle: SKSpriteNode!
    var stars:SKSpriteNode!
    var wallSwitch:SKSpriteNode!
    var photon:SKSpriteNode!
    var deleteWall:SKSpriteNode!
    var lifeItem:SKSpriteNode!
    var atomCluster:SKSpriteNode!

    var lifeLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var highScoreLabel = SKLabelNode()
    
    var scoreTimer = Timer()
    var photonTimer = Timer()
    var switchTimer = Timer()
    var lifeTimer = Timer()
    var clusterTimer = Timer()
    var wallHazardTimer = Timer()
    
    var positive = true
    var highScore = 0
    var lives = 5
    var score = 0
    var atomClusterNum = 0
    
    var photons = [SKSpriteNode]()
    var switches = [SKSpriteNode]()
    var atomClusters = [SKSpriteNode]()
    var lifeItems = [SKSpriteNode]()

    override func didMove(to view: SKView)
    {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        scheduledTimerWithTimeInterval()

        makeLabel(labelName: lifeLabel, labelText: "Lives: \(lives)", labelFontSize: 25, labelFontColor: UIColor.white, labelPosition: CGPoint(x: frame.midX, y: frame.maxY - 478))
        makeLabel(labelName: scoreLabel, labelText: "Score: \(score)", labelFontSize: 25, labelFontColor: UIColor.white, labelPosition: CGPoint(x: frame.midX - 250, y: frame.maxY - 478))
        makeLabel(labelName: highScoreLabel, labelText: "Highscore: \(highScore)", labelFontSize: 25, labelFontColor: UIColor.white, labelPosition: CGPoint(x: frame.midX + 250, y: frame.maxY - 478))
        resetGame()
        var xPos = frame.maxX
        var yPos = frame.midY - 165 + CGFloat(randomNumber(MIN: 0, MAX: 330))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        circle.position.x = frame.midX - 250
        if (positive)
        {
            positive = !positive
            circle.texture = SKTexture(imageNamed: "Negative Charge")
        }
        else
        {
            positive = !positive
            circle.texture = SKTexture(imageNamed: "Positive Charge")
        }
        createGravity()
        print("tapped")
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        for lifeItem in lifeItems
        {
            if (contact.bodyA.node == lifeItem && contact.bodyB.node == circle)
            {
                contact.bodyA.node?.removeFromParent()
                lives += 1
                lifeLabel.text = "Lives: \(lives)"
                resetBall()
            }
            else if (contact.bodyB.node == lifeItem && contact.bodyA.node == circle)
            {
                contact.bodyB.node?.removeFromParent()
                lives += 1
                lifeLabel.text = "Lives: \(lives)"
                resetBall()
            }
            else if (contact.bodyA.node == lifeItem && contact.bodyB.node == deleteWall)
            {
                contact.bodyA.node?.removeFromParent()
            }
            else if (contact.bodyB.node == lifeItem && contact.bodyA.node == deleteWall)
            {
                contact.bodyB.node?.removeFromParent()
            }
        }
        
        for photon in photons
        {
            if(contact.bodyA.node == photon && contact.bodyB.node == deleteWall)
            {
                print("photon deleted")
                contact.bodyA.node?.removeFromParent()
            }
            else if(contact.bodyB.node == photon && contact.bodyA.node == deleteWall)
            {
                print("photon deleted")
                contact.bodyB.node?.removeFromParent()
            }
            else if (contact.bodyA.node == photon && contact.bodyB.node == circle)
            {
                print("Lost a Life")
                lives -= 1
                checkGameOver()
                lifeLabel.text = "Lives: \(lives)"
                contact.bodyA.node?.removeFromParent()
                resetBall()
            }
            else if (contact.bodyB.node == photon && contact.bodyA.node == circle)
            {
                print("Lost a Life")
                lives -= 1
                checkGameOver()
                lifeLabel.text = "Lives: \(lives)"
                contact.bodyB.node?.removeFromParent()
                resetBall()
            }
        }
        
        for atomCluster in atomClusters
        {
            if (contact.bodyA.node == positiveWall && contact.bodyB.node == atomCluster)
            {
                contact.bodyB.node?.removeFromParent()
                createPhoton(xPos: atomCluster.position.x, yPos: atomCluster.position.y)
                createPhoton(xPos: atomCluster.position.x + 1, yPos: atomCluster.position.y + 1)
                createPhoton(xPos: atomCluster.position.x + 2, yPos: atomCluster.position.y + 2)
                createPhoton(xPos: atomCluster.position.x + 3, yPos: atomCluster.position.y + 3)
                createPhoton(xPos: atomCluster.position.x - 1, yPos: atomCluster.position.y - 1)
            }
            else if (contact.bodyA.node == negativeWall && contact.bodyB.node == atomCluster)
            {
                contact.bodyB.node?.removeFromParent()
                createPhoton(xPos: atomCluster.position.x, yPos: atomCluster.position.y)
                createPhoton(xPos: atomCluster.position.x + 1, yPos: atomCluster.position.y + 1)
                createPhoton(xPos: atomCluster.position.x + 2, yPos: atomCluster.position.y + 2)
                createPhoton(xPos: atomCluster.position.x + 3, yPos: atomCluster.position.y + 3)
                createPhoton(xPos: atomCluster.position.x - 1, yPos: atomCluster.position.y - 1)
            }
            else if (contact.bodyA.node == circle && contact.bodyB.node == atomCluster)
            {
                resetBall()
            }
            else if (contact.bodyB.node == circle && contact.bodyA.node == atomCluster)
            {
                resetBall()
            }
            else if (contact.bodyA.node == deleteWall && contact.bodyB.node == atomCluster)
            {
                contact.bodyB.node?.removeFromParent()
            }
            else if (contact.bodyA.node == atomCluster && contact.bodyB.node == deleteWall)
            {
                contact.bodyA.node?.removeFromParent()
            }
        }
        
        for wallSwitch in switches
        {
            if (contact.bodyA.node == wallSwitch && contact.bodyB.node == circle)
            {
                if (positiveWall.name == "positive")
                {
                    positiveWall.name = "negative"
                    positiveWall.color = UIColor.blue
                    negativeWall.color = UIColor.red
                }
                else
                {
                    positiveWall.name = "positive"
                    negativeWall.color = UIColor.blue
                    positiveWall.color = UIColor.red
                }
                contact.bodyA.node?.removeFromParent()
                createGravity()
                resetBall()
            }
            else if (contact.bodyB.node == wallSwitch && contact.bodyA.node == circle)
            {
                if (positiveWall.name == "positive")
                {
                    positiveWall.name = "negative"
                    positiveWall.color = UIColor.blue
                    negativeWall.color = UIColor.red
                }
                else
                {
                    positiveWall.name = "positive"
                    negativeWall.color = UIColor.blue
                    positiveWall.color = UIColor.red
                }
                contact.bodyB.node?.removeFromParent()
                createGravity()
                resetBall()
            }
            else if(contact.bodyA.node == wallSwitch && contact.bodyB.node == deleteWall)
            {
                contact.bodyA.node?.removeFromParent()
            }
            else if(contact.bodyB.node == wallSwitch && contact.bodyA.node == deleteWall)
            {
                contact.bodyB.node?.removeFromParent()
            }
        }
    }

    func createGravity()
    {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        if ((positive) && (positiveWall.name == "negative"))
        {
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 6)
        }
        else if ((positive) && (positiveWall.name == "positive"))
        {
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -6)
        }
        else if ((!positive) && (positiveWall.name == "negative"))
        {
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -6)
        }
        else
        {
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 6)
        }
    }
    
    func createPositiveWall()
    {
        positiveWall = SKSpriteNode(color: UIColor.red, size: (CGSize(width: frame.width, height: frame.height/64)))
        positiveWall.position = CGPoint(x: frame.midX, y: frame.maxY - 490)
        positiveWall.physicsBody = SKPhysicsBody(rectangleOf: positiveWall.size)
        positiveWall.physicsBody?.affectedByGravity = false
        positiveWall.physicsBody?.allowsRotation = false
        positiveWall.physicsBody?.isDynamic = false
        positiveWall.physicsBody?.friction = 0
        positiveWall.zPosition = 5

        positiveWall.name = "positive"
        
        addChild(positiveWall)
    }
    
    func createNegativeWall()
    {
        negativeWall = SKSpriteNode(color:UIColor.blue, size: (CGSize(width: frame.width, height: frame.height/64)))
        negativeWall.position = CGPoint(x: frame.midX, y: frame.minY + 466)
        negativeWall.physicsBody = SKPhysicsBody(rectangleOf: negativeWall.size)
        negativeWall.physicsBody?.affectedByGravity = false
        negativeWall.physicsBody?.allowsRotation = false
        negativeWall.physicsBody?.isDynamic = false
        negativeWall.physicsBody?.friction = 0
        negativeWall.zPosition = 5
        
        addChild(negativeWall)
    }
    
    func createDeleteWall()
    {
        deleteWall = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 1, height: frame.height))
        //deleteWall.size = CGSize(width: 1, height: frame.height)
        deleteWall.position = CGPoint(x: frame.minX + 2, y: frame.midY - 28)
        deleteWall.physicsBody = SKPhysicsBody(rectangleOf: deleteWall.size)
        deleteWall.physicsBody?.affectedByGravity = false
        deleteWall.physicsBody?.isDynamic = false
        deleteWall.physicsBody?.contactTestBitMask = (deleteWall.physicsBody?.collisionBitMask)!

        addChild(deleteWall)
    }

    func createCircle()
    {
        circle = SKSpriteNode(imageNamed: "Positive Charge")
        circle.size = CGSize(width: 50, height: 40)
        circle.position = CGPoint(x: frame.midX - 250, y: frame.midY)
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        circle.physicsBody?.allowsRotation = false
        circle.physicsBody?.isDynamic = true
        circle.physicsBody?.contactTestBitMask = (circle.physicsBody?.collisionBitMask)!
        circle.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(circle)
    }
    
    func createPhoton(xPos: CGFloat, yPos: CGFloat)
    {
        photon = SKSpriteNode(imageNamed: "Light Photon")
        photon.size = CGSize(width: 50, height: 35)
        photon.position = CGPoint(x: xPos, y: yPos)
        //photon.position = CGPoint(x: frame.maxX, y: frame.midY - 165 + CGFloat(randomNumber(MIN: 0, MAX: 330)))
        
        addChild(photon)
        
        photon.physicsBody = SKPhysicsBody(circleOfRadius: 8)
        photon.physicsBody?.applyImpulse(CGVector(dx: -3, dy: 0 - 3 + randomNumber(MIN: 0, MAX: 8)))
        photon.physicsBody?.affectedByGravity = false
        photon.physicsBody?.linearDamping = 0
        photon.physicsBody?.allowsRotation = false
        photon.physicsBody?.restitution = 1.0
        photon.physicsBody?.friction = 0
        photons.append(photon)
    }
    
    func createPhotonCluster()
    {
        atomClusterNum = randomNumber(MIN: 1, MAX: 3)
        if (atomClusterNum == 1)
        {
            atomCluster = SKSpriteNode(imageNamed: "Atom Cluster 1")
        }
        if (atomClusterNum == 2)
        {
            atomCluster = SKSpriteNode(imageNamed: "Atom Cluster 2")
        }
        if (atomClusterNum == 3)
        {
            atomCluster = SKSpriteNode(imageNamed: "Atom Cluster 3")
        }
        atomCluster.position = CGPoint(x: frame.maxX, y: frame.midY - 165 + CGFloat(randomNumber(MIN: 0, MAX: 330)))
        atomCluster.size = CGSize(width: 50, height: 35)
        
        addChild(atomCluster)
        
        atomCluster.physicsBody = SKPhysicsBody(circleOfRadius: 14)
        atomCluster.physicsBody?.applyImpulse(CGVector(dx: -5, dy: 0 - 3 + randomNumber(MIN: 0, MAX: 8)))
        atomCluster.physicsBody?.affectedByGravity = false
        atomCluster.physicsBody?.linearDamping = 0
        atomCluster.physicsBody?.contactTestBitMask = (atomCluster.physicsBody?.collisionBitMask)!
        atomClusters.append(atomCluster)
    }

    func createLifeItem()
    {
        lifeItem = SKSpriteNode(imageNamed: "Life Item")
        lifeItem.position = CGPoint(x: frame.maxX, y: frame.midY - 165 + CGFloat(randomNumber(MIN: 0, MAX: 330)))
        lifeItem.size = circle.size
        
        addChild(lifeItem)
        
        lifeItem.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        lifeItem.physicsBody?.applyImpulse(CGVector(dx: -3, dy: 0))
        lifeItem.physicsBody?.affectedByGravity = false
        lifeItem.physicsBody?.linearDamping = 0
        lifeItem.physicsBody?.friction = 0
        lifeItem.physicsBody?.contactTestBitMask = (lifeItem.physicsBody?.collisionBitMask)!
        lifeItems.append(lifeItem)
    }
    
    func createBackground()
    {
        stars = SKSpriteNode(imageNamed: "background")
        stars.position = CGPoint(x: frame.midX, y: frame.midY)
        stars.size = CGSize(width: frame.width, height: frame.height)
        stars.zPosition = -2
        
        addChild(stars)
    }
    
    func createSwitch()
    {
        wallSwitch = SKSpriteNode(imageNamed: "Wall Swap Item")
        wallSwitch.position = CGPoint(x: frame.maxX, y: frame.midY)
        wallSwitch.size = CGSize(width: 100, height: 75)
        wallSwitch.physicsBody = SKPhysicsBody(circleOfRadius: 23)
        wallSwitch.name = "wallSwitch"
        
        addChild(wallSwitch)
        
        wallSwitch.physicsBody?.affectedByGravity = false
        wallSwitch.physicsBody?.usesPreciseCollisionDetection = true
        wallSwitch.physicsBody?.applyImpulse(CGVector(dx: -7, dy: 0 - 2 + randomNumber(MIN: 0, MAX: 4)))
        wallSwitch.physicsBody?.isDynamic = true
        wallSwitch.physicsBody?.linearDamping = 0
        wallSwitch.physicsBody?.contactTestBitMask = (wallSwitch.physicsBody?.collisionBitMask)!
        switches.append(wallSwitch)
    }
    
    func makeLabel(labelName: SKLabelNode,labelText: String, labelFontSize: CGFloat, labelFontColor: UIColor, labelPosition: CGPoint)
    {
        labelName.text = labelText
        labelName.fontSize = labelFontSize
        labelName.position = labelPosition
        labelName.fontColor = labelFontColor
        
        addChild(labelName)
    }
    
    func scheduledTimerWithTimeInterval()
    {
        scoreTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
        
        photonTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Int(randomNumber(MIN: Int(1.5), MAX: 2))), target: self, selector: #selector(self.createPhotonRepeat), userInfo: nil, repeats: true)
        
        switchTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Int(randomNumber(MIN: 15, MAX: 30))), target: self, selector: #selector(self.createSwitch), userInfo: nil, repeats: true)
        
        lifeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Int(randomNumber(MIN: 10, MAX: 25))), target: self, selector: #selector(self.createLifeItem), userInfo: nil, repeats: true)
        
        clusterTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Int(randomNumber(MIN: 8, MAX: 15))), target: self, selector: #selector(self.createPhotonCluster), userInfo: nil, repeats: true)
    }
    
    func updateCounting()
    {
        NSLog("counting..")
        score += 1
        checkHighScore()
        scoreLabel.text = "Score: \(score)"
    }

    func randomNumber(MIN: Int, MAX: Int)-> Int
    {
        return Int(arc4random_uniform(UInt32(MAX)) + UInt32(MIN));
    }
    
    func checkGameOver()
    {
        if (lives == 0)
        {
            if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion")
            {
                explosion.position = circle.position
                addChild(explosion)
                circle.removeFromParent()
            }
            let gameOverAlert = UIAlertController(title: "Game Over", message: "Score: \(score)", preferredStyle: UIAlertControllerStyle.alert)
            let resetButton = UIAlertAction(title: "Reset", style: UIAlertActionStyle.default, handler:
            {
                (sender) in
                
            self.resetGame()
                
            })
            gameOverAlert.addAction(resetButton)
            self.view?.window?.rootViewController?.present(gameOverAlert, animated: true, completion: nil)
            print("You lost")

        }
    }
    
    func createPhotonRepeat()
    {
        createPhoton(xPos: frame.maxX, yPos: frame.midY - 165 + CGFloat(randomNumber(MIN: 0, MAX: 330)))
    }
    
    func checkHighScore()
    {
        if (score > highScore)
        {
            highScore = score
            highScoreLabel.text = "Highscore: \(highScore)"
        }
    }
    
    func resetBall()
    {
        circle.position.x = frame.midX - 250
        circle.physicsBody?.isDynamic = false
        circle.physicsBody?.isDynamic = true
    }
    
    func resetGame()
    {
        lives = 3
        score = 0
        
        createPositiveWall()
        createNegativeWall()
        createDeleteWall()
        createCircle()
        createBackground()
        createPhoton(xPos: frame.maxX, yPos: frame.midY - 165 + CGFloat(randomNumber(MIN: 0, MAX: 330)))
        photon.removeAllChildren()
        
        scoreLabel.text = "Score: \(score)"
        lifeLabel.text = "Lives: \(lives)"
        
    }
}
