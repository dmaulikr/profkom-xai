//
//  ViewControllerPushNewsDetail.swift
//  profkom-xai
//
//  Created by KY1VSTAR on 19.06.15.
//  Copyright (c) 2015 KY1VSTAR. All rights reserved.
//

import UIKit

class PushViewController: WebViewController {
    
    override var isDetailViewController: Bool {
        return false
    }
    
    var dataId = ""
    var dataPage = ""
    var loadingView: KSLoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView()
        reloadNews()
    }

    func setupLoadingView() {
        loadingView = KSLoadingView()
        loadingView.reloadButtonClicked = {[unowned self] in
            self.reloadNews()
        }
        loadingView.hide()
        view.addSubview(loadingView)
        view.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func errorHandler() {
        loadingView.showError()
    }
    
    func reloadNews() {
        loadingView.showLoading()
        Global.setNetworkActivityIndicatorVisible(true)
        let url = URL(string: "http://profkom.xai.edu.ua/api/newsAjax.php?page=\(dataPage)&id=\(dataId)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        let jsonQuery = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            Global.setNetworkActivityIndicatorVisible(false)
            DispatchQueue.main.sync {
                self.loadingView.hide()
            }
            if error != nil {
                DispatchQueue.main.sync {
                    self.errorHandler()
                }
                return
            }
            if let jsonResult = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String: [String: String]] {
                if let news = jsonResult[self.dataId] {
                    if news["tema"] != nil && news["content"] != nil && news["logo"] != nil {
                        let style = news["style"] != nil ? news["style"]! : "1"
                        let logo = style == "0" ? "<center><img src=\"" + news["logo"]! + "\" /></center>" : ""
                        DispatchQueue.main.sync {
                            self.navigationItem.setScrollingTitle(news["tema"]!)
                            self.webView.loadHTMLString("<html><head><style>body {max-width: 100%;} img {max-width: 99%;} iframe {max-width: 95%;}</style></head><body>\(logo + news["content"]!)</body>", baseURL: URL(string: "http://profkom.xai.edu.ua/"))
                            Global.setNetworkActivityIndicatorVisible(true)
                            let request = URLRequest(url: URL(string: "http://profkom.xai.edu.ua/api/newsAjax.php?page=17&razdel=" + (self.dataPage == "11" ? "all" : "work") + "&id=\(self.dataId)")!)
                            NSURLConnection.sendAsynchronousRequest(request, queue: .main, completionHandler: { _, _, _ in
                                Global.setNetworkActivityIndicatorVisible(false)
                            })
                        }
                    }
                } else {
                    DispatchQueue.main.sync {
                        self.errorHandler()
                    }
                }
            } else {
                DispatchQueue.main.sync {
                    self.errorHandler()
                }
            }
        })
        jsonQuery.resume()
    }

    @IBAction func close(_: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showActionSheet(_: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Открыть в браузере", style: .default, handler: { _ in
            UIApplication.shared.openURL(URL(string: self.getLink())!)
        }))
        alertController.addAction(UIAlertAction(title: "Скопировать ссылку", style: .default, handler: { _ in
            UIPasteboard.general.string = self.getLink()
            Toast.makeToast(message: "Ссылка скопирована в буфер обмена")
        }))
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func getLink() -> String {
        return "http://profkom.xai.edu.ua/?page=" + (dataPage == "11" ? "28&news=" : "36&vacancy=") + dataId
    }
    
}
