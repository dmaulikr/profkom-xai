//
//  Schedule.swift
//  profkom-xai
//
//  Created by KY1VSTAR on 29.09.16.
//  Copyright © 2016 KY1VSTAR. All rights reserved.
//

import Foundation

class Schedule: NSObject {
    
    var type: String {
        return "group"
    }
    class var type: String {
        return "group"
    }
    typealias LessonInfo = (subject: String, classroom: String, type: Int, details: String)
    private var scheduleDictionary: [String: [String: [String: [String: String]]]]!
    
    required init(id: String) {
        super.init()
        scheduleDictionary = NSDictionary(contentsOfFile: documentsDirectory.appendingPathComponent("\(type)-\(id).plist")) as! [String: [String: [String: [String: String]]]]
    }
    
    internal required init(scheduleDictionary: [String: [String: [String: [String: String]]]]) {
        self.scheduleDictionary = scheduleDictionary
    }
    
    class func isLoaded(id: String) -> Bool {
        return FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("\(type)-\(id).plist"))
    }
    
    class func isListLoaded() -> Bool {
        return FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("\(type)s.plist"))
    }
    
    func countOfLessonsForDay(day: Int) -> Int {
        return scheduleDictionary["\(day)"]!.count
    }
    
    func countOfVariantsForLesson(lesson: Int, atDay: Int) -> Int {
        return scheduleDictionary["\(atDay)"]!["\(lesson)"]!.count
    }
    
    func lessonInfoForLessonVariant(lessonVariant: Int, lesson: Int, atDay: Int) -> LessonInfo {
        let temp = scheduleDictionary["\(atDay)"]!["\(lesson)"]!["\(lessonVariant)"]!
        return LessonInfo(subject: temp["subject"]!, classroom: temp["classroom"]!, type: temp["type"]! == "" ? 0 : Int(temp["type"]!)!, details: temp[type == "group" ? "teacher" : "group"]!)
    }
    
    class func getList() -> [String] {
        return NSArray(contentsOfFile: documentsDirectory.appendingPathComponent("\(type)s.plist")) as! [String]
    }
    
    class func updateList(completionHandler: @escaping ([String]?) -> ()) -> (() -> ()) {
        if type == "group" {
            return updateList(page: "15", keyword: "group", fileName: "groups", completionHandler: completionHandler)
        } else {
            return updateList(page: "16", keyword: "lecturer", fileName: "teachers", completionHandler: completionHandler)
        }
    }
    
    class func downloadScheduleForID(_ id: String, fileName: String? = nil, completionHandler: @escaping (Schedule?) -> ()) -> (() -> ()) {
        if type == "group" {
            return downloadScheduleForID(page: "15", firstKeyword: "group", secondKeyword: "teacher", thirdKeyword: "lecturer", id: id, fileName: fileName ?? "group", completionHandler: completionHandler)
        } else {
            return downloadScheduleForID(page: "16", firstKeyword: "lecturer", secondKeyword: "group", thirdKeyword: "group", id: id, fileName: fileName ?? "teacher", completionHandler: completionHandler)
        }
        
    }
    
    private class func updateList(page: String, keyword: String, fileName: String, completionHandler: @escaping ([String]?) -> ()) -> (() -> ()) {
        Global.setNetworkActivityIndicatorVisible(true)
        let url = URL(string: "http://profkom.xai.edu.ua/api/newsAjax.php?page=\(page)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        let jsonQuery = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            Global.setNetworkActivityIndicatorVisible(false)
            if error != nil {
                DispatchQueue.main.sync(execute: {
                    completionHandler(nil)
                })
                return
            }
            if let jsonResult = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? NSArray {
                let list = NSMutableArray()
                for element in jsonResult {
                    if let element = element as? NSDictionary {
                        if let element = element[keyword] as? String {
                            list.add(element)
                        }
                    }
                }
                list.sort(using: [NSSortDescriptor(key: "self", ascending: true)])
                if list.count == 0 {
                    DispatchQueue.main.sync(execute: {
                        completionHandler(nil)
                    })
                    return
                }
                if list.write(toFile: documentsDirectory.appendingPathComponent("\(fileName).plist"), atomically: true) {
                    DispatchQueue.main.sync(execute: {
                        completionHandler(((list as NSArray) as? [String])!)
                    })
                    return
                }
                DispatchQueue.main.sync(execute: {
                    completionHandler(nil)
                })
            } else {
                DispatchQueue.main.sync(execute: {
                    completionHandler(nil)
                })
            }
        })
        jsonQuery.resume()
        return { [weak jsonQuery] in
            jsonQuery?.suspend()
        }
    }
    
    private class func downloadScheduleForID(page: String, firstKeyword: String, secondKeyword: String, thirdKeyword: String, id: String, fileName: String, completionHandler: @escaping (Schedule?) -> ()) -> (() -> ()) {
        Global.setNetworkActivityIndicatorVisible(true)
        let url = URL(string: "http://profkom.xai.edu.ua/api/newsAjax.php?page=\(page)&\(firstKeyword)=\(id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!
        let request = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        let jsonQuery = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            Global.setNetworkActivityIndicatorVisible(false)
            if error != nil {
                DispatchQueue.main.sync(execute: {
                    completionHandler(nil)
                })
                return
            }
            if let jsonResult = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? NSArray {
                var schedule = [String: [String: [String: [String: String]]]]()
                for i in 1...5 {
                    schedule[String(i)] = [String: [String: [String: String]]]()
                    for j in 1...6 {
                        schedule[String(i)]![String(j)] = [String: [String: String]]()
                        for k in 0...1 {
                            schedule[String(i)]![String(j)]![String(k)] = [String: String]()
                            schedule[String(i)]![String(j)]![String(k)]!["subject"] = ""
                            schedule[String(i)]![String(j)]![String(k)]!["classroom"] = ""
                            schedule[String(i)]![String(j)]![String(k)]![secondKeyword] = ""
                            schedule[String(i)]![String(j)]![String(k)]!["type"] = ""
                        }
                    }
                }
                var completed = 0
                for period in jsonResult {
                    if let period = period as? NSDictionary {
                        if period["subject"] as? String != nil && period["type"] as? String != nil && Int(period["type"] as! String) != nil {
                            let type = Int(period["type"] as! String)!
                            let day = String((type >> 3) % 8)
                            let para = String(type % 8)
                            let cycle = String((type >> 6) % 2)
                            let subtype = String(type >> 7)
                            let subject = period["subject"] as! String
                            let flat = period["flat"] as? String ?? ""
                            let keyword = period[thirdKeyword] as? String ?? ""
                            if (type >> 3) % 8 > 5 || (type >> 3) % 8 < 1 || type % 8 > 6 || type % 8 < 1 || (type >> 6) % 2 > 1 || (type >> 6) % 2 < 0 || type >> 7 > 1 || type >> 7 < 0 {
                                DispatchQueue.main.sync(execute: {
                                    completionHandler(nil)
                                })
                                return
                            }
                            schedule[day]![para]![cycle]!["subject"] = subject
                            if schedule[day]![para]![cycle]!["classroom"] == "" {
                                schedule[day]![para]![cycle]!["classroom"] = flat
                            } else if schedule[day]![para]![cycle]!["classroom"]!.range(of: flat) == nil {
                                schedule[day]![para]![cycle]!["classroom"]! += ", \(flat)"
                            }
                            if schedule[day]![para]![cycle]![secondKeyword] == "" {
                                schedule[day]![para]![cycle]![secondKeyword] = keyword
                            } else if schedule[day]![para]![cycle]![secondKeyword]!.range(of: keyword) == nil {
                                schedule[day]![para]![cycle]![secondKeyword]! += ", \(keyword)"
                            }
                            schedule[day]![para]![cycle]!["type"] = subtype
                            completed += 1
                        } else {
                            DispatchQueue.main.sync(execute: {
                                completionHandler(nil)
                            })
                            return
                        }
                    } else {
                        DispatchQueue.main.sync(execute: {
                            completionHandler(nil)
                        })
                        return
                    }
                }
                if completed == 0 {
                    DispatchQueue.main.sync(execute: {
                        completionHandler(nil)
                    })
                    return
                }
                for i in 1...5 {
                    for j in (1...6).reversed() {
                        if schedule[String(i)]![String(j)]!["0"]! == schedule[String(i)]![String(j)]!["1"]! {
                            schedule[String(i)]![String(j)]!["1"] = nil
                            if j == 6 {
                                if schedule[String(i)]![String(j)]!["0"]!["subject"] == "" && schedule[String(i)]![String(j)]!["0"]!["classroom"] == "" && schedule[String(i)]![String(j)]!["0"]![secondKeyword] == "" && schedule[String(i)]![String(j)]!["0"]!["type"] == "" {
                                    schedule[String(i)]![String(j)] = nil
                                }
                            } else if j == 5 && schedule[String(i)]!["6"] == nil {
                                if schedule[String(i)]![String(j)]!["0"]!["subject"] == "" && schedule[String(i)]![String(j)]!["0"]!["classroom"] == "" && schedule[String(i)]![String(j)]!["0"]![secondKeyword] == "" && schedule[String(i)]![String(j)]!["0"]!["type"] == "" {
                                    schedule[String(i)]![String(j)] = nil
                                }
                            }
                        }
                    }
                }
                
                if NSDictionary(dictionary: schedule).write(toFile: documentsDirectory.appendingPathComponent("\(fileName)-\(id).plist"), atomically: true) {
                    DispatchQueue.main.sync {
                        completionHandler(self.init(scheduleDictionary: schedule))
                    }
                    return
                }
                DispatchQueue.main.sync {
                    completionHandler(nil)
                }
            } else {
                DispatchQueue.main.sync(execute: {
                    completionHandler(nil)
                })
            }
        })
        jsonQuery.resume()
        return { [weak jsonQuery] in
            jsonQuery?.suspend()
        }
    }
    
}
