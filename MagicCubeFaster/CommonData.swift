//
//  CommonData.swift
//  MagicCubeFaster
//
//  Created by maocaiyuan on 2019/1/21.
//  Copyright © 2019 maocaiyuan. All rights reserved.
//

import Foundation
import UIKit

let Width = UIScreen.main.bounds.width
let Height = UIScreen.main.bounds.height

// 0 1 2 3 4 5 对应下面的顺序
struct CubeColor {
    var Yellow : [Float]
    var Red : [Float]
    var Blue : [Float]
    var White : [Float]
    var Orange : [Float]
    var Green : [Float]
}

let Yellow : [Float] = [255, 255, 11]
let Red : [Float] = [128, 25, 25]
let Blue : [Float] = [0, 0, 254]
let White : [Float] = [255, 255, 255]
let Orange : [Float] = [250, 85, 55]
let Green : [Float] = [32, 232, 8]

let UIColorArray = [UIColor.yellow, UIColor.red, UIColor.blue, UIColor.white, UIColor.orange, UIColor.green]
