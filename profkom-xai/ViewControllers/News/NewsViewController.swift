//
//  ViewControllerNews.swift
//  profkom-xai
//
//  Created by Admin on 14.01.15.
//  Copyright (c) 2015 KY1VSTAR. All rights reserved.
//

import UIKit

class NewsViewController: PagerController, PagerDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        navigationController!.interactivePopGestureRecognizer!.isEnabled = false
        navigationController!.navigationBar.hideBottomHairline()
        let vc1 = storyboard!.instantiateViewController(withIdentifier: "NewsPageViewController") as! NewsPageViewController
        vc1.rootViewController = self
        vc1.page = "1"
        let vc2 = storyboard!.instantiateViewController(withIdentifier: "NewsPageViewController") as! NewsPageViewController
        vc2.rootViewController = self
        vc2.page = "2"
        let vc3 = storyboard!.instantiateViewController(withIdentifier: "NewsPageViewController") as! NewsPageViewController
        vc3.rootViewController = self
        vc3.page = "4"
        let vc4 = storyboard!.instantiateViewController(withIdentifier: "NewsPageViewController") as! NewsPageViewController
        vc4.rootViewController = self
        vc4.page = "5"
        setupPager(tabNames: ["ХАИ", "Другие", "Главные", "Работа"], tabControllers: [vc1, vc2, vc3, vc4])
        customizeTab()
    }
    
    func customizeTab() {
        view.backgroundColor = .white
        indicatorColor = Global.tintColor
        tabsViewBackgroundColor = Global.barTintColor
        contentViewBackgroundColor = .white
        
        centerCurrentTab = true
        tabLocation = .top
        tabHeight = 44
        tabOffset = 0
        if isIPhone{
            tabWidth = view.frame.width / 4
        } else {
            tabWidth = 142
        }
        fixFormerTabsPositions = false
        fixLaterTabsPosition = false
        animation = .during
        tabsTextColor = .black
        selectedTabTextColor = Global.tintColor
        tabsTextFont = .systemFont(ofSize: 17)
    }

}
