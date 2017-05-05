//
//  WDTProfileViewController.swift
//  Widdit
//
//  Created by JH Lee on 17/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import SJSegmentedScrollView
import Parse

class WDTProfileViewController: SJSegmentedViewController, SJSegmentedViewControllerDelegate {

    var m_objUser = PFUser.current()
    var selectedSegment: SJSegmentTab?
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.        
        let headerVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTProfileHeaderViewController.self)) as! WDTProfileHeaderViewController
        headerVC.m_objUser = m_objUser
        headerVC.m_parentVC = self
        headerViewController = headerVC
        
        let feedVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
        feedVC.m_objUser = m_objUser
        feedVC.title = "Feed"
        
        let aboutVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTAboutViewController.self)) as! WDTAboutViewController
        aboutVC.m_objUser = m_objUser
        aboutVC.title = "About"
        segmentControllers = [feedVC, aboutVC]
        
        headerViewHeight = 300
        segmentTitleColor = UIColor.WDTGreenColor()
        segmentTitleFont = UIFont.WDTMedium(size: 12)
        selectedSegmentViewHeight = 0
        segmentViewHeight = 44
        
        delegate = self
        
        super.viewDidLoad()
        
        setSelectedSegmentAt(1, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        reloadData()
    }
    
    private func reloadData() {
        let headerVC = headerViewController as! WDTProfileHeaderViewController
        headerVC.initAvatarScrollView()
        
        for segmentVC in segmentControllers {
            (segmentVC as! UITableViewController).tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
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
    
    // MARK: - SJSegementedViewControllerDelegate
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {
        if selectedSegment != nil {
            selectedSegment?.titleColor(UIColor.WDTGreenColor())
        }

        selectedSegment = segment
        segment?.titleColor(UIColor.WDTTealColor())
    }
}
