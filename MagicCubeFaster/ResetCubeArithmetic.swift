//
//  ResetCubeArithmetic.swift
//  MagicCubeFaster
//
//  Created by maocaiyuan on 2019/1/24.
//  Copyright © 2019 maocaiyuan. All rights reserved.
//

// 0  1  2
// 3  4  5
// 6  7  8
// 9  10 11  12 13 14  15 16 17  18 19 20
// ...
// ...
// 45 46 47
// 48 49 50
// 51 52 53

//IDA*路径搜索，但是这种算法不可能

import Foundation

class ResetCubeArithmetic: NSObject {
    //表示每个面除中间的另外8个的位置
    let posOrigin = [
        [0,1,2,3,5,6,7,8],
        [9,10,11,21,23,33,34,35],
        [12,13,14,24,26,36,37,38],
        [15,16,17,27,29,39,40,41],
        [18,19,20,30,32,42,43,44],
        [45,46,47,48,50,51,52,53]
    ]
    
    let centre = [4,22,25,28,31,49]//每个面中心坐标
    
    //转换数组，12种变换，两两对应，每次转换会更改20个位置
    let posChange = [
        [9,10,11,23,35,34,33,21, 6,7,8,12,24,36,47,46,45,44,32,20],  // a0
        [33,21,9,10,11,23,35,34, 44,32,20,6,7,8,12,24,36,47,46,45],  // b1    a->b = F
        [12,13,14,26,38,37,36,24, 8,5,2,15,27,39,53,50,47,35,23,11], // c2
        [36,24,12,13,14,26,38,37, 35,23,11,8,5,2,15,27,39,53,50,47],  // d3    c->d = R
        [15,16,17,29,41,40,39,27, 2,1,0,18,30,42,51,52,53,38,26,14],  // e4
        [39,27,15,16,17,29,41,40, 38,26,14,2,1,0,18,30,42,51,52,53],  // f5    e->f = B
        [18,19,20,32,44,43,42,30, 0,3,6,9,21,33,45,48,51,41,29,17],   // g6
        [42,30,18,19,20,32,44,43, 41,29,17,0,3,6,9,21,33,45,48,51],   // h7    g->h = L
        [0,1,2,5,8,7,6,3, 9,10,11,12,13,14,15,16,17,18,19,20],         // i8
        [6,3,0,1,2,5,8,7, 12,13,14,15,16,17,18,19,20,9,10,11],         // j9   i->j = U
        [45,46,47,50,53,52,51,48, 33,34,35,36,37,38,39,40,41,42,43,44], // k10
        [51,48,45,46,47,50,53,52, 42,43,44,33,34,35,36,37,38,39,40,41]  // l11   k->l = D
    ]
    
    var depth = 0   //迭代加深搜索的层数
    var ansStr = [String](repeating: "", count: 20)
    var ansNo = [Int](repeating: -1, count: 20)
    var flag = false
    
    //找出每个面中与中间颜色不同的个数的最大值
    func getH(_ maze: [String]) -> Int{
        var ret = 0
        for i in 0 ..< 6{
            var cnt = 0
            for j in 0 ..< 8{
                if(maze[posOrigin[i][j]] != maze[centre[i]]){
                    cnt += 1
                }
            }
            ret = max(ret, cnt)
        }
        return (ret+2)/3
    }
    
    //路径搜索
    func IDAstar(tmp_depth: Int, b: [String], father: Int){
        if(self.flag){return}
        //A*剪枝
        if( getH(b) > tmp_depth){
            return
        }
        if(tmp_depth == 0){
            self.flag = true  //找到了
            return
        }
        
        for i in 0 ..< 12{
            if(self.flag){return}
            if((i^father) == 1) {continue}
            var char_tmp = [String]()
            char_tmp = b
            self.ansStr[tmp_depth] = lburfd(i) //记录转的是哪个面
            self.ansNo[tmp_depth] = i
            //转换
            for j in 0 ..< 20{
                char_tmp[posChange[i][j]] = b[posChange[i^1][j]]
            }
            
            self.IDAstar(tmp_depth: tmp_depth-1, b: char_tmp, father: i)
        }
    }
    
    func lburfd(_ i: Int) -> String{
        switch i {
        case 0: return "F"
        case 1: return "F'"
        case 2: return "R"
        case 3: return "R'"
        case 4: return "B"
        case 5: return "B'"
        case 6: return "L"
        case 7: return "L'"
        case 8: return "U"
        case 9: return "U'"
        case 10: return "D"
        case 11: return "D'"
        default: return "nil"
        }
    }
    
    //开始计算
    func calculateBegin(_ maze: [String]) -> String{
        let a = ["w", "w", "g", "o", "y", "y", "r", "y", "o", "b", "g", "w", "b", "b", "y", "r", "g", "g", "r", "y", "y", "r", "r", "b", "w", "g", "b", "r", "o", "r", "g", "b", "w", "b", "o", "r", "w", "o", "o", "g", "y", "g", "o", "o", "y", "o", "b", "b", "w", "w", "g", "w", "r", "y"]
        let maxCount = 6
        var resultStr = "已解！"
        let initMaze = getH(a)
        if(initMaze == 0){
            return resultStr
        }
        self.depth = initMaze
        for _ in initMaze ..< maxCount {
            self.IDAstar(tmp_depth: depth, b: a, father: -1)
            if(self.flag){
                resultStr = "步骤: "
                for j in 0 ..< depth{
                     resultStr += "\(ansStr[depth-j]) "
                }
                break
            }
            self.depth += 1
        }
        if(!flag){
            resultStr = "找了\(maxCount-initMaze)次，没找到！"
        }
        return resultStr
    }
    
    
    
    func rotation(i: Int, maze: [String]) -> [String]{
        var char_tmp = [String]()
        char_tmp = maze
        //转换
        for j in 0 ..< 20{
            char_tmp[posChange[i][j]] = maze[posChange[i^1][j]]
        }
        return char_tmp
    }
    
    
    func debug(maze: [String]){
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
