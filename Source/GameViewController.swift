//
//  AppDelegate.swift
//  Downhill Challenge
//
//  Created by Joe on 16/9/22.
//  Copyright © 2016年 Joe Mario. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
// SKNode是SpriteKit框架中的一个核心类  表示游戏中可见的元素
extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! HomeScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    // 在视图已加载并即将显示时被调用
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // 创建一个用于连接到Game Center的对象
        let localPlayer : GKLocalPlayer = GKLocalPlayer.localPlayer()
        // 设置这个对象的身分验证处理程序（authentication handler）为一个闭包  游戏开始时自动调用这个闭包
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if (viewController != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            } else {
                if GKLocalPlayer().authenticated == false {
                    print("Player will be authenticated.")
                }
            }
        }
        // 加载HomeSence对象
        if let scene = HomeScene.unarchiveFromFile("HomeScene") as? HomeScene {
            // 配置视图  变量scene将包含一个引用 指向加载的HomeScene（相应的.sks文件）
            // 让新的变量skView指向该视图控制器的视图 （用as将self.view强制转换为一个SKView对象）
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            scene.size = skView.bounds.size
            
            /* Sprite Kit 执行额外的优化  以提高渲染性能 */
            skView.ignoresSiblingOrder = true
            
            /* 设置缩放模式  让视图适合窗口 */
            scene.scaleMode = .AspectFill
            // 显示前面加载的场景  让场景出现在视图和设备屏幕上
            skView.presentScene(scene)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
