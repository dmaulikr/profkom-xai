//
//  ViewController.swift
//  profkom-xai
//
//  Created by Admin on 17.12.14.
//  Copyright (c) 2014 KY1VSTAR. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: WebViewController {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        DispatchQueue.main.async {
            _ = self.view
        }
    }
    
    override func loadWebView() {
        var html = Bundle.main.path(forResource: "about", ofType: "html")!
        html = try! String(contentsOfFile: html, encoding: .utf8)
        webView.loadHTMLString(html, baseURL: nil)
    }
    
}
