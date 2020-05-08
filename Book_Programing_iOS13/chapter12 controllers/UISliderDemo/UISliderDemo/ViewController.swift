//
//  ViewController.swift
//  UISliderDemo
//
//  Created by vivo on 4/6/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
    }


    @IBAction func handleTap(_ g: UIGestureRecognizer) {
        let s = g.view as! UISlider
        // 如果isHighlighted为true 表示点击的是thumb滑块区域
        if s.isHighlighted {
          return
        }
        // 点击的点 CGPoint
        let pt = g.location(in: s)
        /// 获取track 的围度信息 CGRect
        let track = s.trackRect(forBounds: s.bounds)
        
        // 如果点击的点不在 轨道区域 则忽略
        if !track.insetBy(dx: 0, dy: -10).contains(pt) {
          return
        }
        
        // 点击位置X轴方向上，占UISlider的百分比位置
        let percentage = pt.x / s.bounds.size.width
        let delta = Float(percentage) * (s.maximumValue - s.minimumValue)
        // 点击位置表示的值
        let value = s.minimumValue + delta
        // 滑动到制定位置
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
          s.setValue(value, animated: true)
        }
    }
}

