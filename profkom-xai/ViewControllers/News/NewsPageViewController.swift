//
//  ViewControllerNews.swift
//  profkom-xai
//
//  Created by Admin on 18.12.14.
//  Copyright (c) 2014 KY1VSTAR. All rights reserved.
//

import UIKit

class NewsPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var rootViewController: NewsViewController!
    var page: String!
    var loadingView: KSLoadingView!
    var defaultImage: UIImage!
    
    var News = [ElementNews]()
    var NewsStart = 0
    var NewsDownloading = false
    var TopNewsImageSize: CGSize!
    var rowsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView()
        tableView.tableFooterView = UIView()
        let width = view.frame.size.width - 30
        if width >= 524 {
            TopNewsImageSize = CGSize(width: 524.0, height: 348.0)
        } else {
            TopNewsImageSize = CGSize(width: width, height: width / 524.0 * 348.0)
        }
        if page != "4" {
            tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
            defaultImage = UIImage.imageWithColor(Global.placeholderImageColor, size: CGSize(width: 180, height: 120))
        } else {
            tableView.register(UINib(nibName: "TopNewsCell", bundle: nil), forCellReuseIdentifier: "TopNewsCell")
            defaultImage = UIImage.imageWithColor(Global.placeholderImageColor, size: TopNewsImageSize)
        }
        reloadNews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !loadingView.isErrorHidden {
            reloadNews()
        }
        super.viewDidAppear(animated)
    }
    
    func setupLoadingView() {
        let backgroundView = UIView()
        loadingView = KSLoadingView()
        loadingView.reloadButtonClicked = reloadNews
        backgroundView.addSubview(loadingView)
        backgroundView.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: backgroundView, attribute: .centerX, multiplier: 1, constant: 0))
        backgroundView.addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: backgroundView, attribute: .centerY, multiplier: 1, constant: 0))
        tableView.backgroundView = backgroundView
    }
    
    func errorHandler() {
        if News.count == 0 {
            loadingView.showError()
        }
    }
    
    func reloadNews() {
        loadingView.hide()
        if News.count == 0 {
            loadingView.showLoading()
            getNews()
        }
    }
    
    func getNews() {
        if NewsDownloading {
            return
        }
        NewsDownloading = true
        Global.setNetworkActivityIndicatorVisible(true)
        let url = URL(string: "http://profkom.xai.edu.ua/api/newsAjax.php?page=\(page!)&start=\(NewsStart)&step=25")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        let jsonQuery = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            Global.setNetworkActivityIndicatorVisible(false)
            if error != nil {
                self.NewsDownloading = false
                DispatchQueue.main.sync(execute: {
                    self.errorHandler()
                })
                return
            }
            if let jsonResult = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String: [String: String]] {
                let jsonResult = jsonResult.sorted { Int($0.0)! > Int($1.0)! }
                var indexPaths = [IndexPath]()
                if self.page != "4" {
                    for (key, value) in jsonResult {
                        if value["tema"] != nil && value["date"] != nil && value["content"] != nil && value["description"] != nil && value["logo"] != nil && value["view"] != nil {
                            let description = value["description"]!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                            var textHeight: CGFloat!
                            DispatchQueue.main.sync {
                                let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 30, height: 1))
                                textView.text = description
                                textHeight = textView.sizeThatFits(textView.frame.size).height
                            }
                            self.News.append(ElementNews(id: key, title: value["tema"]!, style: value["style"] != nil ? value["style"]! : "1", date: value["date"]!, content: value["content"]!, description: description, descriptionHeight: textHeight, logoURL: value["logo"]!, view: value["view"]!))
                            indexPaths.append(IndexPath(row: self.News.count - 1, section: 0))
                        }
                    }
                } else {
                    for (key, value) in jsonResult {
                        if value["tema"] != nil && value["date"] != nil && value["content"] != nil && value["logo"] != nil && value["view"] != nil {
                            self.News.append(ElementNews(id: key, title: value["tema"]!, style: value["style"] != nil ? value["style"]! : "1", date: value["date"]!, content: value["content"]!, description: nil, descriptionHeight: nil, logoURL: value["logo"]!, view: value["view"]!))
                            indexPaths.append(IndexPath(row: self.News.count - 1, section: 0))
                        }
                    }
                }
                DispatchQueue.main.sync {
                    self.rowsCount = self.News.count
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: indexPaths, with: .middle)
                    self.tableView.endUpdates()
                }
                self.NewsStart += 25
                self.NewsDownloading = false
            } else {
                self.NewsDownloading = false
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
        if page != "4" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
            if News.count >= NewsStart && indexPath.row > News.count - 15 {
                getNews()
            }
            cell.titleLabel.text = News[indexPath.row].title
            cell.dateLabel.text = News[indexPath.row].date
            cell.logoView.sd_setImage(with: URL(string: "http://profkom.xai.edu.ua/" + News[indexPath.row].logoURL), placeholderImage: defaultImage)
            cell.textView.text = News[indexPath.row].description!
            cell.textConstraintHeight.constant = News[indexPath.row].descriptionHeight!
            cell.viewsLabel.text = "Просмотров: " + News[indexPath.row].view
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopNewsCell") as! TopNewsCell
        if News.count >= NewsStart && indexPath.row > News.count - 15 {
            getNews()
        }
        cell.titleLabel.text = News[indexPath.row].title
        cell.dateLabel.text = News[indexPath.row].date
        cell.logoView.sd_setImage(with: URL(string: "http://profkom.xai.edu.ua/" + News[indexPath.row].logoURL), placeholderImage: defaultImage)
        cell.viewsLabel.text = "Просмотров: " + News[indexPath.row].view
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if page != "4" {
            return 192.0 + News[indexPath.row].descriptionHeight!
        }
        return 78.0 + TopNewsImageSize.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var razdel: String
        switch page {
        case "5":
            razdel = "work"
        default:
            razdel = "all"
        }
        showPageWithNews(News[indexPath.row].id, type: razdel, title: News[indexPath.row].title, content: (News[indexPath.row].style == "0" ? "<center><img src=\"" + News[indexPath.row].logoURL + "\" /></center>" : "") + News[indexPath.row].content)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
    }
    
    func showPageWithNews(_ id: String, type: String, title: String, content: String) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
        vc.dataId = id
        vc.dataType = type
        vc.dataTitle = title
        vc.dataContent = content
        rootViewController.navigationController!.pushViewController(vc, animated: true)
    }

}
