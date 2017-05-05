//
//  WDTTabBarController.swift
//  Widdit
//
//  Created by JH Lee on 07/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController

class WDTTabBarController: RAMAnimatedTabBarController {

    let aryTabBarNames = ["Feed", "Activity", "Profile"]
    
    override func viewDidLoad() {
        var aryTabBarNCs = [UINavigationController]()
        for strTabBarName in aryTabBarNames {
            let tabBarItem = RAMAnimatedTabBarItem(title: strTabBarName,
                                                   image: UIImage(named: "tabbar_icon_\(strTabBarName.lowercased())"),
                                                   selectedImage: UIImage(named: "tabbar_icon_\(strTabBarName.lowercased())_active"))
            tabBarItem.textColor = UIColor.WDTPrimaryColor()
            tabBarItem.animation = WDTTabItemAnimation()
            let tabBarNC = storyboard?.instantiateViewController(withIdentifier: "\(strTabBarName)NavigationController") as! UINavigationController
            tabBarNC.tabBarItem = tabBarItem
            
            aryTabBarNCs.append(tabBarNC)
        }
        
        viewControllers = aryTabBarNCs
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showPermissionScope()
        tabBar.backgroundColor = UIColor.init(white: 1.0, alpha: 0.9)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
