//
//  ViewController.swift
//  UISwitchDemo
//
//  Created by vivo on 4/5/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customSwitch = CustomSwitch(frame: CGRect(x: 200, y: 50, width: 100, height: 34))
        customSwitch.areLabelsShown = true
        customSwitch.cornerRadius = 0
        customSwitch.thumbCornerRadius = 0
        customSwitch.tintColor = UIColor.green
        // rgb(140,57,54)
        customSwitch.offTintColor = UIColor(red: 140/255, green: 57/255, blue: 54/255, alpha: 1)
//        customSwitch.thumbTintColor = .red
        self.view.addSubview(customSwitch)
    }


}

