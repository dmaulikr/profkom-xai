//
//  BaseViewController.swift
//  profkom-xai
//
//  Created by KY1VSTAR on 08.10.16.
//  Copyright © 2016 KY1VSTAR. All rights reserved.
//

import UIKit

open class BaseViewController: UIViewController {

    private static var revealController: SWRevealViewController!
    private static let panGestureRecognizer = revealController.panGestureRecognizer()!
    private static let tapGestureRecognizer = revealController.tapGestureRecognizer()!
    var isDetailViewController: Bool {
        return true
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if isIPhone && isDetailViewController {
            if BaseViewController.revealController == nil {
                BaseViewController.revealController = revealViewController()
            }
            if navigationController!.viewControllers.count == 1 {
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu")!.withRenderingMode(.alwaysTemplate), style: .plain, target: BaseViewController.revealController, action: #selector(SWRevealViewController.revealToggle(_:)))
            }
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isIPhone && isDetailViewController {
            if navigationController!.viewControllers.count == 1 {
                navigationController!.view.addGestureRecognizer(BaseViewController.panGestureRecognizer)
                navigationController!.view.addGestureRecognizer(BaseViewController.tapGestureRecognizer)
            } else {
                navigationController!.view.removeGestureRecognizer(BaseViewController.panGestureRecognizer)
                navigationController!.view.removeGestureRecognizer(BaseViewController.tapGestureRecognizer)
            }
        }
    }

}
