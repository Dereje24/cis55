//
//  GameObject.swift
//  GameofSingle15
//
//  Created by Koichi Okada on 6/7/16.
//  Copyright © 2016 GregSimons. All rights reserved.
//

import UIKit

class GameObject: NSObject {
    var dimensionX: Int = 0
    var dimensionY: Int = 0
    var gameTime: Int = 0
    var theme: String = ""
    
    init(x: Int, y: Int, gameTime: Int, theme: String) {
        self.dimensionX = x
        self.dimensionY = y
        self.gameTime = gameTime
        self.theme = theme
    }
}
