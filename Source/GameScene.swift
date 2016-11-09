//
//  AppDelegate.swift
//  Downhill Challenge
//
//  Created by Joe on 16/9/22.
//  Copyright © 2016年 Joe Mario. All rights reserved.
//

import SpriteKit
import Foundation
import GameKit
import AVFoundation
// 协议SKPhysicsContactDelegate定义了两个方法，用于检测两个对象是否有接触（碰撞检测）
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var backgroundMusic = AVAudioPlayer()
    var coinCounter : Int = 0
    var playerSpeed : CGFloat = 240
    var pSpeed : NSTimeInterval = 200
    var upSpawn : Bool = false
    var actionCounter : Bool = false
    let trailParticle : SKEmitterNode = SKEmitterNode(fileNamed: "SnowParticle.sks")!
    var gameLogic = GameLogic(tSpeed: 4.5, tRespawn: 0.5, sSpeed: 10, sRespawn: 18, cSpeed: 5.2, cRespawn: 0.6, trSpeed: 4, trRespawn: 18)
    var didComeToGame : Bool = true
    
    let number = NSUserDefaults.standardUserDefaults()
    
    let player = NewObject(imageName: "Snowman", scaleX: 0.63, scaleY: 0.63).addSprite()
    
    let snowball = NewObject(imageName: "Snowball", scaleX: 0.7, scaleY: 0.7)
    let tree = NewObject(imageName: "Tree", scaleX: 0.7, scaleY: 0.7)
    let coin = NewObject(imageName: "Coin", scaleX: 0.25, scaleY: 0.25)
    // 创建得分和帮助标签节点、加载滑雪者动画（连续图像的atlas文件）
    var score : SKLabelNode = SKLabelNode(text: "0")
    let help : SKLabelNode = SKLabelNode(text: "Tap or hold sides to move")
    
    let snowmanAnimation : SKTextureAtlas = SKTextureAtlas(named: "Snowman.atlas")
    var snowmanArray = Array<SKTexture>()
    var coinArray = Array<SKTexture>()
    
    /* 在这里设置场景 */
    override func didMoveToView(view: SKView) {
        
        playCoinSound()
        
        snowmanArray.append(snowmanAnimation.textureNamed("Snowman1"))
        snowmanArray.append(snowmanAnimation.textureNamed("Snowman2"))
        snowmanArray.append(snowmanAnimation.textureNamed("Snowman3"))
        
        backgroundMusic = setupAudioPlayerWithFile("mainSong2", type: "mp3")
        backgroundMusic.numberOfLoops = -1
        backgroundMusic.play()
        backgroundMusic.volume = 0.2
        
        self.backgroundColor = UIColor.whiteColor()
        physicsWorld.contactDelegate = self
        
        trailParticle.targetNode = self.scene
        trailParticle.zPosition = 0
        
        // 得分标签
        score.position = CGPointMake(size.width / 2, size.height * 0.90)
        score.fontName = "Papyrus"
        score.fontColor = UIColor.blackColor()
        score.fontSize = 40
        score.zPosition = 10
        
        help.position = CGPointMake(size.width / 2, size.height / 2)
        help.fontName = "Papyrus"
        help.fontColor = UIColor.blackColor()
        help.fontSize = 25
        help.zPosition = 10
        
        setPlayer()
        
        addChild(help)
        snowmanAnimate()
    }
    
    func playCoinSound() {
        let playSound : SKAction = SKAction.playSoundFileNamed("coinSound.mp3", waitForCompletion: true)
        let removeSound : SKAction = SKAction.removeFromParent()
        self.runAction(SKAction.sequence([playSound, removeSound]), withKey: "theCoinSound")
        self.removeActionForKey("theCoinsound")
    }
    
    func setupAudioPlayerWithFile(file: String, type: String) -> AVAudioPlayer {
        let path = NSBundle.mainBundle().pathForResource(file, ofType: type)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer : AVAudioPlayer?
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch let error1 as NSError {
            print("\(error1)")
            audioPlayer = nil
        }
        return audioPlayer!
    }
    
    // 创建滑雪者
    func setPlayer() {
        player.addChild(trailParticle)
        player.anchorPoint = CGPoint(x: 0.5, y: 0.25)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 4)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.categoryBitMask = Body.playerBody.rawValue
        player.physicsBody!.contactTestBitMask = Body.treeBody.rawValue | Body.coinBody.rawValue
        player.physicsBody!.collisionBitMask = 0
        player.zPosition = 1
        player.position = CGPointMake(size.width / 2, size.height / 1.35)
        addChild(player)
    }
    
    func reportLeaderboard(x : Int64) {
        //scoreObject.context = 0
        let scoreObject : GKScore = GKScore(leaderboardIdentifier: "dhc.sfb.leaderboard")
        scoreObject.context = 0
        scoreObject.value = x
        GKScore.reportScores([scoreObject], withCompletionHandler: {(error) -> Void in})
    }
    
    func getScores() {
        if GKLocalPlayer.localPlayer().authenticated {
            reportLeaderboard(Int64(coinCounter))
        } else {
            print("Not authenticated.", terminator: "")
        }
        if let gotScore = number.valueForKey("score") as? Int {
            if coinCounter > gotScore {
                number.setInteger(coinCounter, forKey: "score")
            }
        } else {
            number.setInteger(coinCounter, forKey: "score")
        }
        number.setInteger(coinCounter, forKey: "currentScore")
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func runActions(runTree runTree: Bool, runSnowball: Bool, runCoin: Bool, runTruck : Bool) {
        if runTree == true {
            self.removeActionForKey("tree")
            runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(moveTree),SKAction.waitForDuration(gameLogic.treeRespawn)])), withKey: "tree")
        }
        if runSnowball == true {
            self.removeActionForKey("snowball")
            runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(moveSnowball),SKAction.waitForDuration(gameLogic.snowballRespawn)])), withKey: "snowball")
        }
        if runCoin == true {
            self.removeActionForKey("coin")
            runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(moveCoin),SKAction.waitForDuration(gameLogic.coinRespawn)])), withKey: "coin")
        }
        if runTruck == true {
            self.removeActionForKey("truck")
            runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(moveTruck),SKAction.waitForDuration(gameLogic.truckRespawn)])), withKey: "truck")
        }
    }
    // 创建一个SKAction对象
    func snowmanAnimate() {
        let animateAction = SKAction.animateWithTextures(self.snowmanArray, timePerFrame: 0.10)
        let repeatAction = SKAction.repeatActionForever(animateAction)
        player.runAction(repeatAction)
    }
    
    /* Called when a touch begins */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in (touches ) {
            
            if didComeToGame == false {
                let touchedScreen = touch.locationInNode(self)
                
                let distanceResultRight : CGFloat = (size.width - player.position.x) / playerSpeed
                let distanceResultLeft : CGFloat = (player.position.x) / playerSpeed
                let time1 : NSTimeInterval = NSTimeInterval(distanceResultRight)
                let time2 : NSTimeInterval = NSTimeInterval(distanceResultLeft)
                if touchedScreen.x < size.width / 2 {
                    player.runAction(movePlayer(0.0, time: time2))
                }
                if touchedScreen.x > size.width / 2 {
                    player.runAction(movePlayer(size.width, time: time1))
                }
            } else if didComeToGame == true {
                runActions(runTree: true, runSnowball: false, runCoin: true, runTruck: false)
                self.addChild(score)
                help.removeFromParent()
                didComeToGame = false
            }
            
        }
    }
    
    func findDistance(pointA : CGFloat, pointB : CGFloat) -> NSTimeInterval {
        let distancePartA = pointA - pointB
        let distancePartB = distancePartA * distancePartA
        let distancePartC : NSTimeInterval = NSTimeInterval(sqrt(distancePartB))
        let time : NSTimeInterval = distancePartC / pSpeed
        return time
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        player.removeAllActions()
        snowmanAnimate()
    }
    
    func gameOver() {
        getScores()
        backgroundMusic.pause()
        self.removeAllActions()
        let scene = GameOverScene(size: self.scene!.size)
        self.scene?.view?.presentScene(scene, transition: SKTransition.moveInWithDirection(SKTransitionDirection.Up, duration: 0.5))
    }
    // 检测滑雪者是否与其它对象（树木、金币）发生碰撞的核心方法，由SpriteKit自动调用
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody, secondBody : SKPhysicsBody
    // 接受一个SKPhysicsContact对象  包含两个发生碰撞的对象  每个对象都有一个categoryBitMask属性
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        let contactMask = firstBody.categoryBitMask | secondBody.categoryBitMask
        // 根据contactMask对象决定要采取的措施
        switch(contactMask) {
        case 3:
            // 大雪球与滑雪者碰撞
            secondBody.node?.removeFromParent()
            gameOver()
        case 5:
            // 大雪球与树碰撞
            secondBody.node?.removeFromParent()
        case 9:
            // 大雪球与金币碰撞
            secondBody.node?.removeFromParent()
        case 6:
            // 滑雪者与树碰撞
            firstBody.node?.removeFromParent()
            gameOver()
        case 10:
            // 滑雪者与金币碰撞
            //self.coinSound.play()
            playCoinSound()
            coinCounter += 1
            score.text = "\(coinCounter)"
            secondBody.node?.removeFromParent()
        case 17:
            // 卡车与大雪球碰撞
            firstBody.node?.removeFromParent()
        case 18:
            // 卡车与滑雪者碰撞
            firstBody.node?.removeFromParent()
            gameOver()
        case 20:
            // 卡车与树碰撞
            firstBody.node?.removeFromParent()
        case 24:
            // 卡车与金币碰撞
            firstBody.node?.removeFromParent()
        case 33:
            // 卡车激起的雪与大雪球碰撞
            firstBody.node?.removeFromParent()
        case 36:
            // 卡车激起的雪与树碰撞
            firstBody.node?.removeFromParent()
        case 40:
            // 卡车激起的雪与金币碰撞
            firstBody.node?.removeFromParent()
        default:
            return
        }
    }
    
    // 声明各个游戏对象
    // 滑雪者
    func movePlayer(direction : CGFloat, time : NSTimeInterval) -> SKAction {
        let playerMove : SKAction = SKAction.moveToX(direction, duration: time)
        return playerMove
    }
    // 位置随机 速度特定的树
    func moveTree() {
        addChild(tree.setMovingTree(randomTreeLocation(), destination: CGPoint(x: 0, y: size.height * 2), speed: gameLogic.treeSpeed))
    }
    // 雪球
    func moveSnowball() {
        addChild(snowball.setMovingSnowball(randomSnowballLocation(), destination: CGPoint(x: 0, y: -size.height * 2), speed: gameLogic.snowballSpeed))
    }
    // 金币
    func moveCoin() {
        addChild(coin.setMovingCoin(randomCoinLocation(), destination: CGPoint(x: 0, y: size.height * 2), speed: gameLogic.coinSpeed))
    }
    // 卡车
    func moveTruck() {
        let truck : SKSpriteNode = SKSpriteNode(imageNamed: "SnowTruck")
        let truckParticle : SKEmitterNode = SKEmitterNode(fileNamed: "TruckParticle.sks")!
        truckParticle.position = CGPointMake(truck.size.width / 2, truck.size.height)
        
        truckParticle.zPosition = 10
        
        truck.position = randomTruckLocation()
        truck.xScale = 1
        truck.yScale = 1
        
        truck.physicsBody = SKPhysicsBody(rectangleOfSize: truck.size)
        truck.zPosition = 5
        truck.physicsBody!.affectedByGravity = false
        truck.physicsBody!.allowsRotation = false
        truck.physicsBody!.categoryBitMask = Body.truck.rawValue
        truck.physicsBody!.contactTestBitMask = Body.playerBody.rawValue | Body.treeBody.rawValue | Body.coinBody.rawValue
        truck.physicsBody!.collisionBitMask = 0
        
        let moveTruck = SKAction.moveTo(CGPointMake(player.position.x, player.position.y + (player.size.height * 2.2)), duration: NSTimeInterval(gameLogic.truckSpeed))
        let moveTruck2 = SKAction.moveByX(0, y: -size.height * 1.5, duration: gameLogic.truckSpeed)
        let removeTruck = SKAction.removeFromParent()
        
        addChild(truck)
        truck.addChild(truckParticle)
        
        truck.runAction(SKAction.sequence([moveTruck, moveTruck2, removeTruck]))
    }
    
    // 设置游戏对象产生的位置
    func randomTruckLocation() -> CGPoint {
        var result : CGPoint
        let randomNumber : UInt32 = arc4random_uniform(UInt32(size.width))
        result = CGPoint(x: CGFloat(randomNumber), y: size.height + 200)
        
        return result
    }
    
    func randomTreeLocation() -> CGPoint {
        var result : CGPoint
        let randomNumber : UInt32 = arc4random_uniform(UInt32(size.width))
        result = CGPoint(x: CGFloat(randomNumber), y: -100)
        
        return result
    }
    
    func randomSnowballLocation() -> CGPoint {
        var result : CGPoint
        let randomNumber : UInt32 = arc4random_uniform(UInt32(size.width))
        result = CGPoint(x: CGFloat(randomNumber), y: size.height + 200)
        
        return result
    }
    
    func randomCoinLocation() -> CGPoint {
        var result : CGPoint
        let randomNumber : UInt32 = arc4random_uniform(UInt32(size.width))
        result = CGPoint(x: CGFloat(randomNumber), y: -100)
        
        return result
    }
    
    /* 在渲染每一帧之前被调用 update() from class of SKScence  */
    override func update(currentTime: CFTimeInterval) {
        switch coinCounter {
        case 15:
            if upSpawn == false {
                gameLogic.treeRespawn = 0.3
                upSpawn = true
            }
        case 25:
            if upSpawn == false {
                gameLogic.treeRespawn = 0.22
                upSpawn = true
            }
        case 50:
            if upSpawn == false {
                playerSpeed += 5
                gameLogic.treeRespawn  = 0.18
                upSpawn = true
            }
        case 100:
            if upSpawn == false {
                gameLogic.snowballRespawn = 10
                gameLogic.treeRespawn  = 0.15
                upSpawn = true
            }
        case 200:
            if upSpawn == false {
                gameLogic.truckRespawn = 13
                upSpawn = true
            }
        default:
            upSpawn = false
        }
    }
    // didEvaluateActions() from class of SKScene 重写该方法
    override func didEvaluateActions() {
        switch coinCounter {
        case 15:
            if actionCounter == false {
                //gameLogic.treeRespawn = 0.3
                runActions(runTree: true, runSnowball: true, runCoin: false, runTruck: false)
                actionCounter = true
            }
        case 25:
            if actionCounter == false {
                runActions(runTree: true, runSnowball: false, runCoin: true, runTruck: false)
                actionCounter = true
            }
        case 50:
            if actionCounter == false {
                runActions(runTree: true, runSnowball: false, runCoin: false, runTruck: true)
                actionCounter = true
            }
        case 100:
            if actionCounter == false {
                runActions(runTree: true, runSnowball: true, runCoin: false, runTruck: false)
                actionCounter = true
            }
        case 200:
            if actionCounter == false {
                runActions(runTree: false, runSnowball: false, runCoin: false, runTruck: true)
                actionCounter = true
            }
        default:
            actionCounter = false
        }
    }
}