//
//  MenuViewController.swift
//  profkom-xai
//
//  Created by KY1VSTAR on 29.09.16.
//  Copyright © 2016 KY1VSTAR. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var revealController: SWRevealViewController!
    var previouslySelectedRow = 0
    var items: [(title: String, image: UIImage, viewController: UIViewController)] = []
    weak var overview: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        if isIPhone {
            revealController = revealViewController()
            items.append((title: "Новости", image: UIImage(named: "News")!, viewController: revealController.frontViewController))
        } else {
            items.append((title: "Новости", image: UIImage(named: "News")!, viewController: splitViewController!.viewControllers[1]))
        }
        items.append((title: "Занятия", image: UIImage(named: "Schedule")!, viewController: mainStoryboard.instantiateViewController(withIdentifier: "ScheduleNavigationController")))
        items.append((title: "Преоподаватели", image: UIImage(named: "Schedule")!, viewController: {
            let nc = mainStoryboard.instantiateViewController(withIdentifier: "ScheduleNavigationController") as! UINavigationController
            let vc = nc.viewControllers[0] as! ScheduleViewController
            vc.type = "teacher"
            vc.typeClass = TeacherSchedule.self
            return nc
        }()))
        items.append((title: "Газета \"Взлёт\"", image: UIImage(named: "Newspaper")!, viewController: mainStoryboard.instantiateViewController(withIdentifier: "NewspaperNavigationController")))
        items.append((title: "О нас", image: UIImage(named: "About")!, viewController: mainStoryboard.instantiateViewController(withIdentifier: "AboutNavigationController")))
        items.append((title: "Уведомления", image: UIImage(named: "Notifications")!, viewController: mainStoryboard.instantiateViewController(withIdentifier: "NotificationsNavigationController")))
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
    }
    
    func setupTableView() {
        var frame = view.frame
        frame.origin.y = 20
        frame.size.height -= 20
        tableView = UITableView(frame: frame)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        view.backgroundColor = UIColor(red: 0.219608, green: 0.270588, blue: 0.329412, alpha: 1)
        tableView.backgroundColor = UIColor(red: 0.219608, green: 0.270588, blue: 0.329412, alpha: 1)
        tableView.separatorColor = UIColor(red: 0.282353, green: 0.337255, blue: 0.380392, alpha: 1)
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isIPhone {
            let overview = UIView(frame: revealController.frontViewController.view.frame)
            revealController.frontViewController.view.addSubview(overview)
            self.overview = overview
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overview?.removeFromSuperview()
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel!.textColor = UIColor(red: 0.913725, green: 0.917647, blue: 0.921569, alpha: 1)
        cell.textLabel!.font = UIFont.systemFont(ofSize: 17)
        cell.imageView!.tintColor = UIColor(red: 175 / 255, green: 180 / 255, blue: 186 / 255, alpha: 1)
        cell.backgroundColor = tableView.backgroundColor
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView!.backgroundColor = UIColor(red: 0.184314, green: 0.227451, blue: 0.278431, alpha: 1)
        cell.textLabel!.text = items[indexPath.row].title
        cell.imageView!.image = items[indexPath.row].image.withRenderingMode(.alwaysTemplate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != previouslySelectedRow {
            previouslySelectedRow = indexPath.row
            let viewController = items[indexPath.row].viewController
            if isIPhone {
                revealController.setFront(viewController, animated: false)
            } else {
                splitViewController!.showDetailViewController(viewController, sender: nil)
            }
        }
        if isIPhone {
            revealController.revealToggle(animated: true)
        }
    }
    
}
