//
//  Extensions.swift
//  Widdit
//
//  Created by JH Lee on 04/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

extension UserDefaults {
    class func isFirstStart() -> Bool {
        let isFirstStart = UserDefaults.standard.bool(forKey: Constants.UserDefaults.FIRST_START)
        if isFirstStart {
            UserDefaults.standard.set(false, forKey: Constants.UserDefaults.FIRST_START)
        }
        
        return isFirstStart
    }
}

extension UIColor {
    convenience init(r: Float, g: Float, b: Float, a: Float) {
        self.init(colorLiteralRed: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    class func WDTPrimaryColor() -> UIColor {
        return UIColor(r: 62, g: 203, b: 204, a: 1)
    }
    
    class func WDTGreenColor() -> UIColor {
        return UIColor(r: 147, g: 237, b: 199, a: 1)
    }
    
    class func WDTTealColor() -> UIColor {
        return UIColor(r: 90, g: 212, b: 213, a: 1)
    }
}

extension UIFont {
    class func WDTRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "SFUIText-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func WDTLight(size: CGFloat) -> UIFont {
        return UIFont(name: "SFUIText-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func WDTMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "SFUIText-Medium", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
}

extension UIImage {
    func resizeImage(_ newWidth: CGFloat) -> UIImage {
        let scale = newWidth / size.width
        let newHeight = size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension Date {
    func timeLeft() -> String {
        let leftSec = timeIntervalSince(Date())
        var strTimeLeft = ""
        
        if leftSec / 60 < 60 {
            let min = Int(leftSec / 60)
            if min > 1 {
                strTimeLeft = "\(min) minutes left"
            } else {
                strTimeLeft = "1 minute left"
            }
        } else if leftSec / 3600 < 24 {
            let hour = Int(leftSec / 3600)
            if hour > 1 {
                strTimeLeft = "\(hour) hours left"
            } else {
                strTimeLeft = "1 hour left"
            }
        } else {
            let day = Int(leftSec / 3600 / 24)
            if day > 1 {
                strTimeLeft = "\(day) days left"
            } else {
                strTimeLeft = "1 day left"
            }
        }
        
        return strTimeLeft
    }
    
    func addHours(_ hours: Double) -> Date {
        return addingTimeInterval(hours * 3600)
    }
}

import MBProgressHUD
import DGActivityIndicatorView
import PermissionScope
import Parse
import SCLAlertView

extension UIViewController {
    
    func showInfoAlert(_ message: String) {
        SCLAlertView().showInfo("", subTitle: message)
    }
    
    func showErrorAlert(_ message: String) {
        SCLAlertView().showError(Constants.String.APP_NAME, subTitle: message)
    }
    
    func showHud() {
        let viewActivity = DGActivityIndicatorView(type: .ballRotate, tintColor: UIColor.WDTTealColor(), size: 70)
        viewActivity?.startAnimating()
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.customView = viewActivity
        hud?.mode = .customView
        hud?.color = UIColor.clear
    }
    
    func hideHudWithError(_ error: String) {
        MBProgressHUD.hide(for: view, animated: true)
        showErrorAlert(error)
    }
    
    func hideHud() {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func showPermissionScope() {
        let scope = PermissionScope()
        
        scope.addPermission(NotificationsPermission(notificationCategories: nil),
                             message: "Get notified on downs and replies")
        scope.addPermission(LocationWhileInUsePermission(),
                             message: "Doing this lets you see peoples posts")
        
        scope.show({ finished, results in
            print("got results \(results)")
            for result in results {
                if result.type == .notifications && result.status == .authorized {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                if result.type == .locationInUse && result.status == .authorized {
                    PFGeoPoint.geoPointForCurrentLocation(inBackground: { (geoPoint, error) in
                        if error == nil {
                            let user = PFUser.current()
                            user!["geoPoint"] = geoPoint
                            user!.saveInBackground()
                        }
                    })
                }
            }
            
        }, cancelled: { (results) -> Void in
            print("thing was cancelled")
        })
    }
}

struct WDTTextParser {
    static let hashtagPattern = "(?:^|\\s|$)#[\\p{L}0-9_]*"
    static let urlPattern = "(^|[\\s.:;?\\-\\]<\\(])" +
        "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
    "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
    
    static private var cachedRegularExpressions: [String : NSRegularExpression] = [:]
    
    static func getElements(from text: String, with pattern: String) -> [NSTextCheckingResult]{
        guard let elementRegex = regularExpression(for: pattern) else { return [] }
        return elementRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
    }
    
    private static func regularExpression(for pattern: String) -> NSRegularExpression? {
        if let regex = cachedRegularExpressions[pattern] {
            return regex
        } else if let createdRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            cachedRegularExpressions[pattern] = createdRegex
            return createdRegex
        } else {
            return nil
        }
    }
}
