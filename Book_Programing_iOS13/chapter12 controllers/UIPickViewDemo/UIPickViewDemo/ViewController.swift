//
//  ViewController.swift
//  UIPickViewDemo
//
//  Created by vivo on 3/23/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var selectedState: UILabel!
    
    var states: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        let f = Bundle.main.path(forResource: "states", ofType: "txt")!
        let s = try! String(contentsOfFile: f)
        self.states = s.components(separatedBy: "\n")
        
        if self.states.count > 0 {
            selectedState.text = states[0]
        }
    }
    
    
    @IBAction func findFlorida(_ sender: Any) {
        // 找到 Florida 并选中改行
        let floridaIndex = self.states.firstIndex(of: "Florida")
        if let index = floridaIndex,  index > -1 {
            self.picker.selectRow(index, inComponent: 0, animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        print("picker height", self.picker.frame.size.height)
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        print("self.states.count: \(self.states.count)")
        return self.states.count
    }
    
    // 进行复用
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let lab: UILabel
        if let label = view as? UILabel {
            lab = label
            print("reusing label")
        } else {
            lab = MyLabel()
            print("making new label")
        }
        lab.text = self.states[row]
        lab.backgroundColor = .clear
        lab.sizeToFit()
        return lab
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("selected: \(self.states[row])")
        print("row size at  component: \(component): \(self.picker.rowSize(forComponent: component))")
        self.selectedState.text = self.states[row]
    }
}

class MyLabel: UILabel {
    deinit {
        print("deinit label")
    }
}



