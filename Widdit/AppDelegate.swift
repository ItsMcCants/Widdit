//
//  AppDelegate.swift
//  Widdit
//
//  Created by JH Lee on 02/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import ParseFacebookUtilsV4
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //NavigationBar
        UINavigationBar.appearance().barTintColor = UIColor.WDTPrimaryColor()
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.WDTLight(size: 16)]
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), for: .default)
        let imgBack = UIImage(named: "common_button_back")
        UINavigationBar.appearance().backIndicatorImage = imgBack
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = imgBack
        
        //IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        //Parse
        let configuration = ParseClientConfiguration {
            $0.applicationId = Constants.Parse.APPLICATION_ID
            $0.clientKey = Constants.Parse.CLIENT_KEY
            $0.server = Constants.Parse.SERVER
        }
        Parse.initialize(with: configuration)
        
        PFUser.enableRevocableSessionInBackground()
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        //PFFacebookUtils
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        
        //Fabric
        Fabric.with([Crashlytics.self])
        
        //StartApplication
        if let user = PFUser.current() {
            if let signUpFinished = user["signUpFinished"] as? Bool, signUpFinished {
                startApplication(false)
            } else {
                PFUser.logOut()
            }
        }
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.channels = ["global"]
        installation?.saveEventually()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        
        if let installation = PFInstallation.current() {
            if(0 < installation.badge) {
                installation.badge = 0;
                installation.saveEventually()
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    func startApplication(_ animated: Bool) {
        //Save user on installation
        let installation = PFInstallation.current()
        installation?["user"] = PFUser.current()
        installation?.saveEventually()
        
        //Show TabBarController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootNC = window?.rootViewController as! UINavigationController
        let tabbar = storyboard.instantiateViewController(withIdentifier: String(describing: WDTTabBarController.self)) as! WDTTabBarController
        
        rootNC.pushViewController(tabbar, animated: animated)
    }
    
}

