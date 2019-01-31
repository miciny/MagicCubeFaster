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
    
   
    
    func lburfd(_ i: String) -> [Int]{
        switch i {
        case "F": return [0]
        case "F2": return [0, 0]
        case "F'": return [1]
        case "R": return [2]
        case "R2": return [2, 2]
        case "R'": return [3]
        case "B": return [4]
        case "B2": return [4, 4]
        case "B'": return [5]
        case "L": return [6]
        case "L2": return [6, 6]
        case "L'": return [7]
        case "U": return [8]
        case "U2": return [8, 8]
        case "U'": return [9]
        case "D": return [10]
        case "D2": return [10, 10]
        case "D'": return [11]
        default: return []
        }
    }
    
    //开始计算
    func calculateBegin(_ maze: [String], rotaStr: String) -> [String]{
        var a = maze
        let rotaInt = lburfd(rotaStr)
        for i in rotaInt {
            a = rotation(i: i, maze: a)
        }
        return a
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
}
