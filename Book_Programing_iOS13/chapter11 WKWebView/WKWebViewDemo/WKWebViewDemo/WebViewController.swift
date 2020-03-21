//
//  WebViewController.swift
//  WKWebViewDemo
//
//  Created by vivo on 3/20/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var activity: UIActivityIndicatorView = {
        let act = UIActivityIndicatorView(style: .large)
        act.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        act.translatesAutoresizingMaskIntoConstraints = false
        return act
    }()
    
    weak var wv: WKWebView!

    
    override func loadView() {
        print("loadView")
        super.loadView()
    }

    var obs = Set<NSKeyValueObservation>()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        let wwv = WKWebView(frame: CGRect.zero)
        wwv.scrollView.backgroundColor = .systemPink
        view.addSubview(wwv)
        wwv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[wv]|", options: [], metrics: nil, views: ["wv": wwv]),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[wv]|", options: [], metrics: nil, views: ["wv": wwv])
            ].flatMap{$0})
        
        self.wv = wwv
        wv.allowsBackForwardNavigationGestures = true
        
        wv.addSubview(activity)
        NSLayoutConstraint.activate([
            activity.centerXAnchor.constraint(equalTo: wv.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: wv.centerYAnchor)
        ])
        
        obs.insert(wv.observe(\.isLoading, options: .new) { [unowned self] wv, ch in
            if let val = ch.newValue {
                if val {
                    self.activity.startAnimating()
                } else {
                    self.activity.stopAnimating()
                }
            }
            
        })
        
        // 监听title变化
        obs.insert(wv.observe(\.title, options: .new) { [unowned self] wv, change in
            if let val = change.newValue, let title = val {
                self.navigationItem.title = title
            }
            
        })
        
        wv.navigationDelegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("view did appear, req: \(self.wv.url as Any)")
        
        let b = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(goBack))
        navigationItem.rightBarButtonItems = [b]
        

        let url = URL(string: "http://www.apeth.com/RubyFrontierDocs/default.html")!
        
        wv.load(URLRequest(url:url))
    }
    
    @objc func goBack() {
        wv.goBack()
    }

}

extension WebViewController {
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        if navigationAction.navigationType == .linkActivated {
//            if let url = navigationAction.request.url {
    // 使用浏览器或者应用（如果该应用添加了url scheme, 会自动打开应用）
//                print("url: \(String(describing: url))")
//                UIApplication.shared.open(url)
//                decisionHandler(.cancel)
//                return
//            }
//        }
//        decisionHandler(.allow)
//    }
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated {
                if let url = navigationAction.request.url {
                    print("url: \(String(describing: url))")
                    /// 使用 SFSafariViewController
                    let svc = SFSafariViewController(url: url)
                    // 取消按钮样式
                    // .done || .close || .cancel
                    svc.dismissButtonStyle = .cancel
                    svc.preferredBarTintColor = .darkGray // 导航区域颜色
                    svc.preferredControlTintColor = .red  // 图标颜色
                    self.present(svc, animated: true, completion: nil)
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("did commit \(navigation)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("did fail")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("did fail Provisional \(error)")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("did Start Provisional Navigation")
    }
}
