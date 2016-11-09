//
//  AppDelegate.swift
//  Downhill Challenge
//
//  Created by Joe on 16/9/22.
//  Copyright © 2016年 Joe Mario. All rights reserved.
//

import UIKit
import SpriteKit
import Foundation
import AVFoundation
import GameKit
// 从SpriteKit类SKScence派生而来  遵守协议GKGameCenterControllerDelegate
class HomeScene: SKScene, GKGameCenterControllerDelegate {
    
    var backgroundMusic = AVAudioPlayer()
    
    let title1 : SKLabelNode = SKLabelNode(text: "Downhill")
    let title2 : SKLabelNode = SKLabelNode(text: "Challenge")
    let playButton : SKLabelNode = SKLabelNode(text: "Play")
    let gamecenter : SKLabelNode = SKLabelNode(text: "Leaderboard")
    // SKEmitterNode对象加载文件Snow.sks
    let snow : SKEmitterNode = SKEmitterNode(fileNamed: "Snow.sks")!
    
    func setLabel(label : SKLabelNode, labelName : String, fontName: String, fontSize : CGFloat, xPos : CGFloat, yPos : CGFloat, fontColor : UIColor) {
        label.name = labelName
        label.fontName = fontName
        label.fontSize = fontSize
        label.position = CGPointMake(xPos, yPos)
        label.fontColor = fontColor
        addChild(label)
    }
    // func(使用一个音频文件创建一个播放器) － 第56行调用  给场景播放背景音乐
    func setupAudioPlayerWithFile(file: String, type: String) -> AVAudioPlayer {
        let path = NSBundle.mainBundle().pathForResource(file, ofType: type)
        let url = NSURL.fileURLWithPath(path!)
        
        var audioPlayer : AVAudioPlayer?
        do {// 创建 AVAudioPlayer 实例的函数可能引发错误
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch let error1 as NSError {
            print("\(error1)")
            audioPlayer = nil
        }
        
        return audioPlayer!
    }
    // （回调函数） 触摸Done按钮时以关闭Game Center排行榜时被调用
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 设置视图 场景Home出现后被调用
    override func didMoveToView(view: SKView) {
        backgroundMusic = setupAudioPlayerWithFile("introSong", type: "mp3")
        backgroundMusic.numberOfLoops = -1  //
        backgroundMusic.volume = 0.25
        backgroundMusic.play()
        
        backgroundColor = UIColor(red: 0, green: 125/255, blue: 1, alpha: 1)
        
        addChild(snow)
        snow.position = CGPointMake(size.width / 2, size.height)
        
        setLabel(title1, labelName: "Title1", fontName: "Papyrus", fontSize: 50, xPos: size.width / 2, yPos: size.height * 0.82, fontColor: UIColor.whiteColor())
        setLabel(title2, labelName: "Title2", fontName: "Papyrus", fontSize: 50, xPos: size.width / 2, yPos: size.height * 0.70, fontColor: UIColor.whiteColor())
        setLabel(playButton, labelName: "Play", fontName: "Papyrus", fontSize: 45, xPos: size.width / 2, yPos: size.height * 0.35, fontColor: UIColor.whiteColor())
        setLabel(gamecenter, labelName: "Leaderboard", fontName: "Papyrus", fontSize: 45, xPos: size.width / 2, yPos: size.height * 0.2, fontColor: UIColor.whiteColor())
    }
    // 创建Cocoa类GKGameCenterViewController的一个实例  并设置排行榜标识符。
    func showLeaderboard() {
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        
        gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        
        gcViewController.leaderboardIdentifier = "dhc.sfb.leaderboard"
        
        let vc : UIViewController = self.view!.window!.rootViewController!
        vc.presentViewController(gcViewController, animated: true, completion: nil)
    }
    
    // （触摸开始时被调用）重写touchesBegan()  将一个UITouch对象集合作为参数
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in (touches ) {
            
            let touchedScreen = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(touchedScreen)
            
            if touchedNode.name == "Play" {
                backgroundMusic.pause()
                let scene = GameScene(size: self.scene!.size)
                self.scene?.view?.presentScene(scene, transition: SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 0.5))
            }
            if touchedNode.name == "Leaderboard" {
                showLeaderboard()
            }
        }
    }
}
