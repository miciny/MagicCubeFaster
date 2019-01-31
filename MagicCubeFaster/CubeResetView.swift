//
//  CubeResetView.swift
//  MagicCubeFaster
//
//  Created by maocaiyuan on 2019/1/31.
//  Copyright © 2019 maocaiyuan. All rights reserved.
//

import Foundation
import UIKit

class CubeResetView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateColor(color: [String]){
        //移除所有子试图
        _ = self.subviews.map {
            $0.removeFromSuperview()
        }
        let _width = self.frame.size.width/4
        let cor = getIntFromString(color: color)
        
        let v1 = ResultColorView(frame: CGRect(x: _width, y: self.frame.size.height/2-_width/2, width: _width, height: _width))
        v1.updateColor(color: cor[0])
        let v2 = ResultColorView(frame: CGRect(x: 0, y: self.frame.size.height/2-_width/2, width: _width, height: _width))
        v2.updateColor(color: cor[1])
        let v3 = ResultColorView(frame: CGRect(x: _width*2, y: self.frame.size.height/2-_width/2, width: _width, height: _width))
        v3.updateColor(color: cor[2])
        let v4 = ResultColorView(frame: CGRect(x: _width*3, y: self.frame.size.height/2-_width/2, width: _width, height: _width))
        v4.updateColor(color: cor[3])
        let v5 = ResultColorView(frame: CGRect(x: _width, y: self.frame.size.height/2-_width*3/2, width: _width, height: _width))
        v5.updateColor(color: cor[4])
        let v6 = ResultColorView(frame: CGRect(x: _width, y: self.frame.size.height/2+_width/2, width: _width, height: _width))
        v6.updateColor(color: cor[5])
        
        self.addSubview(v1)
        self.addSubview(v2)
        self.addSubview(v3)
        self.addSubview(v4)
        self.addSubview(v5)
        self.addSubview(v6)
    }
    
    func getIntFromString(color: [String]) -> [[Int]]{
        var a = [[Int]](repeating: [Int](repeating: -1, count: 9), count: 6)
        let b = strToInt(color: color)
        for j in 0 ..< 6{
            if j == 0{
                for i in 0 ..< 9{
                    a[j][i] = b[i%3 + 12*(i/3) + 9]
                }
            }else if j == 1{
                for i in 0 ..< 9{
                    a[j][i] = b[i%3 + 12*(i/3) + 18]
                }
            }else if j == 2{
                for i in 0 ..< 9{
                    a[j][i] = b[i%3 + 12*(i/3) + 12]
                }
            }else if j == 3{
                for i in 0 ..< 9{
                    a[j][i] = b[i%3 + 12*(i/3) + 15]
                }
            }else if j == 4{
                for i in 0 ..< 9{
                    a[j][i] = b[i]
                }
            }else if j == 5{
                for i in 0 ..< 9{
                    a[j][i] = b[i+45]
                }
            }
        }
        
        
        return a
    }
    
    func strToInt(color: [String]) -> [Int]{
        var a = [Int]()
        for i in color{
            a.append(getInt(str: i))
        }
        return a
    }
    
    func getInt(str: String) -> Int{
        switch str {
        case "y": return 0
        case "r": return 1
        case "b": return 2
        case "w": return 3
        case "o": return 4
        case "g": return 5
        default: return 0
        }
    }
}
