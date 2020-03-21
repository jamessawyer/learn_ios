//
//  WebViewController.swift
//  WebViewPostMessage
//
//  Created by vivo on 3/21/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit
import WebKit

/// 内存管理,使用delegate类防止ViewController不释放
class CustomScriptMessageDelegate: NSObject, WKScriptMessageHandler {
    weak var scriptDelegate: WKScriptMessageHandler?
    
    init(_ scriptDelegate: WKScriptMessageHandler) {
        self.scriptDelegate = scriptDelegate
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        scriptDelegate?.userContentController(userContentController, didReceive: message)
    }
    
    deinit {
        print("CustomScriptMessageDelegate is deinit")
    }
}

class CustomWebView: UIView, WKNavigationDelegate, WKScriptMessageHandler {

    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.selectionGranularity = WKSelectionGranularity.character
        configuration.userContentController = WKUserContentController()
        
       // 给webview与swift交互起名字，webview给swift发消息的时候会用到
        configuration.userContentController.add(CustomScriptMessageDelegate(self), name: "logger")
        configuration.userContentController.add(CustomScriptMessageDelegate(self), name: "cancelResponse")
        
        configuration.userContentController.add(CustomScriptMessageDelegate(self), name: "comfirmResponse")
        
        var wv = WKWebView(frame: .zero, configuration: configuration)
        // 让webview翻动有回弹效果
        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.scrollView.bounces = false
        wv.scrollView.showsVerticalScrollIndicator = false
        wv.scrollView.showsHorizontalScrollIndicator = false
        
        // 只允许webview上下滚动
        wv.scrollView.alwaysBounceVertical = true
        wv.navigationDelegate = self
    
        return wv
    }()
    
    let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width">
          <title>JS Bin</title>
        </head>
        <body>
          <button onclick="cancelResponse()">取消</button>
          <button onclick="comfirmResponse()">确定</button>
          
          <script type="text/javascript">
            <!--   添加这个script在项目头,这样swift才能打印console.log的内容         -->
             var console = {};
             console.log = function(message){
               window.webkit.messageHandlers['logger'].postMessage(message)
             };
            
            ///调用swift方法的方式 window.webkit.messageHandlers.(swift注册的交互名).postMessage(传给swift的参数)
            function cancelResponse() {
              window.webkit.messageHandlers.cancelResponse.postMessage('')
            }
            
            function comfirmResponse() {
              window.webkit.messageHandlers.comfirmResponse.postMessage('')
            }
          </script>
        </body>
        </html>
    """
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.leftAnchor.constraint(equalTo: leftAnchor),
            webView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
    
    func setupUI() {
        addSubview(webView)
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }

    // WKScriptMessageHandler 协议方法
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body
        
        if message.name == "logger" {
            print("JS log: \(body)")
        }
        
        switch message.name {
        case "cancelResponse":
            print("取消")
            // 这里写你想要写的逻辑
            break
        case "comfirmResponse":
            print("确认")
            break
        default:
            break
        }
    }
    
    deinit {
        let ucc = webView.configuration.userContentController
        ucc.removeAllUserScripts()
        ucc.removeScriptMessageHandler(forName: "logger")
        ucc.removeScriptMessageHandler(forName: "cancelResponse")
        ucc.removeScriptMessageHandler(forName: "comfirmResponse")
    }

}
