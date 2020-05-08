//
//  MyKnob.swift
//  CustomControl
//
//  Created by vivo on 4/13/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}
extension CGSize {
    init(_ width:CGFloat, _ height:CGFloat) {
        self.init(width:width, height:height)
    }
}
extension CGPoint {
    init(_ x:CGFloat, _ y:CGFloat) {
        self.init(x:x, y:y)
    }
}
extension CGVector {
    init (_ dx:CGFloat, _ dy:CGFloat) {
        self.init(dx:dx, dy:dy)
    }
}

extension CGRect {
    var center : CGPoint {
        return CGPoint(self.midX, self.midY)
    }
}


class MyKnob: UIControl {
    var angle: CGFloat = 0 {
        didSet {
            // 每次最大旋转角度为5
            self.angle = min(max(self.angle, 0), 5)
            self.transform = CGAffineTransform(rotationAngle: self.angle)
        }
    }
    var isContinuous = false // 是否连续触发事件
    private var initialAngle: CGFloat = 0
    


    override func draw(_ rect: CGRect) {
        UIImage(named: "knob")!.draw(in: rect)
    }

    // 计算旋转角度
    func pToA(_ t: UITouch) -> CGFloat {
        let loc = t.location(in: self)
        let c = self.bounds.center
        return atan2(loc.y - c.y, loc.x - c.x)
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.initialAngle = pToA(touch)
        return true
    }
    // 滚动角度范围0-5 radians
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let ang = pToA(touch) - self.initialAngle
        let absoluteAngle = self.angle + ang
        
        switch absoluteAngle {
        case -CGFloat.greatestFiniteMagnitude...0:
            // 小于0 都设置为0
            self.angle = 0
            self.sendActions(for: .valueChanged)
            return false
        case 5...CGFloat.greatestFiniteMagnitude:
            // 大于5以上 都设置为5
            self.angle = 5
            self.sendActions(for: .valueChanged)
            return false
        default:
            self.angle = absoluteAngle
            // 是否连续触发
            if self.isContinuous {
                self.sendActions(for: .valueChanged)
            }
            return true
        }
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.sendActions(for: .valueChanged)
    }
}
