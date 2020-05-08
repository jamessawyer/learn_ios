//
//  CustomSlider.swift
//  UISliderDemo
//
//  Created by vivo on 4/6/20.
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

class CustomSlider: UISlider {

    var bubbleView: UIView!
    weak var label: UILabel?
    let formatter: NumberFormatter = {
        let n = NumberFormatter()
        n.maximumFractionDigits = 1 // 最多一位小数
        return n
    }()
    
    // The default implementation of this method does nothing. Subclasses can override it to perform additional actions whenever the superview changes.
    override func didMoveToSuperview() {
        self.bubbleView = UIView(frame: CGRect(0, 0, 100, 100))
        let im: UIImage!
        
        // iOS10+
        if #available(iOS 10.0, *) {
            // 绘制带倒三角的框
            let r = UIGraphicsImageRenderer(size: CGSize(100, 100))
            im = r.image { ctx in
                let con = ctx.cgContext
                let p = UIBezierPath(roundedRect: CGRect(0, 0, 100, 80), cornerRadius: 10)
                p.move(to: CGPoint(45, 80))
                p.addLine(to: CGPoint(50, 100))
                p.addLine(to: CGPoint(55, 80))
                con.addPath(p.cgPath)
                UIColor.blue.setFill()
                con.fillPath()
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(100, 100), false, 0)
            let con = UIGraphicsGetCurrentContext()!
            
            let p = UIBezierPath(roundedRect: CGRect(0, 0, 100, 80), cornerRadius: 10)
            p.move(to: CGPoint(45, 80))
            p.addLine(to: CGPoint(50, 100))
            p.addLine(to: CGPoint(55, 80))
            con.addPath(p.cgPath)
            UIColor.blue.setFill()
            con.fillPath()
            im = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        let iv = UIImageView(image: im)
        self.bubbleView.addSubview(iv)
        
        let lab = UILabel(frame: CGRect(0, 0, 100, 80))
        lab.numberOfLines = 1
        lab.textAlignment = .center
        lab.font = UIFont(name: "GillSans-Bold", size: 20)
        lab.textColor = .white
        self.bubbleView.addSubview(lab)
        self.label = lab
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let r = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        // bubbleView的位置
        self.bubbleView?.frame.origin.x = r.origin.x + (r.size.width/2.0) - (self.bubbleView.frame.size.width/2.0)
        self.bubbleView?.frame.origin.y = r.origin.y - 105
        return r
    }
    
    // 开始追踪UISlider 的 valueChanged 事件
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let bool = super.beginTracking(touch, with: event)
        if bool {
            self.addSubview(self.bubbleView)
            self.label?.text = self.formatter.string(from: self.value as NSNumber)
        }
        return bool
    }
    
    // 根据不停发送的valueChange事件 持续的更新label的数字
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let bool = super.continueTracking(touch, with: event)
        if bool {
            self.label?.text = self.formatter.string(from: self.value as NSNumber)
        }
        return bool
    }
    
    // 当事件停止时 将视图从父视图中移除
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.bubbleView?.removeFromSuperview()
        super.endTracking(touch, with: event)
    }
    
    // 当事件取消时 将视图从父视图中移除
    override func cancelTracking(with event: UIEvent?) {
        self.bubbleView?.removeFromSuperview()
        super.cancelTracking(with:event)
    }
    
}
