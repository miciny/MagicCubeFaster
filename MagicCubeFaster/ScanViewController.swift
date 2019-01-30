//
//  ScanViewController.swift
//  MagicCubeFaster
//
//  Created by maocaiyuan on 2019/1/21.
//  Copyright © 2019 maocaiyuan. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

protocol ScanViewViewDelegate{
    func comfirmClicked(image: UIImage, index: Int, data: [Int])
}


class ScanViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    var delegate: ScanViewViewDelegate?
    
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    let showColorView = ResultColorView()
    var isStart = false
    var timer : Timer?  //1s扫描一次
    
    var scanIndex = 0 //扫描的第几面
    var colorArray: [Int] = [-1, -1, -1, -1, -1, -1, -1, -1, -1]
    var confirmBtn = UIButton() //确认按钮
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpEles()
        startTimer()
    }
    
    //设置title 等
    func setUpEles(){
        self.title = "扫描"
        self.view.backgroundColor = UIColor.gray
        
        //界面中间的扫描框
        let imageView = UIImageView(frame: CGRect(x: 20, y: Height/2 - (Width-40)/2, width: Width-40, height: Width-40))
        imageView.image = UIImage(named:"ScanBg")
        self.view.addSubview(imageView)
        
        let borderImageView = UIImageView()
        borderImageView.center = CGPoint(x: imageView.center.x-20, y: imageView.center.y-20)
        borderImageView.frame.size = CGSize(width: 40, height: 40)
        borderImageView.image = UIImage(named:"ColorBorder")
        self.view.addSubview(borderImageView)
        
        //扫描动画的线
        let animationLine = UIView(frame: CGRect(x: 50, y: Height/2 - (Width-40)/2 + 20, width: Width-100, height: 5))
        animationLine.backgroundColor = UIColor.green
        let animation = scanAnimation()
        animationLine.layer.add(animation, forKey: "")
        self.view.addSubview(animationLine)
        
        //预览
        showColorView.frame = CGRect(x: Width-180, y: Height-180, width: 180, height: 180)
        showColorView.backgroundColor = UIColor.lightGray
        self.view.addSubview(showColorView)
        
        //确认按钮
        confirmBtn.frame = CGRect(x: 20, y: Height-100, width: 120, height: 44)
        confirmBtn.backgroundColor = UIColor.gray
        confirmBtn.setTitle("确定", for: .normal)
        confirmBtn.setTitleColor(UIColor.white, for: .normal)
        confirmBtn.addTarget(self, action: #selector(self.confirmData), for: .touchUpInside)
        self.view.addSubview(confirmBtn)
    }
    
    //确认按钮
    @objc func confirmData(){
        for cc in colorArray {
            if(cc == -1){
                ToastView().showToast("扫描未成功！")
                return
            }
        }
        
        self.delegate?.comfirmClicked(image: getImageFromView(view: self.showColorView), index: self.scanIndex, data: self.colorArray)
        self.stopTimer()
        self.navigationController?.popViewController(animated: true)
    }
    
    //将某个view 转换成图像
    func getImageFromView(view: UIView) ->UIImage{
        UIGraphicsBeginImageContext(view.bounds.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    //动画
    func scanAnimation() -> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.toValue = (Width-40) - 40
        animation.duration = 3
        animation.isRemovedOnCompletion = false
        animation.repeatCount = 1/0
        return animation
    }
    
    
    //界面出现时，初始化摄像头
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupCamera()
        self.isStart = true
        print("开始扫描")
    }
    
    //界面消失时，关闭
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.captureSession.isRunning {
            self.captureSession.stopRunning()
        }
        self.isStart = false
        print("结束扫描")
    }
    
    //初始化摄像头
    func setupCamera(){
        self.captureSession.sessionPreset = AVCaptureSession.Preset.high
        var error : NSError?
        let input: AVCaptureDeviceInput!
        self.captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        //获取权限等
        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        //如果设备不允许，显示提示并返回
        if (error != nil && input == nil) {
            let deleteAlertView = UIAlertController(title: "提醒", message: "请在iPhone的\"设置-隐私-相机\"选项中,允许本程序访问您的相机", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            deleteAlertView.addAction(cancelAction)
            self.present(deleteAlertView, animated: true, completion: nil)
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //可以看到的镜头区域
        previewLayer!.frame = CGRect(x: 0, y: 64, width: Width, height: Height-64)
        self.view.layer.insertSublayer(self.previewLayer!, at: 0)
        
        let output = AVCaptureVideoDataOutput()
        //设置响应区域
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA] as [String : Any]
        }
        captureSession.startRunning()
    }
    
    //获得图片
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard self.isStart == true else {
            return
        }
        
        if let resultImage = sampleBuffer.getBuffferCIImage(){
            let centerColor0 = resultImage.getPixelColor(xP: 0.34, yP: 0.75)
            let centerColor1 = resultImage.getPixelColor(xP: 0.34, yP: 0.5)
            let centerColor2 = resultImage.getPixelColor(xP: 0.34, yP: 0.25)
            let centerColor3 = resultImage.getPixelColor(xP: 0.5, yP: 0.75)
            
            let centerColor5 = resultImage.getPixelColor(xP: 0.5, yP: 0.25)
            let centerColor6 = resultImage.getPixelColor(xP: 0.66, yP: 0.75)
            let centerColor7 = resultImage.getPixelColor(xP: 0.66, yP: 0.5)
            let centerColor8 = resultImage.getPixelColor(xP: 0.66, yP: 0.25)
            
            let centerColor = resultImage.getPixelColor(xP: 0.5, yP: 0.5)
            
            colorArray[0] = centerColor0
            colorArray[1] = centerColor1
            colorArray[2] = centerColor2
            colorArray[3] = centerColor3
            
            colorArray[4] = centerColor
            
            colorArray[5] = centerColor5
            colorArray[6] = centerColor6
            colorArray[7] = centerColor7
            colorArray[8] = centerColor8
        }
        self.isStart = false
        
        //显示预览图
        showColorView.updateColor(color: colorArray)
    }
    
    // 2.开始计时
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updataSecond), userInfo: nil, repeats: true)
        //调用fire()会立即启动计时器
        timer!.fire()
    }
    
    // 3.定时操作
    @objc func updataSecond() {
        self.isStart = true
    }
    
    // 4.停止计时
    func stopTimer() {
        if timer != nil {
            timer!.invalidate() //销毁timer
            timer = nil
        }
    }
}


//CMSampleBuffer 转为 UIImage
extension CMSampleBuffer {
    func getBuffferCIImage() -> CIImage? {
        if let buffer = CMSampleBufferGetImageBuffer(self) {
            let ciImage = CIImage(cvPixelBuffer: buffer)
            return ciImage
        }
        return nil
    }
    
    func getBuffferUIImage() -> UIImage? {
        if let buffer = CMSampleBufferGetImageBuffer(self) {
            let ciImage = CIImage(cvPixelBuffer: buffer)
            let uiImage = UIImage.init(ciImage: ciImage, scale: 1.0, orientation: .right)
            return uiImage
        }
        return nil
    }
}

//获取图片某一点的颜色
extension CIImage {
    //xy为长高的比例
    func getPixelColor(xP: CGFloat, yP: CGFloat) -> Int {
        
        let ciContext = CIContext.init()
        let cgImage: CGImage = ciContext.createCGImage(self, from: self.extent)!
        
        //修正监测点,宽高是横向的
        let xx = CGFloat(cgImage.width) * xP - 32*CGFloat(cgImage.height)/Height
        let yy = CGFloat(cgImage.height) * yP
        let posOffset = CGPoint(x: xx, y: yy)
        
        let provider = cgImage.dataProvider
        let pixelData = provider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(cgImage.width) * Int(posOffset.y)) + Int(posOffset.x)) * 4
        let r = Float(data[pixelInfo])
        let g = Float(data[pixelInfo+1])
        let b = Float(data[pixelInfo+2])
        //let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)  //alpha值，暂时不用
        
        let cc = CubeColor.init(Yellow: Yellow, Red: Red, Blue: Blue, White: White, Orange: Orange, Green: Green)
        let theValue: Float = 140
        var difference: Float = 0
        
        difference = pow( pow((r-cc.Yellow[0]), 2) + pow((g-cc.Yellow[1]), 2) + pow((b-cc.Yellow[2]), 2), 0.5)
        if(difference < theValue){
            return 0
        }
        difference = pow( pow((r-cc.Blue[0]), 2) + pow((g-cc.Blue[1]), 2) + pow((b-cc.Blue[2]), 2), 0.5)
        if(difference < theValue){
            return 2
        }
        difference = pow( pow((r-cc.White[0]), 2) + pow((g-cc.White[1]), 2) + pow((b-cc.White[2]), 2), 0.5)
        if(difference < theValue){
            return 3
        }
        difference = pow( pow((r-cc.Green[0]), 2) + pow((g-cc.Green[1]), 2) + pow((b-cc.Green[2]), 2), 0.5)
        if(difference < theValue){
            return 5
        }
        difference = pow( pow((r-cc.Red[0]), 2) + pow((g-cc.Red[1]), 2) + pow((b-cc.Red[2]), 2), 0.5)
        if(difference < theValue){
            return 1
        }
        difference = pow( pow((r-cc.Orange[0]), 2) + pow((g-cc.Orange[1]), 2) + pow((b-cc.Orange[2]), 2), 0.5)
        if(difference < theValue){
            return 4
        }
        return -1
    }
}
