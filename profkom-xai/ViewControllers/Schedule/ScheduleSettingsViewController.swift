//
//  ViewControllerScheduleFaculty.swift
//  profkom-xai
//
//  Created by Admin on 31.12.14.
//  Copyright (c) 2014 KY1VSTAR. All rights reserved.
//

import UIKit

class ScheduleSettingsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    var type = "group"
    var typeClass = Schedule.self
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBarContainer: UIView!
    @IBOutlet var barButton: UIBarButtonItem!
    
    var searchController = UISearchController(searchResultsController: nil)
    var errorLabel: UILabel!
    var filtredList = [String]()
    var list = [String]()
    var cancelHandler: () -> () = {}
    var currentScheduleID: String?
    var scheduleViewController: ScheduleViewController!
    var presentFrom: UIViewController {
        return presentedViewController ?? self
    }
    var updateTask: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = type == "group" ? "Выберите группу" : "Выберите преподавателя"
        setupSearchController()
        createErrorLabel()
        tableView.tableFooterView = UIView()
        if isIPhone {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        }
        tableView.register(UINib(nibName: "SettingsUpdateCell", bundle: nil), forCellReuseIdentifier: "SettingsUpdateCell")
        tableView.register(UINib(nibName: "SettingsUpdateCheckedCell", bundle: nil), forCellReuseIdentifier: "SettingsUpdateCheckedCell")
        tableView.register(UINib(nibName: "SettingsDownloadCell", bundle: nil), forCellReuseIdentifier: "SettingsDownloadCell")
        reloadData(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTask?()
    }
    
    func setupSearchController() {
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        if type == "group" {
            searchController.searchBar.keyboardType = .numbersAndPunctuation
        }
        searchBarContainer.addSubview(searchController.searchBar)
    }
    
    deinit {
        if isIPhone {
            NotificationCenter.default.removeObserver(self)
        }
        searchController.view.removeFromSuperview()
    }
    
    @IBAction func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func createErrorLabel() {
        errorLabel = UILabel()
        errorLabel.textColor = .lightGray
        errorLabel.textAlignment = .center
        errorLabel.text = type == "group" ? "Список групп пуст" : "Список преподавателей пуст"
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: navigationController!.navigationBar.frame.maxY / 2))
    }
    
    @IBAction func buttonPressed() {
        searchController.searchBar.resignFirstResponder()
        showDownloadBar()
        updateList()
    }

    func keyboardWillShow(_ notification: Notification) {
        let keyboardHeight = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size.height
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardHeight - 44, 0)
        let animationDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve)), animations: { 
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
            }, completion: nil)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let animationDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve)), animations: {
            self.tableView.contentInset = .zero
            self.tableView.scrollIndicatorInsets = .zero
            }, completion: nil)
    }
    
    func reloadData(_ updateList: Bool) {
        cancelHandler = {}
        if typeClass.isListLoaded() {
            errorLabel.isHidden = true
            if updateList {
                list = typeClass.getList()
            }
            updateListWithFilter(searchController.searchBar.text!)
            searchController.searchBar.isHidden = false
            tableView.isHidden = false
        } else {
            errorLabel.isHidden = false
            searchController.searchBar.isHidden = true
            barButton.isEnabled = false
            updateTask = {
                DispatchQueue.main.async {
                    self.barButton.isEnabled = true
                    self.showDownloadBar()
                    self.updateList()
                }
                self.updateTask = nil
            }
        }
    }
    
    func checkFunc(_ str: String, filter: String) -> Bool {
        return type == "group" ? str.hasPrefix(filter) : str.range(of: filter) != nil
    }
    
    func updateListWithFilter(_ filterString: String) {
        var array = [String]()
        var currentScheduleIDIndex = -1
        for el in list {
            if filterString == "" || checkFunc(el.lowercased(), filter: filterString.lowercased()) {
                array.append(el)
                if currentScheduleID == el {
                    currentScheduleIDIndex = array.count - 1
                }
            }
        }
        filtredList = array
        tableView.reloadData()
        if filterString == "" && currentScheduleIDIndex > -1 {
            tableView.scrollToRow(at: IndexPath(row: currentScheduleIDIndex, section: 0), at: .top, animated: true)
        } else if filtredList.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func showDownloadBar() {
        let alertController = UIAlertController(title: "Загрузка...", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Отменить", style: .cancel) { _ in
            self.cancelHandler()
        })
        presentFrom.present(alertController, animated: true, completion: nil)
    }
    
    func errorHandler() {
        dismiss(animated: true) {
            let alertController = UIAlertController(title: "Ошибка", message: "Ошибка при загрузке данных", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
            self.presentFrom.present(alertController, animated: true, completion: nil)
        }
    }
    
    func chooseID(_ id: String, schedule: Schedule) {
        UserDefaults.standard.set(id, forKey: self.type)
        UserDefaults.standard.synchronize()
        self.scheduleViewController.schedule = schedule
        self.scheduleViewController.currentScheduleID = id
        self.scheduleViewController.reloadPageViewController()
        searchController.setEditing(false, animated: false)
        if presentedViewController != nil {
            dismiss(animated: false) {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func updateList() {
        cancelHandler = typeClass.updateList { list in
            if list == nil {
                self.errorHandler()
            } else {
                self.dismiss(animated: true, completion: nil)
                self.list = list!
                Toast.makeToast(message: "Список \(self.type == "group" ? "групп" : "преподавателей") обновлен")
                self.reloadData(false)
            }
        }
    }
    
    func downloadScheduleForID(_ id: String, openSchedule: Bool) {
        showDownloadBar()
        cancelHandler = typeClass.downloadScheduleForID(id) { schedule in
            if schedule == nil {
                self.errorHandler()
            } else {
                self.presentFrom.dismiss(animated: true) {
                    Toast.makeToast(message: "Расписание \(self.type == "group" ? "для группы" : "преподавателя") \(id) обновлено" )
                    if openSchedule {
                        self.chooseID(id, schedule: schedule!)
                    } else {
                        var row = -1
                        for i in 0 ..< self.filtredList.count {
                            if self.filtredList[i] == id {
                                row = i
                                break
                            }
                        }
                        if row > -1 {
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .left)
                            self.tableView.endUpdates()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return errorLabel.isHidden ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return type == "group" ? "ГРУППЫ" : "ПРЕПОДАВАТЕЛИ"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SettingsCell!
        let isLoaded = typeClass.isLoaded(id: filtredList[indexPath.row])
        if isLoaded && currentScheduleID == filtredList[indexPath.row] {
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsUpdateCheckedCell") as! SettingsCell
        } else if isLoaded {
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsUpdateCell") as! SettingsCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsDownloadCell") as! SettingsCell
        }
        cell.titleLabel.text = filtredList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! SettingsCell).titleLabel.restart()
        cell.separatorInset = .zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let scheduleID = filtredList[indexPath.row]
        let alertController = UIAlertController(title: "\(type == "group" ? "Группа " : "")\(scheduleID)", message: nil, preferredStyle: .actionSheet)
        if typeClass.isLoaded(id: scheduleID) && scheduleID == currentScheduleID {
            alertController.addAction(UIAlertAction(title: "Обновить", style: .default, handler: { _ in
                self.downloadScheduleForID(scheduleID, openSchedule: false)
            }))
        } else if typeClass.isLoaded(id: scheduleID) {
            alertController.addAction(UIAlertAction(title: "Выбрать", style: .default, handler: { _ in
                self.chooseID(scheduleID, schedule: self.typeClass.init(id: scheduleID))
            }))
            alertController.addAction(UIAlertAction(title: "Обновить и выбрать", style: .default, handler: { _ in
                self.downloadScheduleForID(scheduleID, openSchedule: true)
            }))
            alertController.addAction(UIAlertAction(title: "Обновить", style: .default, handler: { _ in
                self.downloadScheduleForID(scheduleID, openSchedule: false)
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "Загрузить и выбрать", style: .default, handler: { _ in
                self.downloadScheduleForID(scheduleID, openSchedule: true)
            }))
            alertController.addAction(UIAlertAction(title: "Загрузить", style: .default, handler: { _ in
                self.downloadScheduleForID(scheduleID, openSchedule: false)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = view
            let cellRectOnScreen = tableView.convert(tableView.rectForRow(at: indexPath), to: view)
            popoverPresentationController.sourceRect = cellRectOnScreen
        }
        presentFrom.present(alertController, animated: true, completion: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateListWithFilter("")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateListWithFilter(searchText)
    }
    
}
