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
    var resultView = UILabel() //结果显示
    
    var isClaculating = false
    
    var cubeData = [String](repeating: "nil", count: 54)
    var resetTheCubeView : CubeResetView?
    
    var resolverStr = ""  //步骤结果
    var strTmp = [String]() //步骤结果的拆分
    var index = 0 //执行的次数
    var timer : Timer?  //1s扫描一次
    var cubeDataTmp = [String](repeating: "nil", count: 54)

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
        resultView.isEnabled = false
        resultView.numberOfLines = 0
        resultView.contentMode = .top
        resultView.lineBreakMode = .byWordWrapping
        resultView.backgroundColor = UIColor.white
        resultView.text = "请扫描魔方!"
        self.view.addSubview(resultView)
        
        //确认按钮
        confirmBtn.frame = CGRect(x: 20, y: resultView.frame.maxY+20, width: Width-40, height: 44)
        confirmBtn.backgroundColor = UIColor.white
        confirmBtn.setTitle("开始计算", for: .normal)
        confirmBtn.setTitleColor(UIColor.black, for: .normal)
        confirmBtn.addTarget(self, action: #selector(self.calculate), for: .touchUpInside)
        self.view.addSubview(confirmBtn)
        
        //复原按钮
        let resetBtn = UIButton()
        resetBtn.frame = CGRect(x: 20, y: confirmBtn.frame.maxY+10, width: Width-40, height: 44)
        resetBtn.backgroundColor = UIColor.white
        resetBtn.setTitle("复原演示", for: .normal)
        resetBtn.setTitleColor(UIColor.black, for: .normal)
        resetBtn.addTarget(self, action: #selector(self.resetTheCube), for: .touchUpInside)
        self.view.addSubview(resetBtn)
        
        //测试按钮
        let rightBarBtn = UIBarButtonItem(title: "测试", style: .plain, target: self,
                                          action: #selector(test))
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }
    
    @objc func test(){
        if(self.cubeData.contains("nil")){
            self.cubeData = ["g", "w", "g", "o", "y", "o", "g", "o", "y", "w", "b", "o", "b", "w", "y", "r", "r", "o", "y", "y", "r", "r", "r", "y", "r", "g", "y", "g", "o", "o", "g", "b", "b", "w", "w", "o", "b", "b", "r", "b", "w", "g", "o", "r", "r", "b", "g", "w", "g", "w", "y", "w", "b", "y"]
            resetTheCubeView = CubeResetView(frame: CGRect(x: scanView2.frame.minX, y: scanView5.frame.minY,
                                                       width: (Width-20), height: (Width-20)*3/4))
            resetTheCubeView!.updateColor(color: self.cubeData)
            self.view.addSubview(resetTheCubeView!)
        }
    }
    
    //复原
    @objc func resetTheCube(){
        self.resetTheCubeView?.removeFromSuperview()
        self.resetTheCubeView = nil
        
        if timer != nil{
            ToastView().showToast("复原中...")
            return
        }
        if resolverStr == ""{
            ToastView().showToast("请先计算步骤...")
            return
        }
        if(isClaculating){
            ToastView().showToast("计算中!")
            return
        }
        resetTheCubeView = CubeResetView(frame: CGRect(x: scanView2.frame.minX, y: scanView5.frame.minY,
                                                       width: (Width-20), height: (Width-20)*3/4))
        self.cubeDataTmp = self.cubeData
        resetTheCubeView!.updateColor(color: self.cubeDataTmp)
        self.view.addSubview(resetTheCubeView!)
        strTmp = resolverStr.components(separatedBy: " ")
        self.startTimer()
    }
    
    //开始计算
    @objc func calculate(){
        self.resetTheCubeView?.removeFromSuperview()
        self.resetTheCubeView = nil
        
        if(self.cubeData.contains("nil")){
            ToastView().showToast("请继续扫描!")
            return
        }
        if(isClaculating){
            ToastView().showToast("计算中!")
            return
        }
        if let str = isDataRight(){
            ToastView().showToast("扫描数据错误，请检查颜色" + str)
            return
        }
        let solver = ThistlethwaiteArithmetic()
        self.resultView.text = "计算中..."
        
        let myQueue = DispatchQueue(label: "myQueue")  //
        isClaculating = true
        let data = self.getColorUFDBLRStr()
        
        myQueue.async {
            let time1 = CACurrentMediaTime()
            self.resolverStr = solver.calculateBegin(argv: data)
            let time2 = CACurrentMediaTime()
            DispatchQueue.main.async {
                self.resultView.text = self.resolverStr + "\n时间: " + String(format: "%.3f", time2-time1) + "s"
                self.isClaculating = false
            }
        }
    }
    
    //检查数据正确
    func isDataRight() -> String?{
        var colorCount = [Int](repeating: 0, count: 6)
        for data in self.cubeData{
            if(data == "y"){
                colorCount[0] += 1
            }else if(data == "r"){
                colorCount[1] += 1
            }else if(data == "b"){
                colorCount[2] += 1
            }else if(data == "w"){
                colorCount[3] += 1
            }else if(data == "o"){
                colorCount[4] += 1
            }else if(data == "g"){
                colorCount[5] += 1
            }
        }
        for i in 0 ..< 6 {
            if(colorCount[i] != 9){
                return getColorStr(i)
            }
        }
        return nil
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
        
        var cubeDataTmp = self.cubeData
        
        for i in 0 ..< self.cubeData.count{
            if(U == self.cubeData[i]){
                cubeDataTmp[i] = "U"
            }else if(F == self.cubeData[i]){
                cubeDataTmp[i] = "F"
            }else if(R == self.cubeData[i]){
                cubeDataTmp[i] = "R"
            }else if(B == self.cubeData[i]){
                cubeDataTmp[i] = "B"
            }else if(L == self.cubeData[i]){
                cubeDataTmp[i] = "L"
            }else if(D == self.cubeData[i]){
                cubeDataTmp[i] = "D"
            }
        }
        
        //拼接
        var str = [String]()
        //"UF", "UR", "UB", "UL"
        str.append(cubeDataTmp[7]+cubeDataTmp[10])
        str.append(cubeDataTmp[5]+cubeDataTmp[13])
        str.append(cubeDataTmp[1]+cubeDataTmp[16])
        str.append(cubeDataTmp[3]+cubeDataTmp[19])
        //"DF", "DR", "DB", "DL"
        str.append(cubeDataTmp[46]+cubeDataTmp[34])
        str.append(cubeDataTmp[50]+cubeDataTmp[37])
        str.append(cubeDataTmp[52]+cubeDataTmp[40])
        str.append(cubeDataTmp[48]+cubeDataTmp[43])
        //"FR", "FL"
        str.append(cubeDataTmp[23]+cubeDataTmp[24])
        str.append(cubeDataTmp[21]+cubeDataTmp[32])
        //"BR", "BL"
        str.append(cubeDataTmp[27]+cubeDataTmp[26])
        str.append(cubeDataTmp[29]+cubeDataTmp[30])
        //"UFR", "URB", "UBL", "ULF"
        str.append(cubeDataTmp[8]+cubeDataTmp[11]+cubeDataTmp[12])
        str.append(cubeDataTmp[2]+cubeDataTmp[14]+cubeDataTmp[15])
        str.append(cubeDataTmp[0]+cubeDataTmp[17]+cubeDataTmp[18])
        str.append(cubeDataTmp[6]+cubeDataTmp[20]+cubeDataTmp[9])
        //"DRF", "DFL", "DLB", "DBR"
        str.append(cubeDataTmp[47]+cubeDataTmp[36]+cubeDataTmp[35])
        str.append(cubeDataTmp[45]+cubeDataTmp[33]+cubeDataTmp[44])
        str.append(cubeDataTmp[51]+cubeDataTmp[42]+cubeDataTmp[41])
        str.append(cubeDataTmp[53]+cubeDataTmp[39]+cubeDataTmp[38])
        
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
        let resetArithmatic = ResetCubeArithmetic()
        self.self.cubeDataTmp = resetArithmatic.calculateBegin(self.self.cubeDataTmp, rotaStr: strTmp[index])
        self.resetTheCubeView?.updateColor(color: self.self.cubeDataTmp)
        index += 1
        if index >= strTmp.count{
            stopTimer()
            index = 0
        }
    }
    
    // 4.停止计时
    func stopTimer() {
        if timer != nil {
            timer!.invalidate() //销毁timer
            timer = nil
        }
    }
    
    func debug(_ maze: [String]){
        var k = 0
        for _ in 0 ..< 3{
            print(maze[k] + maze[k+1] + maze[k+2])
            k += 3
        }
        for _ in 0 ..< 3{
            print(maze[k] + maze[k+1] + maze[k+2] + " " + maze[k+3] + maze[k+4] + maze[k+5] + " " + maze[k+6] + maze[k+7] + maze[k+8] + " " + maze[k+9] + maze[k+10] + maze[k+11])
            k += 12
        }
        for _ in 0 ..< 3{
            print(maze[k] + maze[k+1] + maze[k+2])
            k += 3
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

