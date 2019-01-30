//
//  ToastView.swift
//  iPets
//
//  Created by maocaiyuan on 16/3/23.
//  Copyright © 2016年 maocaiyuan. All rights reserved.
//

import UIKit

class ToastView: NSObject{
    
    fileprivate var frameMarginSize: CGFloat! = 20 //文字左右间距
    fileprivate var frameSize = CGSize(width: Width-40, height: 60) //大小
    fileprivate var toastView: UIView!
    
    var textFont: CGFloat = 15 //字体大小
    var centerPosition: CGPoint = CGPoint(x: Width/2, y: Height-100)  //位置
    var duration: TimeInterval = 3
    var viewAlpha: CGFloat = 0.7
    
    //根据文字大小和数量，返回一个size
    private func sizeWithString(_ string: NSString, font: UIFont) -> CGSize {
        let dic:NSDictionary = NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
        let options = NSStringDrawingOptions.truncatesLastVisibleLine
        let rect:CGRect = string.boundingRect(with: frameSize, options:options, attributes: dic as? [NSAttributedStringKey : AnyObject], context: nil)
        return rect.size
    }
    
    
    func showToast(_ text: String){
        
        let size = self.sizeWithString(text as NSString, font: UIFont.systemFont(ofSize: textFont))
        
        //显示的lable
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        label.text = text
        label.font = UIFont.systemFont(ofSize: textFont)
        label.numberOfLines = 0
        label.textColor = UIColor.white
        
        //toastView
        toastView = UIView(frame:CGRect(x: 0, y: 0, width: size.width + frameMarginSize, height: size.height + frameMarginSize))
        label.center = CGPoint(x: toastView.frame.size.width / 2, y: toastView.frame.size.height / 2);
        toastView.addSubview(label)
        toastView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: viewAlpha)
        toastView.layer.cornerRadius = 5
        toastView.center = CGPoint(x: centerPosition.x, y: centerPosition.y+10)
        
        //把toast加载到主窗口
        let window = UIApplication.shared.keyWindow!
        window.addSubview(toastView) //用window加，保证最前
        
        //添加定时器，自动消失
        let timer:Timer = Timer(timeInterval: duration, target: self, selector: #selector(hideToast), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    @objc fileprivate func hideToast(){
        UIView.animate(withDuration: 0.2, animations: {
            () -> ()in
            self.toastView.alpha = 0
        }, completion: {
            (Boolean) -> ()in
            self.toastView.removeFromSuperview()
        })
    }
    
}

