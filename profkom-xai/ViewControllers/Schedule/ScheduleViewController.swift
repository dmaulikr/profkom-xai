//
//  ViewControllerSchedule.swift
//  profkom-xai
//
//  Created by Admin on 31.12.14.
//  Copyright (c) 2014 KY1VSTAR. All rights reserved.
//

import UIKit

class ScheduleViewController: PagerController, PagerDataSource {
    
    var type = "group"
    var typeClass = Schedule.self
    
    var errorLabel: UILabel!
    var currentScheduleID: String!
    var schedule: Schedule!
    var viewControllers = [SchedulePageViewController]()
    var isCurrentlyVisible = false
    var updateTask: (() -> ())?
    var isUpdateCanceled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        navigationController!.interactivePopGestureRecognizer?.isEnabled = false
        createErrorLabel()
        loadSchedule()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateWeekType()
        isCurrentlyVisible = true
        if !isUpdateCanceled && updateTask == nil && errorLabel.isHidden {
            checkForUpdate()
        } else if !isUpdateCanceled {
            updateTask?()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isCurrentlyVisible = false
    }
    
    func updateWeekType() {
        if Calendar(identifier: .gregorian).component(.weekOfYear, from: Date()) % 2 == 0 {
            navigationItem.title = "Числитель"
        } else {
            navigationItem.title = "Знаменатель"
        }
    }
    
    func createErrorLabel() {
        errorLabel = UILabel()
        errorLabel.textColor = .lightGray
        errorLabel.text = type == "group" ? "Группа не выбрана" : "Преподаватель не выбран"
        errorLabel.isHidden = true
        errorLabel.sizeToFit()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: navigationController!.navigationBar.frame.maxY / 2))
    }
    
    func loadSchedule() {
        currentScheduleID = UserDefaults.standard.string(forKey: type)
        if currentScheduleID == nil || currentScheduleID == "" || !typeClass.isLoaded(id: currentScheduleID) {
            errorLabel.isHidden = false
            setupViewControllers(hidden: true)
            DispatchQueue.main.async {
                self.openSettings()
            }
        } else {
            navigationItem.prompt = currentScheduleID
            setupViewControllers(hidden: false)
        }
    }
    
    func checkForUpdate() {
        let currentScheduleID = self.currentScheduleID!
        _ = typeClass.downloadScheduleForID(currentScheduleID, fileName: "temp\(type)") { schedule in
            if schedule != nil {
                self.updateTask = {
                    
                    if self.isCurrentlyVisible && self.presentedViewController == nil {
                        let newPath = documentsDirectory.appendingPathComponent("temp\(self.type)-\(currentScheduleID).plist")
                        if currentScheduleID == self.currentScheduleID {
                            let oldPath = documentsDirectory.appendingPathComponent("\(self.type)-\(currentScheduleID).plist")
                            self.updateTask = nil
                            if !FileManager.default.contentsEqual(atPath: oldPath, andPath: newPath) {
                                let alertController = UIAlertController(title: "Уведомление", message: "Расписание для \(self.type == "group" ? "группы" : "преподавателя") \(currentScheduleID) устарело. Обновить?", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "Обновить", style: .default) { _ in
                                    try! FileManager.default.removeItem(atPath: oldPath)
                                    try! FileManager.default.moveItem(atPath: newPath, toPath: oldPath)
                                    self.schedule = schedule
                                    self.reloadPageViewController()
                                })
                                alertController.addAction(UIAlertAction(title: "Отменить", style: .cancel) { _ in
                                    self.isUpdateCanceled = true
                                    try! FileManager.default.removeItem(atPath: newPath)
                                })
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                try! FileManager.default.removeItem(atPath: newPath)
                            }
                        } else {
                            try! FileManager.default.removeItem(atPath: newPath)
                            self.updateTask = nil
                        }
                    }
                    
                }
                self.updateTask!()
            }
        }
    }
    
    func setupViewControllers(hidden: Bool) {
        if !hidden {
            navigationController!.navigationBar.hideBottomHairline()
            schedule = typeClass.init(id: currentScheduleID)
        }
        isPageViewControllerHidden = hidden
        for i in 1...5 {
            let vc = SchedulePageViewController()
            vc.day = i
            vc.type = type
            vc.schedule = schedule
            vc.scheduleViewController = self
            viewControllers.append(vc)
        }
        setupPager(tabNames: ["ПН", "ВТ", "СР", "ЧТ", "ПТ"], tabControllers: viewControllers)
        customizeTab()
    }
    
    func customizeTab() {
        view.backgroundColor = .white
        indicatorColor = Global.tintColor
        tabsViewBackgroundColor = Global.barTintColor
        contentViewBackgroundColor = .white
        
        var weekday = Calendar(identifier: .gregorian).component(.weekday, from: Date()) - 2
        if weekday > 4 || weekday < 0 {
            weekday = 0
        }
        selectTabAtIndex(weekday, swipe: true)
        startIndex = weekday
        centerCurrentTab = true
        tabLocation = .top
        tabHeight = 44
        tabOffset = 0
        if isIPhone{
            tabWidth = view.frame.width / 5
        } else {
            tabWidth = 113
        }
        fixFormerTabsPositions = false
        fixLaterTabsPosition = false
        animation = .during
        tabsTextColor = .black
        selectedTabTextColor = Global.tintColor
        tabsTextFont = .systemFont(ofSize: 17)
    }
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        openSettings()
    }
    
    func openSettings() {
        let nc = storyboard!.instantiateViewController(withIdentifier: "ScheduleSettingsNavigationController") as! UINavigationController
        let vc = nc.viewControllers[0] as! ScheduleSettingsViewController
        vc.scheduleViewController = self
        vc.currentScheduleID = currentScheduleID
        vc.type = type
        vc.typeClass = typeClass
        if !isIPhone {
            nc.modalPresentationStyle = .popover
            let popover = nc.popoverPresentationController!
            nc.preferredContentSize = CGSize(width: 9999, height: 9999)
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(nc, animated: true, completion: nil)
    }
    
    func reloadPageViewController() {
        navigationItem.prompt = currentScheduleID
        schedule = typeClass.init(id: currentScheduleID)
        for vc in viewControllers {
            vc.schedule = schedule
            _ = vc.view
            vc.tableView.reloadData()
        }
        if !errorLabel.isHidden {
            errorLabel.isHidden = true
            navigationController!.navigationBar.hideBottomHairline()
            isPageViewControllerHidden = false
        }
    }

}
