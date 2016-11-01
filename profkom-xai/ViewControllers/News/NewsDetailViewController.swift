//
//  ViewControllerNewsPage.swift
//  profkom-xai
//
//  Created by Admin on 23.12.14.
//  Copyright (c) 2014 KY1VSTAR. All rights reserved.
//

import UIKit
import WebKit

class NewsDetailViewController: WebViewController {

    var dataId = ""
    var dataType = ""
    var dataTitle = ""
    var dataContent = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setScrollingTitle(dataTitle)
        Global.setNetworkActivityIndicatorVisible(true)
        let request = URLRequest(url: URL(string: "http://profkom.xai.edu.ua/api/newsAjax.php?page=27&razdel=\(dataType)&id=\(dataId)")!)
        NSURLConnection.sendAsynchronousRequest(request, queue: .main) {(_, _, _) in
            Global.setNetworkActivityIndicatorVisible(false)
        }
    }
    
    override func loadWebView() {
        webView.loadHTMLString("<html><head><style>body {max-width: 100%;} img {max-width: 99%;} iframe {max-width: 95%;}</style></head><body>\(dataContent)</body>", baseURL: URL(string: "http://profkom.xai.edu.ua/"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.showBottomHairline()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController!.navigationBar.hideBottomHairline()
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
        return "http://profkom.xai.edu.ua/?page=" + (dataType == "all" ? "28&news=" : "36&vacancy=") + dataId
    }

}
