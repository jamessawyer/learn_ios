//
//  WebViewController.swift
//  CommunicatingIntoWebPage
//
//  Created by vivo on 3/21/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var wv: WKWebView!
//    let barButton: UIBarButtonItem = {
//        var btn = UIBarButtonItem(title: "changeFontSize", style: .plain, target: self, action: #selector(changeFontSizeByNative))
//        return btn
//    }()
    
    var fontSize = 18
    var cssrule: String {
        return """
        var s = document.createElement('style');
        s.textContent = 'body { font-size: \(self.fontSize)px; color: red; }';
        document.documentElement.appendChild(s);
        """
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let barButton = UIBarButtonItem(title: "changeFontSize", style: .plain, target: self, action: #selector(changeFontSizeByNative))
        navigationItem.rightBarButtonItem = barButton

        /// 在web view 加载完成前 先执行一遍脚本
        let script = WKUserScript(source: cssrule, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let config = wv.configuration
        config.userContentController.addUserScript(script)
        wv.loadLocal("home")
    }
    

    @objc func changeFontSizeByNative(_ sender: Any) {
//        print("hello")
        self.fontSize -= 1
        if self.fontSize < 10 {
            self.fontSize = 20
        }
        let s = self.cssrule
        wv.evaluateJavaScript(s) { (result, error) in
            print("error \(error!)")
        }
    }

}


extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
    
    func loadLocal(_ fileName: String) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "html") {
            loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
}
