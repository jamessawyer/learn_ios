//
//  ViewController.swift
//  WKWebViewDemo
//
//  Created by vivo on 3/20/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "start"
        edgesForExtendedLayout = []
    }
    
    @IBAction func doButton(_ sender: Any) {
        let wvc = WebViewController()
        self.navigationController!.pushViewController(wvc, animated: true)
    }
    
    

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//
//        let statusBarheight = UIApplication.shared.statusBarFrame.height
//
//        print("statusBarheight: \(statusBarheight)")
//
//        let configuration = WKWebViewConfiguration()
//
//        let wv = WKWebView(frame: CGRect(x: 0, y: statusBarheight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - statusBarheight), configuration: configuration)
//
//        view.addSubview(wv)
//
//        // 方式1: load()
////        let req = URLRequest(url: URL(string: "https://www.youtube.com/watch?v=DjeXpV-AUzo")!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
////        wv.load(req)
//
//        // 方式2：loadFileURL(_:allowingReadAccessTo:)
////        let localHtmlUrl = Bundle.main.url(forResource: "home", withExtension: "html")!
////        wv.loadFileURL(localHtmlUrl, allowingReadAccessTo: localHtmlUrl)
//
//        // 方式3: loadHTMLString(_:baseURL:)
////        let templatepath = Bundle.main.path(forResource: "templateHTML", ofType: "txt")!
////        let base = URL(fileURLWithPath: templatepath)
////
////        var s = try! String(contentsOfFile: templatepath)
////        wv.loadHTMLString(s, baseURL: base)
//
//        let session = URLSession.shared
//        let url = URL(string: "https://unsplash.com/photos/X-Far-t1woI")!
//        let task = session.dataTask(with: url) { data, response, err in
//            if let response = response,
//            let mime = response.mimeType,
//                let enc = response.textEncodingName,
//                let data = data {
//                print("mime: \(mime)\n enc: \(enc)\n")
//                DispatchQueue.main.async {
//                    wv.load(data, mimeType: mime, characterEncodingName: enc, baseURL: url)
//
//                    wv.backForwardList
//                }
//            }
//        }
//
//        task.resume()
//
//    }


}

