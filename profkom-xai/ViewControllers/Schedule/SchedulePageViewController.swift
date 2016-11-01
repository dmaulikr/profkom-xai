//
//  ViewControllerSchedulePage.swift
//  profkom-xai
//
//  Created by Admin on 07.01.15.
//  Copyright (c) 2015 KY1VSTAR. All rights reserved.
//

import UIKit

class SchedulePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var type = "group"
    
    var tableView: UITableView!
    var day: Int!
    var schedule: Schedule!
    var scheduleViewController: ScheduleViewController!
    let times = ["1. 08:00 - 9:35", "2. 09:50 - 11:25", "3. 11:55 - 13:30", "4. 13:45 - 15:20", "5. 15:35 - 17:10", "6. 17:25 - 19:00"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: view.frame)
        tableView.allowsSelection = false
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        tableView.register(UINib(nibName: "SingleScheduleCell", bundle: nil), forCellReuseIdentifier: "SingleScheduleCell")
        view.addSubview(tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return schedule == nil ? 0 : schedule.countOfLessonsForDay(day: day)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return times[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let v = view as! UITableViewHeaderFooterView
        v.backgroundView?.backgroundColor = .gray
        v.textLabel?.textColor = .white
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.countOfVariantsForLesson(lesson: section + 1, atDay: day)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lessonInfo = schedule.lessonInfoForLessonVariant(lessonVariant: indexPath.row, lesson: indexPath.section + 1, atDay: day)
        if lessonInfo.subject == "" && lessonInfo.classroom == "" {
            var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                cell.textLabel!.textAlignment = .center
                cell.textLabel!.text = "Пары нет"
            }
            return cell
        } else if lessonInfo.classroom != "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell") as! ScheduleCell
            cell.titleLabel.text = lessonInfo.subject
            cell.classroomLabel.text = lessonInfo.classroom
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleScheduleCell") as! SingleScheduleCell
            cell.titleLabel.text = lessonInfo.subject
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let lessonInfo = schedule.lessonInfoForLessonVariant(lessonVariant: indexPath.row, lesson: indexPath.section + 1, atDay: day)
        var details: String? = lessonInfo.details == "" ? nil : lessonInfo.details
        if details != nil && type == "teacher" {
            details = details!.range(of: ", ") == nil ? "Группа \(details!)" : "Группы \(details!)"
        }
        let alertController = UIAlertController(title: lessonInfo.type == 0 ? "Практика" : "Лекция", message: details, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
        scheduleViewController.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.reuseIdentifier == "ScheduleCell" {
            (cell as! ScheduleCell).titleLabel.restart()
        } else if cell.reuseIdentifier == "SingleScheduleCell" {
            (cell as! SingleScheduleCell).titleLabel.restart()
        }
        cell.separatorInset = .zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
    }

}
