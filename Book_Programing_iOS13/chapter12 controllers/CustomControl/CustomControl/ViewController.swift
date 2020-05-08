//
//  ViewController.swift
//  CustomControl
//
//  Created by vivo on 4/13/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var myKnob: MyKnob!
    
    @IBAction func doKnob(_ sender: Any) {
        let knob = sender as! MyKnob
        print("knob angle is \(knob.angle)")
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        myKnob.isContinuous = true
    }


}

