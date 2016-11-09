//
//  AppDelegate.swift
//  Downhill Challenge
//
//  Created by Joe on 16/9/22.
//  Copyright © 2016年 Joe Mario. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import Foundation
import GameKit
import AVFoundation

class GameOverScene : SKScene {
    
    var backgroundMusic = AVAudioPlayer()
    
    let title1 : SKLabelNode = SKLabelNode(text: "Game Over")
    let mainMenu: SKLabelNode = SKLabelNode(text: "Main Menu")
    let restart : SKLabelNode = SKLabelNode(text: "Restart")
    let currentScore : SKLabelNode = SKLabelNode(text: "Score")
    let highScore : SKLabelNode = SKLabelNode(text: "High Score")
    let snow : SKEmitterNode = SKEmitterNode(fileNamed: "Snow.sks")!
    
    let score = NSUserDefaults.standardUserDefaults()
    
    func setLabel(label : SKLabelNode, labelName : String, fontName: String, fontSize : CGFloat, xPos : CGFloat, yPos : CGFloat, fontColor : UIColor) {
        label.name = labelName
        label.fontName = fontName
        label.fontSize = fontSize
        label.position = CGPointMake(xPos, yPos)
        label.fontColor = fontColor
        addChild(label)
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
    
    // 设置视图
    override func didMoveToView(view: SKView) {
        
        backgroundMusic = setupAudioPlayerWithFile("gameOverSong", type: "mp3")
        backgroundMusic.numberOfLoops = -1
        backgroundMusic.play()
        backgroundMusic.volume = 0.25
        
        snow.position = CGPointMake(size.width / 2, size.height)
        addChild(snow)
        
        if let gotCurrentScore = score.valueForKey("currentScore") as? Int {
            score.setInteger(gotCurrentScore, forKey: "currentScore")
            currentScore.text = "Score: \(gotCurrentScore)"
        }
        if let gotScore = score.valueForKey("score") as? Int {
            score.setInteger(gotScore, forKey: "score")
            highScore.text = "Best: \(gotScore)"
        }
        
        setLabel(title1, labelName: "Title1", fontName: "Papyrus", fontSize: 50, xPos: size.width / 2, yPos: size.height * 0.8, fontColor: UIColor.whiteColor())
        setLabel(mainMenu, labelName: "Home", fontName: "Papyrus", fontSize: 35, xPos: size.width / 2, yPos: size.height / 2, fontColor: UIColor.whiteColor())
        setLabel(restart, labelName: "Restart", fontName: "Papyrus", fontSize: 35, xPos: size.width / 2, yPos: (size.height / 2) - (restart.fontSize * 2), fontColor: UIColor.whiteColor())
        setLabel(currentScore, labelName: "CurrentScore", fontName: "Papyrus", fontSize: 25, xPos: size.width / 2, yPos: size.height / 4, fontColor: UIColor.whiteColor())
        setLabel(highScore, labelName: "HighScore", fontName: "Papyrus", fontSize: 25, xPos: size.width / 2, yPos: (size.height / 4) - (currentScore.fontSize * 2), fontColor: UIColor.whiteColor())
    }
    
    
    // 触摸时调用
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in (touches ) {
            
            let touchedScreen = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(touchedScreen)
            
            if touchedNode.name == "Restart" {
                backgroundMusic.pause()
                let scene = GameScene(size: self.scene!.size)
                self.scene?.view?.presentScene(scene, transition: SKTransition.moveInWithDirection(SKTransitionDirection.Down, duration: 0.5))
            }
            if touchedNode.name == "Home" {
                backgroundMusic.pause()
                let scene = HomeScene(size: self.scene!.size)
                self.scene!.view!.presentScene(scene, transition: SKTransition.fadeWithColor(UIColor(red: 0, green: 165/255, blue: 1, alpha: 1), duration: 0.75))
            }
        }
        
    }
    
}