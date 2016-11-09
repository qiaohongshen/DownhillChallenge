//
//  AppDelegate.swift
//  Downhill Challenge
//
//  Created by Joe on 16/9/22.
//  Copyright © 2016年 Joe Mario. All rights reserved.
//

import Foundation
import SpriteKit

class GameLogic {
    
    var treeSpeed : NSTimeInterval
    var treeRespawn : NSTimeInterval
    var snowballSpeed : NSTimeInterval
    var snowballRespawn : NSTimeInterval
    var coinSpeed : NSTimeInterval
    var coinRespawn : NSTimeInterval
    var truckSpeed : NSTimeInterval
    var truckRespawn : NSTimeInterval
    
    init(tSpeed: NSTimeInterval, tRespawn: NSTimeInterval, sSpeed: NSTimeInterval, sRespawn: NSTimeInterval, cSpeed: NSTimeInterval, cRespawn: NSTimeInterval, trSpeed: NSTimeInterval, trRespawn: NSTimeInterval){
        self.treeSpeed = tSpeed
        self.treeRespawn = tRespawn
        self.snowballSpeed = sSpeed
        self.snowballRespawn = sRespawn
        self.coinSpeed = cSpeed
        self.coinRespawn = cRespawn
        self.truckSpeed = trSpeed
        self.truckRespawn = trRespawn
    }
 }