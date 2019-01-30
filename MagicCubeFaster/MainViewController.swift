//
//  ViewController.swift
//  MagicCubeFaster
//
//  Created by maocaiyuan on 2019/1/21.
//  Copyright © 2019 maocaiyuan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController{
    
    var scanView1 = UIImageView()   //中间
    var scanView2 = UIImageView()   //左边
    var scanView3 = UIImageView()   //右边
    var scanView4 = UIImageView()   //右边的右边
    var scanView5 = UIImageView()   //上边
    var scanView6 = UIImageView()   //下边
    
    var confirmBtn = UIButton() //确认按钮
    var resultView = UITextView() //结果显示
    
    var timer : Timer?
    var isClaculating = false
    
    var cubeData = [String](repeating: "nil", count: 54)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGray
        self.title = "首页"
        self.setEles()
    }

    func setEles(){
        scanView1 = getImageView(index: 0)
        scanView1.center = CGPoint(x: Width/2-scanView1.frame.size.width/2, y: Height/2-scanView1.frame.size.width)
        scanView2 = getImageView(index: 1)
        scanView2.center = CGPoint(x: Width/2-scanView1.frame.size.width*3/2, y: Height/2-scanView1.frame.size.width)
        scanView3 = getImageView(index: 2)
        scanView3.center = CGPoint(x: Width/2+scanView1.frame.size.width/2, y: Height/2-scanView1.frame.size.width)
        scanView4 = getImageView(index: 3)
        scanView4.center = CGPoint(x: Width/2+scanView1.frame.size.width*3/2, y: Height/2-scanView1.frame.size.width)
        scanView5 = getImageView(index: 4)
        scanView5.center = CGPoint(x: Width/2-scanView1.frame.size.width/2, y: Height/2-2*scanView1.frame.size.width)
        scanView6 = getImageView(index: 5)
        scanView6.center = CGPoint(x: Width/2-scanView1.frame.size.width/2, y: Height/2)
        
        //结果显示
        resultView.frame = CGRect(x: 20, y: scanView6.frame.maxY+20, width: Width-40, height: 100)
        resultView.text = "请扫描魔方!"
        self.view.addSubview(resultView)
        
        //确认按钮
        confirmBtn.frame = CGRect(x: 20, y: resultView.frame.maxY+20, width: Width-40, height: 44)
        confirmBtn.backgroundColor = UIColor.white
        confirmBtn.setTitle("开始计算", for: .normal)
        confirmBtn.setTitleColor(UIColor.black, for: .normal)
        confirmBtn.addTarget(self, action: #selector(self.calculate), for: .touchUpInside)
        self.view.addSubview(confirmBtn)
    }
    
    //开始计算
    @objc func calculate(){
        if(self.cubeData.contains("nil")){
            ToastView().showToast("请继续扫描!")
            return
        }
        if(isClaculating){
            ToastView().showToast("计算中!")
            return
        }
        let solver = ThistlethwaiteArithmetic()
        self.startTimer()
        
        let myQueue = DispatchQueue(label: "myQueue")  //
        isClaculating = true
        let data = self.getColorUFDBLRStr()
        
        myQueue.async {
//            let data = ["FU", "DR", "FD", "DL", "FR", "UR", "FL", "UL", "DB", "LB", "RB", "UB", "LBD", "ULF", "RBU", "DRF", "RDB", "UFR", "LUB", "DFL"]
            let time1 = CACurrentMediaTime()
            let resolverStr = solver.calculateBegin(argv: data)
            let time2 = CACurrentMediaTime()
            DispatchQueue.main.async {
                self.stopTimer()
                self.resultView.text = resolverStr + "\n时间: " + String(format: "%.3f", time2-time1) + "s"
                self.isClaculating = false
            }
        }
    }

    //开始扫描
    @objc func scan(_ sender: UITapGestureRecognizer){
        let view = sender.view as! UIImageView
        let vc = ScanViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.delegate = self
        vc.scanIndex = view.tag
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getImageView(index: Int) -> UIImageView{
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: (Width-20)/4, height: (Width-20)/4)
        imageView.image = UIImage(named: "AddScan")
        imageView.tag = index
        
        let imgClick = UITapGestureRecognizer(target: self, action: #selector(self.scan))
        imageView.addGestureRecognizer(imgClick)
        imageView.isUserInteractionEnabled = true
        
        self.view.addSubview(imageView)
        return imageView
    }
    
    
    //通过cubedata转为String
    //根据颜色，转为UFDBLR字符串
    func getColorUFDBLRStr() -> [String]{
        let U = self.cubeData[4]
        let F = self.cubeData[22]
        let R = self.cubeData[25]
        let B = self.cubeData[28]
        let L = self.cubeData[31]
        let D = self.cubeData[49]
        for i in 0 ..< self.cubeData.count{
            if(U == self.cubeData[i]){
                self.cubeData[i] = "U"
            }else if(F == self.cubeData[i]){
                self.cubeData[i] = "F"
            }else if(R == self.cubeData[i]){
                self.cubeData[i] = "R"
            }else if(B == self.cubeData[i]){
                self.cubeData[i] = "B"
            }else if(L == self.cubeData[i]){
                self.cubeData[i] = "L"
            }else if(D == self.cubeData[i]){
                self.cubeData[i] = "D"
            }
        }
        
        //拼接
        var str = [String]()
        //"UF", "UR", "UB", "UL"
        str.append(self.cubeData[7]+self.cubeData[10])
        str.append(self.cubeData[5]+self.cubeData[13])
        str.append(self.cubeData[1]+self.cubeData[16])
        str.append(self.cubeData[3]+self.cubeData[19])
        //"DF", "DR", "DB", "DL"
        str.append(self.cubeData[46]+self.cubeData[34])
        str.append(self.cubeData[50]+self.cubeData[37])
        str.append(self.cubeData[52]+self.cubeData[40])
        str.append(self.cubeData[48]+self.cubeData[43])
        //"FR", "FL"
        str.append(self.cubeData[23]+self.cubeData[24])
        str.append(self.cubeData[21]+self.cubeData[32])
        //"BR", "BL"
        str.append(self.cubeData[27]+self.cubeData[26])
        str.append(self.cubeData[29]+self.cubeData[30])
        //"UFR", "URB", "UBL", "ULF"
        str.append(self.cubeData[8]+self.cubeData[11]+self.cubeData[12])
        str.append(self.cubeData[2]+self.cubeData[14]+self.cubeData[15])
        str.append(self.cubeData[0]+self.cubeData[17]+self.cubeData[18])
        str.append(self.cubeData[6]+self.cubeData[20]+self.cubeData[9])
        //"DRF", "DFL", "DLB", "DBR"
        str.append(self.cubeData[47]+self.cubeData[36]+self.cubeData[35])
        str.append(self.cubeData[45]+self.cubeData[33]+self.cubeData[44])
        str.append(self.cubeData[51]+self.cubeData[42]+self.cubeData[41])
        str.append(self.cubeData[53]+self.cubeData[39]+self.cubeData[38])
        
        return str
    }
    
    // 2.开始计时
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updataSecond), userInfo: nil, repeats: true)
        //调用fire()会立即启动计时器
        timer!.fire()
    }
    
    // 3.定时操作
    @objc func updataSecond() {
        self.resultView.text = "计算中..."
    }
    
    // 4.停止计时
    func stopTimer() {
        if timer != nil {
            timer!.invalidate() //销毁timer
            timer = nil
        }
    }
}

extension MainViewController: ScanViewViewDelegate{
    func comfirmClicked(image: UIImage, index: Int, data: [Int]){
        switch index {
        case 0:
            self.scanView1.image = image
            for i in 0 ..< 9{
                self.cubeData[i%3 + 12*(i/3) + 9] = getColorStr(data[i])
            }
        case 1:
            self.scanView2.image = image
            for i in 0 ..< 9{
                self.cubeData[i%3 + 12*(i/3) + 18] = getColorStr(data[i])
            }
        case 2:
            self.scanView3.image = image
            for i in 0 ..< 9{
                self.cubeData[i%3 + 12*(i/3) + 12] = getColorStr(data[i])
            }
        case 3:
            self.scanView4.image = image
            for i in 0 ..< 9{
                self.cubeData[i%3 + 12*(i/3) + 15] = getColorStr(data[i])
            }
        case 4:
            self.scanView5.image = image
            for i in 0 ..< 9{
                self.cubeData[i] = getColorStr(data[i])
            }
        case 5:
            self.scanView6.image = image
            for i in 0 ..< 9{
                self.cubeData[i + 45] = getColorStr(data[i])
            }
        default: return
        }
    }
    
    func getColorStr(_ color: Int) -> String{
        switch color {
        case 0: return "y"
        case 1: return "r"
        case 2: return "b"
        case 3: return "w"
        case 4: return "o"
        case 5: return "g"
        default: return "nil"
        }
    }
}

