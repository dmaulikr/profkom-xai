//
//  WebViewController.swift
//  profkom-xai
//
//  Created by KY1VSTAR on 28.09.16.
//  Copyright © 2016 KY1VSTAR. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: BaseViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var isLinksEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=100%, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta); setTimeout(\"document.body.scrollTop = document.documentElement.scrollTop = 0;\", 1)"
        let wkUScript = WKUserScript(source: jScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(wkUScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController
        
        webView = WKWebView(frame: view.frame, configuration: wkWebConfig)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        view.addSubview(webView)
        setupProgressView()
        loadWebView()
    }
    
    func loadWebView() {
    }
    
    func setupProgressView() {
        progressView = UIProgressView(frame: CGRect(x: -20, y: navigationController!.navigationBar.frame.maxY, width: view.frame.width + 40, height: 2))
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(progressView, aboveSubview: webView)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Global.setNetworkActivityIndicatorVisible(true)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Global.setNetworkActivityIndicatorVisible(false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Global.setNetworkActivityIndicatorVisible(false)
        isLinksEnabled = false
        progressView.setProgress(0.0, animated: false)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if !isLinksEnabled {
            UIApplication.shared.openURL(navigationAction.request.url!)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
}

