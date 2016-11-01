//
//  ViewControllerIssue.swift
//  profkom-xai
//
//  Created by Admin on 28.05.15.
//  Copyright (c) 2015 KY1VSTAR. All rights reserved.
//

import UIKit
import WebKit

class IssueViewController: WebViewController {
    
    var dataId: String!
    var dataTitle: String!
    var dataFile: String!
    var loadingView: KSLoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView()
        navigationItem.title = dataTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showActionSheet))
    }
    
    override func loadWebView() {
        getIssue()
    }
    
    func setupLoadingView() {
        loadingView = KSLoadingView()
        loadingView.reloadButtonClicked = {[unowned self] in
            self.reloadIssues()
        }
        loadingView.hide()
        view.addSubview(loadingView)
        view.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func getIssue() {
        webView.load(URLRequest(url: URL(string: "http://profkom.xai.edu.ua/" + dataFile)!))
    }
    
    func reloadIssues() {
        loadingView.hide()
        webView.isHidden = false
        getIssue()
    }
    
    func showActionSheet(_: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Открыть в браузере", style: .default, handler: { _ in
            UIApplication.shared.openURL(URL(string: self.getLink())!)
        }))
        alertController.addAction(UIAlertAction(title: "Открыть в браузере (PDF)", style: .default, handler: { _ in
            UIApplication.shared.openURL(URL(string: "http://profkom.xai.edu.ua/" + self.dataFile)!)
        }))
        alertController.addAction(UIAlertAction(title: "Скопировать ссылку", style: .default, handler: { _ in
            UIPasteboard.general.string = self.getLink()
            Toast.makeToast(message: "Ссылка скопирована в буфер обмена")
        }))
        alertController.addAction(UIAlertAction(title: "Скопировать ссылку (PDF)", style: .default, handler: { _ in
            UIPasteboard.general.string = "http://profkom.xai.edu.ua/" + self.dataFile
            Toast.makeToast(message: "Ссылка скопирована в буфер обмена")
        }))
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func getLink() -> String {
        return "http://profkom.xai.edu.ua/gazet.php?s=" + dataId
    }
    
    override func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        super.webView(webView, didFailProvisionalNavigation: navigation, withError: error)
        webView.isHidden = true
        loadingView.showError()
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)
        webView.isHidden = false
        loadingView.hide()
    }

}
