//
//  Structures.swift
//  profkom-xai
//
//  Created by Admin on 28.05.15.
//  Copyright (c) 2015 KY1VSTAR. All rights reserved.
//

struct ElementNews {
    let id: String
    let title: String
    let style: String
    let date: String
    let content: String
    let description: String?
    let descriptionHeight: CGFloat?
    let logoURL: String
    let view: String
}

struct ElementNotification {
    let message: String
    let messageHeight: CGFloat
    let date: String
}

struct ElementIssue {
    let id: String
    let title: String
    let fileURL: String
    let description: String
    let descriptionHeight: CGFloat
    let logoURL: String
    let view: String
}

struct Global {
    
    static let tintColor = UIColor(red: 1, green: 0.231373, blue: 0.188235, alpha: 1)
    static let barTintColor = UIColor(red: 247 / 255.0, green: 247 / 255.0, blue: 247 / 255.0, alpha: 1)
    static let placeholderImageColor = UIColor(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1)
    private static var networkActivityIndicatorCount = 0
    
    static func setNetworkActivityIndicatorVisible(_ visible: Bool) {
        networkActivityIndicatorCount += visible ? 1 : -1
        if networkActivityIndicatorCount < 0 {
            networkActivityIndicatorCount = 0
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = networkActivityIndicatorCount != 0
    }
    
    static func platformString() -> String? {
		//http://stackoverflow.com/questions/11197509/ios-how-to-get-device-make-and-model
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0);
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0);
        if let platform = String(validatingUTF8: machine) {
            switch platform {
            case "iPhone4,1":
                return "iPhone 4S"
            case "iPhone5,1", "iPhone5,2":
                return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":
                return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":
                return "iPhone 5s"
            case "iPhone7,1":
                return "iPhone 6 Plus"
            case "iPhone7,2":
                return "iPhone 6"
            case "iPhone8,1":
                return "iPhone 6s"
            case "iPhone8,2":
                return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":
                return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":
                return "iPhone 7 Plus"
            case "iPhone8,4":
                return "iPhone SE"
            case "iPod5,1":
                return "iPod Touch 5G"
            case "iPod7,1":
                return "iPod Touch 6G"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
                return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":
                return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":
                return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":
                return "iPad Air"
            case "iPad5,3", "iPad5,4":
                return "iPad Air 2"
            case "iPad2,5", "iPad2,6", "iPad2,7":
                return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":
                return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":
                return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":
                return "iPad Mini 4"
            case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":
                return "iPad Pro"
            default:
                if platform.range(of: "iPhone") != nil {
                    return "iPhone"
                } else if platform.range(of: "iPad") != nil {
                    return "iPad"
                } else if platform.range(of: "iPod") != nil {
                    return "iPod"
                }
            }
        }
        return nil
    }
    
}

extension String {
    
    func MD5() -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = [UInt8](repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        return hexString
    }
    
}

extension UINavigationBar {
    
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.isHidden = true
    }
    
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.isHidden = false
    }
    
    private func hairlineImageViewInNavigationBar(_ view: UIView) -> UIImageView? {
        if let view  = view as? UIImageView, view.bounds.size.height <= 1.0 {
            return view
        }
        
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        
        return nil
    }
    
}

extension UINavigationItem {
    
    func setScrollingTitle(_ title: String) {
        let titleLabel = MarqueeLabel()
        titleLabel.trailingBuffer = 5
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .black
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 0, y: 0, width: titleLabel.frame.width - 1, height: 21.5)
        titleView = titleLabel
    }
    
}

extension UIImage {
    
    class func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}

class Toast {
    
    private static var isFirstCall = true
    
    class func makeToast(message: String) {
        if isFirstCall {
            isFirstCall = false
            CSToastManager.setQueueEnabled(true)
        }
        UIApplication.shared.delegate!.window!!.makeToast(message)
    }
    
}

