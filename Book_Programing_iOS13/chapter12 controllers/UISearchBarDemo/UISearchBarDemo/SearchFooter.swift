//
//  SearchFooter.swift
//  UISearchBarDemo
//
//  Created by vivo on 4/3/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit

class SearchFooter: UIView {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()   
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        label.frame = bounds
        configureView()
    }
    

    func setNotFiltering() {
        label.text = ""
        hideFooter()
    }
    
    func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int) {
        if filteredItemCount == totalItemCount {
            setNotFiltering()
        } else if filteredItemCount == 0 {
            label.text = "没有找到匹配内容"
            showFooter()
        } else {
            label.text = "Filtering \(filteredItemCount) of \(totalItemCount)"
            showFooter()
        }
    }
    
    fileprivate func hideFooter() {
        UIView.animate(withDuration: 0.7) {
            self.alpha = 0.0
        }
    }
    
    fileprivate func showFooter() {
        UIView.animate(withDuration: 0.7) {
            self.alpha = 1.0
        }
    }
    
    func configureView() {
        alpha = 0.0
        backgroundColor = UIColor.candyGreen
        label.textAlignment = .center
        label.textColor = UIColor.white
        addSubview(label)
    }
    
}
