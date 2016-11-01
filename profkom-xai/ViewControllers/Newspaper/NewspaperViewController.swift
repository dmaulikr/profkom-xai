//
//  ViewControllerNewspaper.swift
//  profkom-xai
//
//  Created by Admin on 28.05.15.
//  Copyright (c) 2015 KY1VSTAR. All rights reserved.
//

import UIKit

class NewspaperViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var defaultImage: UIImage!
    var insets: UIEdgeInsets!
    var loadingView: KSLoadingView!
    
    var Issues = [ElementIssue]()
    var IssuesStart = 0
    var IssuesDownloading = false
    var rowsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView()
        navigationController!.interactivePopGestureRecognizer?.isEnabled = false
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "IssueCell", bundle: nil), forCellReuseIdentifier: "IssueCell")
        defaultImage = UIImage.imageWithColor(Global.placeholderImageColor, size: CGSize(width: 180, height: 120))
        reloadIssues()
    }
    
    func setupLoadingView() {
        let backgroundView = UIView()
        loadingView = KSLoadingView()
        loadingView.reloadButtonClicked = reloadIssues
        backgroundView.addSubview(loadingView)
        backgroundView.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: backgroundView, attribute: .centerX, multiplier: 1, constant: 0))
        backgroundView.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: backgroundView, attribute: .centerY, multiplier: 1, constant: 0))
        tableView.backgroundView = backgroundView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !loadingView.isErrorHidden {
            reloadIssues()
        }
        super.viewDidAppear(animated)
    }
    
    func errorHandler() {
        if Issues.count == 0 {
            loadingView.showError()
        }
    }
    
    func reloadIssues() {
        loadingView.hide()
        tableView.reloadData()
        if Issues.count == 0 {
            loadingView.showLoading()
            getIssues()
        }
    }
    
    func getIssues() {
        if IssuesDownloading {
            return
        }
        IssuesDownloading = true
        Global.setNetworkActivityIndicatorVisible(true)
        let url = URL(string: "http://profkom.xai.edu.ua/api/newsAjax.php?page=18&start=\(IssuesStart)&step=25")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        let jsonQuery = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            Global.setNetworkActivityIndicatorVisible(false)
            if error != nil {
                self.IssuesDownloading = false
                DispatchQueue.main.sync(execute: {
                    self.errorHandler()
                })
                return
            }
            if let jsonResult = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String: [String: String]] {
                let jsonResult = jsonResult.sorted { Int($0.0)! > Int($1.0)! }
                var indexPaths = [IndexPath]()
                for (key, value) in jsonResult {
                    if value["tema"] != nil && value["file"] != nil && value["tags"] != nil && value["logo"] != nil && value["view"] != nil {
                        let description = value["tags"]!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                        var textHeight: CGFloat!
                        DispatchQueue.main.sync {
                            let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 30, height: 1))
                            textView.text = description
                            textHeight = textView.sizeThatFits(textView.frame.size).height
                        }
                        self.Issues.append(ElementIssue(id: key, title: value["tema"]!, fileURL: value["file"]!, description: value["tags"]!, descriptionHeight: textHeight, logoURL: value["logo"]!, view: value["view"]!))
                        indexPaths.append(IndexPath(row: self.Issues.count - 1, section: 0))
                    }
                }
                DispatchQueue.main.sync(execute: {
                    self.rowsCount = self.Issues.count
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: indexPaths, with: .middle)
                    self.tableView.endUpdates()
                })
                self.IssuesStart += 25
                self.IssuesDownloading = false
            } else {
                self.IssuesDownloading = false
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "IssueCell") as! IssueCell
        if Issues.count >= IssuesStart && indexPath.row > Issues.count - 15 {
            getIssues()
        }
        cell.titleLabel.text = Issues[indexPath.row].title
        cell.logoView.sd_setImage(with: URL(string: "http://profkom.xai.edu.ua/" + Issues[indexPath.row].logoURL), placeholderImage: defaultImage)
        cell.textView.text = Issues[indexPath.row].description
        cell.textConstraintHeight.constant = Issues[indexPath.row].descriptionHeight
        cell.viewsLabel.text = "Просмотров: " + Issues[indexPath.row].view
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 176.0 + Issues[indexPath.row].descriptionHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showPageWithIssue(Issues[indexPath.row].id, title: Issues[indexPath.row].title, file: Issues[indexPath.row].fileURL)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
    }
    
    func showPageWithIssue(_ id: String, title: String, file: String) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "IssueViewController") as! IssueViewController
        vc.dataId = id
        vc.dataTitle = title
        vc.dataFile = file
        navigationController!.pushViewController(vc, animated: true)
    }

}
