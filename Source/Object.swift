//
//  AppDelegate.swift
//  Downhill Challenge
//
//  Created by Joe on 16/9/22.
//  Copyright © 2016年 Joe Mario. All rights reserved.
//

import Foundation
import SpriteKit


enum Body : UInt32 {
    case snowballBody = 1
    case playerBody = 2
    case treeBody = 4
    case coinBody = 8
    case truck = 16
}

class NewObject {
    var snowballArray = Array<SKTexture>()
    var coinArray = Array<SKTexture>()
    var imageName : String
    var NOxScale : CGFloat
    var NOyScale : CGFloat
    
    init(imageName : String, scaleX : CGFloat, scaleY : CGFloat) {
        self.imageName = imageName
        self.NOxScale = scaleX
        self.NOyScale = scaleY

        let snowballAnimation : SKTextureAtlas = SKTextureAtlas(named: "Snowball.atlas")
        snowballArray.append(snowballAnimation.textureNamed("snowball1"))
        snowballArray.append(snowballAnimation.textureNamed("snowball2"))
        snowballArray.append(snowballAnimation.textureNamed("snowball3"))
        snowballArray.append(snowballAnimation.textureNamed("snowball4"))

        let coinAnimation : SKTextureAtlas = SKTextureAtlas(named: "Coin.atlas")
        coinArray.append(coinAnimation.textureNamed("coin01"))
        coinArray.append(coinAnimation.textureNamed("coin02"))
        coinArray.append(coinAnimation.textureNamed("coin03"))
        coinArray.append(coinAnimation.textureNamed("coin04"))
        coinArray.append(coinAnimation.textureNamed("coin05"))
        coinArray.append(coinAnimation.textureNamed("coin06"))
        coinArray.append(coinAnimation.textureNamed("coin07"))
        coinArray.append(coinAnimation.textureNamed("coin08"))
        coinArray.append(coinAnimation.textureNamed("coin09"))
        coinArray.append(coinAnimation.textureNamed("coin10"))
        coinArray.append(coinAnimation.textureNamed("coin11"))
        coinArray.append(coinAnimation.textureNamed("coin12"))
    }
    
    func addSprite() -> SKSpriteNode {
        let sprite : SKSpriteNode = SKSpriteNode(imageNamed: imageName)
        sprite.xScale = NOxScale
        sprite.yScale = NOyScale
        
        return sprite
    }
    
    func setMovingTree(location : CGPoint, destination : CGPoint, speed : NSTimeInterval) -> SKSpriteNode {
        var result : SKSpriteNode
        result = SKSpriteNode(imageNamed: imageName)
        result.anchorPoint = CGPointMake(0.5, 0.25)
        result.position = location
        result.zPosition = 6
        /*
        let resultScale : CGFloat = randomBetweenNumbers(0.4, secondNum: 0.6)
        result.xScale = resultScale
        result.yScale = resultScale
        */
        result.xScale = NOxScale
        result.yScale = NOyScale
        result.physicsBody = SKPhysicsBody(circleOfRadius: result.size.width * 0.1)
        result.physicsBody!.affectedByGravity = false
        result.physicsBody!.allowsRotation = false
        result.physicsBody!.categoryBitMask = Body.treeBody.rawValue
        result.physicsBody!.contactTestBitMask = 0
        result.physicsBody!.collisionBitMask = 0
        let moveNode = SKAction.moveByX(0.0, y: destination.y, duration: speed)
        let removeNode = SKAction.removeFromParent()
        result.runAction(SKAction.sequence([moveNode, removeNode]), withKey: "tree")
        
        return result
    }
    
    
    func setMovingSnowball(location : CGPoint, destination : CGPoint, speed : NSTimeInterval) -> SKSpriteNode {
        
        var result : SKSpriteNode
        result = SKSpriteNode(imageNamed: imageName)
        
        let snowTrail : SKEmitterNode = SKEmitterNode(fileNamed: "SnowMass.sks")!
        snowTrail.zPosition = -2
        
        result.position = location
        result.zPosition = 5
        result.xScale = NOxScale
        result.yScale = NOyScale
        result.physicsBody = SKPhysicsBody(circleOfRadius: result.size.width / 2)
        result.physicsBody!.affectedByGravity = false
        result.physicsBody!.allowsRotation = false
        result.physicsBody!.mass = 100
        result.physicsBody!.categoryBitMask = Body.snowballBody.rawValue
        result.physicsBody!.contactTestBitMask = Body.playerBody.rawValue | Body.treeBody.rawValue | Body.coinBody.rawValue
        result.physicsBody!.collisionBitMask = 0

        let pauseSnowball = SKAction.waitForDuration(2)
        let animateSnowball = SKAction.animateWithTextures(self.snowballArray, timePerFrame: 0.08)
        let snowballRepeat = SKAction.repeatActionForever(animateSnowball)
        
        result.addChild(snowTrail)
        
        result.runAction(snowballRepeat)
        
        let moveNode = SKAction.moveByX(0.0, y: destination.y, duration: speed)
        let removeNode = SKAction.removeFromParent()
        
        result.runAction(SKAction.sequence([pauseSnowball, moveNode, removeNode]))
        
        return result
    }
    
    func setMovingCoin(location : CGPoint, destination : CGPoint, speed : NSTimeInterval) -> SKSpriteNode {
        var result : SKSpriteNode
        result = SKSpriteNode(imageNamed: imageName)
        result.anchorPoint = CGPointMake(0.5, 0.6)
        result.position = location
        result.xScale = NOxScale
        result.yScale = NOyScale
        result.zPosition = 4
        result.physicsBody = SKPhysicsBody(circleOfRadius: result.size.width / 2)
        result.physicsBody!.affectedByGravity = false
        result.physicsBody!.allowsRotation = false
        result.physicsBody!.categoryBitMask = Body.coinBody.rawValue
        result.physicsBody!.contactTestBitMask = 0
        result.physicsBody!.collisionBitMask = 0
        
        let animateCoin = SKAction.animateWithTextures(self.coinArray, timePerFrame: 0.04)
        let coinRepeat = SKAction.repeatActionForever(animateCoin)
        result.runAction(coinRepeat)
        
        let moveNode = SKAction.moveByX(0.0, y: destination.y, duration: speed)
        let removeNode = SKAction.removeFromParent()
        
        result.runAction(SKAction.sequence([moveNode, removeNode]), withKey: "coin")
        
        return result
    }
    
}