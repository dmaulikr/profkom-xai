//
//  ViewControllerPush.swift
//  profkom-xai
//
//  Created by Admin on 25.12.14.
//  Copyright (c) 2014 KY1VSTAR. All rights reserved.
//

import UIKit

class NotificationsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var loadingView: KSLoadingView!
    var Notifications = [ElementNotification]()
    var NotificationsStart = 0
    var NotificationsDownloading = false
    var rowsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView()
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        reloadNotifications()
    }
    
    func setupLoadingView() {
        let backgroundView = UIView()
        loadingView = KSLoadingView()
        loadingView.reloadButtonClicked = reloadNotifications
        backgroundView.addSubview(loadingView)
        backgroundView.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: backgroundView, attribute: .centerX, multiplier: 1, constant: 0))
        backgroundView.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: backgroundView, attribute: .centerY, multiplier: 1, constant: 0))
        tableView.backgroundView = backgroundView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !loadingView.isErrorHidden {
            reloadNotifications()
        }
        super.viewDidAppear(animated)
    }
    
    func errorHandler() {
        if Notifications.count == 0 {
            loadingView.showError()
        }
    }
    
    func reloadNotifications() {
        loadingView.hide()
        tableView.reloadData()
        if Notifications.count == 0 {
            loadingView.showLoading()
            getNotifications()
        }
    }
    
    func getNotifications() {
        if NotificationsDownloading {
            return
        }
        NotificationsDownloading = true
        Global.setNetworkActivityIndicatorVisible(true)
        let url = URL(string: "http://profkom.xai.edu.ua/api/newsAjax.php?page=14&start=\(NotificationsStart)&step=25")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        let jsonQuery = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            Global.setNetworkActivityIndicatorVisible(false)
            if error != nil {
                self.NotificationsDownloading = false
                DispatchQueue.main.sync(execute: {
                    self.errorHandler()
                })
                return
            }
            if let jsonResult = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String: [String: String]] {
                let jsonResult = jsonResult.sorted { Int($0.0)! > Int($1.0)! }
                var indexPaths = [IndexPath]()
                for (_, value) in jsonResult {
                    if value["mes"] != nil && value["date"] != nil {
                        var textHeight: CGFloat!
                        DispatchQueue.main.sync {
                            let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 30, height: 1))
                            textView.font = .systemFont(ofSize: 14)
                            textView.isSelectable = true
                            textView.dataDetectorTypes = [.link, .phoneNumber]
                            textView.text = value["mes"]!
                            textHeight = textView.sizeThatFits(textView.frame.size).height
                        }
                        self.Notifications.append(ElementNotification(message: value["mes"]!, messageHeight: textHeight, date: value["date"]!))
                        indexPaths.append(IndexPath(row: self.Notifications.count - 1, section: 0))
                    }
                }
                DispatchQueue.main.sync(execute: {
                    self.rowsCount = self.Notifications.count
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: indexPaths, with: .middle)
                    self.tableView.endUpdates()
                })
                self.NotificationsStart += 25
                self.NotificationsDownloading = false
            } else {
                self.NotificationsDownloading = false
                DispatchQueue.main.sync(execute: {
                    self.errorHandler()
                })
            }
        })
        jsonQuery.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadingView.hide()
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
        if Notifications.count >= NotificationsStart && indexPath.row > Notifications.count - 15 {
            getNotifications()
        }
        cell.dateLabel.text = Notifications[indexPath.row].date
        cell.textView.text = Notifications[indexPath.row].message
        cell.textConstraintHeight.constant = Notifications[indexPath.row].messageHeight
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32.0 + Notifications[indexPath.row].messageHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
    }

}
