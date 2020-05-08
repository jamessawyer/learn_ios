//
//  ViewController.swift
//  UISearchBarDemo
//
//  Created by vivo on 3/24/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var searchBar: UISearchBar = {
        let sb = UISearchBar(frame: CGRect(x: 0, y: 0, width: 350, height: 40))
        /// 设置各个icon的offset
//        sb.setPositionAdjustment(UIOffset(horizontal: 15, vertical: 10), for: .search)
        // 这个用于设置搜索框left-margin值
        sb.searchTextPositionAdjustment = UIOffset(horizontal: 10, vertical: 0)
        
//        sb.searchFieldBackgroundPositionAdjustment = UIOffset(horizontal: 40, vertical: 0)
        
//        if #available(iOS 13, *) {
//            /// iOS 13+ 通过暴露 searchTextField 可以禁用 搜索框
//            sb.searchTextField.isEnabled = false
//        } else {
//            if let tf = sb.subviews(ofType: UITextField.self).first {
//               tf.isEnabled = false
//            }
//        }
//        UISearchController
        sb.showsScopeBar = true
        sb.scopeButtonTitles = ["One", "Two"]
       
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.center = view.center
    }


}


extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("xxx \(searchBar.scopeButtonTitles?[selectedScope] ?? "NOn")")
    }
}


extension UIView {
    func subviews<T: UIView>(ofType WhatType: T.Type, recursing: Bool = true) -> [T] {
        var result = self.subviews.compactMap { $0 as? T }
        guard recursing else { return result }
        for sub in self.subviews {
            result.append(contentsOf: sub.subviews(ofType: WhatType))
        }
        return result
    }
}
