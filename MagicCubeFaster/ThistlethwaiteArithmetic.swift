//
//  ThistlethwaiteArithmetic.swift
//  MagicCubeFaster
//
//  Created by maocaiyuan on 2019/1/25.
//  Copyright © 2019 maocaiyuan. All rights reserved.
//

import Foundation
import UIKit

class ThistlethwaiteArithmetic: NSObject{
    let faces : [Character] = "RLFBUD".getCharArray()
    let order = "AECGBFDHIJKLMSNTROQP"
    let bithash = "TdXhQaRbEFIJUZfijeYV"
    let perm = "AIBJTMROCLDKSNQPEKFIMSPRGJHLNTOQAGCEMTNSBFDHORPQ"
    
    let tablesize = [1, 4096, 6561, 4096, 256, 1536, 13824, 576]
    let CHAROFFSET = 65
    var tables = [[Character]](repeating: [Character](repeating: "\0", count: 1), count: 8)
    var phase = 0
    
    var pos = [Character](repeating: "\0", count: 20)
    var ori = [Character](repeating: "\0", count: 20)
    var val = [Character](repeating: "\0", count: 20)
    
    var move = [Int](repeating: 0, count: 20)
    var moveAmount = [Int](repeating: 0, count: 20)
    
    //Cycles 4 pieces in array p, the piece indices given by a[0..3].
    //1为pos,2为ori
    func cycle(a: [Character], data: Int){
        if (data == 1){
            for i in 1..<4{
                swap(&pos[a[0].getAscIINo()-CHAROFFSET], &pos[a[i].getAscIINo()-CHAROFFSET])
            }
        }else{
            for i in 1..<4{
                swap(&ori[a[0].getAscIINo()-CHAROFFSET], &ori[a[i].getAscIINo()-CHAROFFSET])
            }
        }
    }
    
    // twists i-th piece a+1 times.
    func twist(i: Int, a: Int){
        var i = i
        i -= CHAROFFSET
        ori[i] = ((ori[i].getAscIINo() + a + 1) % val[i].getAscIINo()).getChar()
    }
    
    // set cube to solved position
    func reset(){
        for i in 0 ..< 20{
            pos[i] = i.getChar()
            ori[i] = "\0"  //?
        }
    }
    
    // convert permutation of 4 chars to a number in range 0..23
    func permtonum(_ p: [Character], offset: Int = 0) -> Int{
        var n = 0
        for a in 0 ..< 4 {
            n *= 4 - a
            for b in a+1 ..< 4{ //
                if (p[b+offset] < p[a+offset]){
                    n += 1
                }
            }
        }
        return n
    }
    
    // convert number in range 0..23 to permutation of 4 chars.
    func numtoperm(_ p: inout [Character], n: Int, o: Int){
        var n = n
        
        p[3 + o] = o.getChar()
        for a in (0 ..< 3).reversed(){  //
            p[a + o] = (n % (4 - a) + o).getChar()
            n /= 4 - a
            for b in a+1 ..< 4{
                if ( p[b + o] >= p[a + o]){
                    p[b + o] = (p[b + o].getAscIINo()+1).getChar()
                }
            }
        }
    }
    
    
    
    // get index of cube position from table t
    func getposition(t: Int) -> Int{
        var n = 0
        switch t {
        // case 0 does nothing so returns 0
        case 1://edgeflip
            // 12 bits, set bit if edge is flipped
            for i in 0 ..< 12{
                n += ori[i].getAscIINo() << i
            }
        case 2://cornertwist
            // get base 3 number of 8 digits - each digit is corner twist
            for i in (12...19).reversed(){
                n = n * 3 + ori[i].getAscIINo()
            }
        case 3://middle edge choice
            // 12 bits, set bit if edge belongs in Um middle slice
            for i in 0 ..< 12{
                n += (pos[i].getAscIINo()&8 > 0) ? (1<<i) : 0
            }
        case 4://ud slice choice
            // 8 bits, set bit if UD edge belongs in Fm middle slice
            for i in 0 ..< 8{
                n += (pos[i].getAscIINo()&4 > 0) ? (1<<i) : 0
            }
        case 5://tetrad choice, twist and parity
            var corn = [Int](repeating: 0, count: 8)
            var corn2 = [Int](repeating: 0, count: 4)
            var k = 0
            var j = 0
            var l = 0
            // 8 bits, set bit if corner belongs in second tetrad.
            // also separate pieces for twist/parity determination
    
            for i in 0 ..< 8{
                l = pos[i+12].getAscIINo()-12
                if(l & 4 > 0){
                    corn[l] = k
                    k += 1
                    n += 1<<i
                }else{
                    corn[j] = l
                    j += 1
                }
            }
            //Find permutation of second tetrad after solving first
            for i in 0 ..< 4{
                corn2[i] = corn[4+corn[i]]
            }
            //Solve one piece of second tetrad
            for i in (0 ..< 4).reversed(){
                corn2[i] ^= corn2[0]
            }
            // encode parity/tetrad twist
            n = n*6 + corn2[1]*2 - 2
            if(corn2[3] < corn2[2]){
                n += 1
            }
        case 6://two edge and one corner orbit, permutation
            n = permtonum(pos)*576 + permtonum(pos, offset: 4)*24 + permtonum(pos, offset: 12)
        case 7://one edge and one corner orbit, permutation
            n = permtonum(pos, offset: 8)*24 + permtonum(pos, offset: 16)
        default:
            n = 0
        }
        return n
    }
    
    
    // sets cube to any position which has index n in table t
    func setposition(t: Int, n: Int){
        var j = 12
        var k = 0
        var nn = n
        let corn = "QRSTQRTSQSRTQTRSQSTRQTSR"
        self.reset()
        
        switch t{
        // case 0 does nothing so leaves cube solved
        case 1://edgeflip
            for i in 0 ..< 12 {
                ori[i] = (nn & 1).getChar()
                nn >>= 1
            }
        case 2://cornertwist
            for i in 12 ..< 20{
                ori[i] = (nn % 3).getChar()
                nn /= 3
            }
        case 3://middle edge choice
            for i in 0 ..< 12 {
                pos[i] = (8 * nn & 8).getChar()
                nn >>= 1
            }
        case 4://ud slice choice
            for i in 0 ..< 8{
                pos[i] = (4 * nn & 4).getChar()
                nn >>= 1
            }
        case 5://tetrad choice,parity,twist
            let cornTmp = corn.getIndexToEnd(begin: nn % 6 * 4)
            nn /= 6
            for i in 0 ..< 8{
                if((nn & 1) > 0){
                    pos[i+12] = (cornTmp[k].getAscIINo()-CHAROFFSET).getChar()
                    k += 1
                }else{
                    pos[i+12] = j.getChar()
                    j += 1
                }
                nn >>= 1
            }
        case 6://slice permutations
            numtoperm(&pos, n: nn%24, o: 12)
            nn /= 24
            numtoperm(&pos, n: nn%24, o: 4)
            nn /= 24
            numtoperm(&pos, n: nn,    o: 0)
    
        case 7://corner permutations
            numtoperm(&pos, n: nn/24, o: 8)
            numtoperm(&pos, n: nn%24, o: 16)
            
        default:
            return
        }
    }
    
    
    //do a clockwise quarter turn cube move
    func domove(m: Int){
        let p = perm.getIndexToEnd(begin: 8 * m)
        //cycle the edges
        let pp = p.getCharArray()
        cycle(a: pp, data: 1)
        cycle(a: pp, data: 2)
        //cycle the corners
        let ppp = p.getIndexToEnd(begin: 4).getCharArray()
        cycle(a: ppp, data: 1)
        cycle(a: ppp, data: 2)
        
        //twist corners if RLFB
        if(m < 4){
            for i in (4...7).reversed(){
                twist(i: p[i].getAscIINo(), a: i & 1)
            }
        }
        
        //flip edges if FB
        if(m < 2){
            for i in (0...3).reversed() {
                twist(i: p[i].getAscIINo(), a: 0)
            }
        }
    }
    
    // calculate a pruning table
    func filltable(ti: Int){
        var n = 1
        var l = 1
        let tl = tablesize[ti]
        // alocate table memory
        var tb = [Character](repeating: "\0", count: tl)
        
        //mark solved position as depth 1
        reset();
        tb[getposition(t: ti)] = 1.getChar()
        
        // while there are positions of depth l
        while( n > 0){
            n = 0
            // find each position of depth l
            for i in 0 ..< tl{
                if(tb[i].getAscIINo() == l){
                    //construct that cube position
                    setposition(t: ti, n: i)
                    // try each face any amount
                    for f in 0 ..< 6{
                        for q in 1 ..< 4{
                            domove(m: f)
                            // get resulting position
                            let r = getposition(t: ti)
                            // if move as allowed in that phase, and position is a new one
                            if( ( q==2 || f >= (ti & 6) ) && tb[r] == "\0"){
                                // mark that position as depth l+1
                                tb[r] = (l+1).getChar()
                                n += 1
                            }
                        }
                        domove(m: f)
                    }
                }
            }
            l += 1
        }
        tables[ti] = tb
    }
    
    // Pruned tree search. recursive.
    func searchphase(movesleft: Int, movesdone: Int, lastmove: Int) -> Bool{
        // prune - position must still be solvable in the remaining moves available
        if( tables[phase][getposition(t: phase)].getAscIINo()-1 > movesleft ||
            tables[phase+1][getposition(t: phase+1)].getAscIINo()-1 > movesleft ) {
            return false
        }
        // If no moves left to do, we have solved this phase
        if(movesleft == 0) {
            return true
        }
    
        // not solved. try each face move
        for i in (0...5).reversed(){
            // do not repeat same face, nor do opposite after DLB.
            if( (i-lastmove) != 0){  //  && ((i-lastmove+1) != 0 || i|1 )
                move[movesdone] = i
                // try 1,2,3 quarter turns of that face
                for j in 1 ..< 4{
                    //do move and remember it
                    domove(m: i)
                    moveAmount[movesdone] = j
                    //Check if phase only allows half moves of this face
                    if( (j==2 || i >= phase ) &&
                        searchphase(movesleft: movesleft-1, movesdone: movesdone+1, lastmove: i)) {
                        return true
                    }
                }
                // put face back to original position.
                domove(m: i)
            }
        }
        // no solution found
        return false
    }

    //开始计算
    func calculateBegin(argv: [String]) -> String{
        var f = 0
        var j = 0
        var k = 0
        var pc = 0
        var mor = 0
        var str = ""
        
        let time1 = CACurrentMediaTime()
        // initialise tables
        for k in 0 ..< 20{ val[k] = (k<12 ? 2 : 3).getChar()}
        for j in 0 ..< 8{ filltable(ti: j)}
        let time2 = CACurrentMediaTime()
        print("初始化时间:" + String(format: "%.3f", time2-time1) + "s")
        // read input, 20 pieces worth
        for i in 0 ..< 20{
            f = 0; pc = 0; k = 0; mor = 0
            for g in 0 ..< val[i].getAscIINo(){
                j = faces.index(of: argv[i][g])!
                // keep track of principal facelet for orientation
                if (j > k){
                    k = j
                    mor = g
                }
                //construct bit hash code
                pc += 1<<j
            }
            // find which cubelet it belongs, i.e. the label for this piece
            for g in 0 ..< 20{
                if(pc == bithash[g].getAscIINo() - 64){break}
                f += 1
            }
            // store piece
            pos[order[i].getAscIINo()-CHAROFFSET] = f.getChar()
            ori[order[i].getAscIINo()-CHAROFFSET] = (mor%val[i].getAscIINo()).getChar()
        }
        let time3 = CACurrentMediaTime()
        print("处理输入时间:" + String(format: "%.3f", time3-time2) + "s")
        
        //solve the cube
        // four phases
        for _ in stride(from: phase, to: 8 ,by: 2){
            // try each depth till solved
            var j = 0
            while(!searchphase(movesleft: j, movesdone: 0, lastmove: 9)){
                j += 1
            }
            for i in 0 ..< j{
                str += String("FBRLUD"[move[i]])
                
                if(moveAmount[i] == 3){
                    str += "'"
                }else if(moveAmount[i] == 2){
                    str += "2"
                }
                str += " "
            }
            phase += 2
        }
        let time4 = CACurrentMediaTime()
        print("寻找路径时间:" + String(format: "%.3f", time4-time3) + "s")
        return "步骤: " + str
    }
}

extension String{
    //i的字符
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    //i到末尾
    func getIndexToEnd(begin: Int) -> String {
        let start = index(startIndex, offsetBy: begin)
        return String(self[start..<self.endIndex])
    }
    
    //i到i的闭包
    subscript (r: ClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start...end])
    }
    
    //String->Char
    func getCharArray() -> [Character]{
        var char = [Character]()
        for data in self{
            char.append(data)
        }
        return char
    }
    
    //返回第一次出现的指定子字符串在此字符串中的索引
    //（如果backwards参数设置为true，则返回最后出现的位置）
    func positionOf(sub:String, backwards:Bool = false)->Int {
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
}

extension Character{
    //字符的ascii码
    func getAscIINo() -> Int{
        var numberFromC = 0
        for scalar in String(self).unicodeScalars{
            numberFromC = Int(scalar.value)
        }
        return numberFromC
    }
}

extension Int{
    //码转字符
    func getChar() -> Character{
        return Character(UnicodeScalar(self)!)
    }
}
