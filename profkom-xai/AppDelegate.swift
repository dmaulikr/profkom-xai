//
//  AppDelegate.swift
//  profkom-xai
//
//  Created by Admin on 17.12.14.
//  Copyright (c) 2014 KY1VSTAR. All rights reserved.
//

import UIKit
import UserNotifications

let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let iPadPushViewControllerScale: CGFloat = 1.2
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.setStatusBarHidden(false, with: .fade)
        UIApplication.shared.applicationIconBadgeNumber = 0
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { granted, _ in
                if granted {
                    application.registerForRemoteNotifications()
                }
            })
        } else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        }

        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barTintColor = Global.barTintColor
        UINavigationBar.appearance().tintColor = Global.tintColor
        UIToolbar.appearance().isTranslucent = true
        UIToolbar.appearance().barTintColor = Global.barTintColor
        UIToolbar.appearance().tintColor = Global.tintColor
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let newsNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "NewsNavigationController")
        if isIPhone {
            let revealController = SWRevealViewController(rearViewController: MenuViewController(), frontViewController: newsNavigationController)!
            revealController.rearViewRevealOverdraw = 0
            //revealController.toggleAnimationDuration = 0.1
            revealController.toggleAnimationType = .easeOut
            revealController.rightViewRevealWidth = 0
            revealController.rightViewRevealOverdraw = 0
            revealController.rightViewRevealDisplacement = 0
            window!.rootViewController = revealController
        } else {
            let splitViewController = UISplitViewController()
            splitViewController.viewControllers = [MenuViewController(), newsNavigationController]
            splitViewController.preferredDisplayMode = .allVisible
            window!.rootViewController = splitViewController
        }
        window!.makeKeyAndVisible()
        
        if let userInfo = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            handleRemoteNotification(userInfo)
        }
//        let userInfo: [String: Any] = ["aps": ["alert": "Hello, world!", "sound": "default"], "page":"1", "id": "856"]
//        handleRemoteNotification(userInfo as [String : AnyObject])
        return true
    }
    
    func debugClear() {
        UserDefaults.standard.set(nil, forKey: "group")
        UserDefaults.standard.set(nil, forKey: "teacher")
        UserDefaults.standard.synchronize()
        for file in try! FileManager.default.contentsOfDirectory(atPath: documentsDirectory as String) {
            try? FileManager.default.removeItem(atPath: (documentsDirectory as NSString).appendingPathComponent(file))
        }
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        let hash = ("PRIVATE_KEY_HERE" + token).MD5()
        let platform = Global.platformString()
        Global.setNetworkActivityIndicatorVisible(true)
        let url = URL(string: "http://profkom.xai.edu.ua/api/iOS.php?token=\(token)&hash=\(hash)" + (platform == nil ? "" : "&model=\(platform!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"))!
        let request = URLRequest(url: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: .main) { _, _, _ in
            Global.setNetworkActivityIndicatorVisible(false)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let userInfo = userInfo as? [String: AnyObject] {
            handleRemoteNotification(userInfo)
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options: UNNotificationPresentationOptions) -> ()) {
        if let userInfo = notification.request.content.userInfo as? [String: AnyObject] {
            handleRemoteNotification(userInfo)
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> ()) {
        if let userInfo = response.notification.request.content.userInfo as? [String: AnyObject] {
            handleRemoteNotification(userInfo)
        }
    }
    
    func handleRemoteNotification(_ userInfo: [String: AnyObject]) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let message = userInfo["aps"]?["alert"] as? String {
            let alertController = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
            if let page = userInfo["page"] as? String, let id = userInfo["id"] as? String {
                alertController.addAction(UIAlertAction(title: "Открыть новость", style: .default) { _ in
                    let topViewController = self.topViewController()
                    let nc = mainStoryboard.instantiateViewController(withIdentifier: "PushNavigationController") as! UINavigationController
                    let vc = nc.viewControllers[0] as! PushViewController
                    switch page {
                    case "1", "2", "4":
                        vc.dataPage = "11"
                    default:
                        vc.dataPage = "12"
                    }
                    vc.dataId = id
                    if !isIPhone {
                        nc.modalPresentationStyle = .popover
                        let popover = nc.popoverPresentationController!
                        let screenFrame = UIScreen.main.bounds
                        let contentSize = CGSize(width: screenFrame.width / self.iPadPushViewControllerScale, height: screenFrame.height / self.iPadPushViewControllerScale)
                        nc.preferredContentSize = contentSize
                        popover.sourceView = topViewController.view
                        popover.sourceRect = CGRect(x: screenFrame.midX, y: screenFrame.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                    }
                    topViewController.present(nc, animated: true, completion: nil)
                })
                alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
            } else {
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            presentAlertController(alertController)
        }
    }
    
    func presentAlertController(_ object: AnyObject) {
        let alertController = object is Timer ? ((object as! Timer).userInfo as! UIAlertController) : object as! UIAlertController
        DispatchQueue.main.async {
            let topViewController = self.topViewController()
            if topViewController is UIAlertController {
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.presentAlertController(_:)), userInfo: alertController, repeats: false)
            } else {
                topViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func topViewController(ofViewController: UIViewController? = nil) -> UIViewController {
        let ofViewController = ofViewController ?? UIApplication.shared.delegate!.window!!.rootViewController!
        if let presentedViewController = ofViewController.presentedViewController {
            return topViewController(ofViewController: presentedViewController)
        }
        return ofViewController
    }

}
