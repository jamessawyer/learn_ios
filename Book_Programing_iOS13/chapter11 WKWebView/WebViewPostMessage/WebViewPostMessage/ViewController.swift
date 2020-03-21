//
//  ViewController.swift
//  WebViewPostMessage
//
//  Created by vivo on 3/21/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        let wv = CustomWebView(frame: CGRect(x: 0, y: 100, width: view.bounds.size.width, height: view.bounds.size.height))
        view.addSubview(wv)
    }


}

