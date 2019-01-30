//
//  ResultColorView.swift
//  MagicCubeFaster
//
//  Created by maocaiyuan on 2019/1/23.
//  Copyright © 2019 maocaiyuan. All rights reserved.
//

import Foundation
import UIKit

class ResultColorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateColor(color: [Int]){
        //移除所有子试图
        _ = self.subviews.map {
            $0.removeFromSuperview()
        }
        
        let _width = self.frame.size.width/3
        let _height = self.frame.size.height/3
        
        for i in 0 ... 8{
            let view = UIView(frame: CGRect(x: CGFloat(i%3) * CGFloat(_width), y: CGFloat(i/3) * CGFloat(_height), width: _width, height: _height))
            if(color[i] >= 0 && color[i] < 6){
                view.backgroundColor = UIColorArray[color[i]]
            }else{
                view.backgroundColor = UIColor.black
            }
            self.addSubview(view)
        }
    }
}
