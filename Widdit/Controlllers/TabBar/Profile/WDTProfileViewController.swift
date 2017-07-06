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
        feedVC.shouldShowSearch = false
        feedVC.title = "Feed"
        
        let aboutVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTAboutViewController.self)) as! WDTAboutViewController
        aboutVC.m_objUser = m_objUser
        aboutVC.title = "About"
        segmentControllers = [aboutVC, feedVC]
        
        headerViewHeight = 388
        segmentTitleColor = UIColor(r: 68, g: 74, b: 89, a: 1)
        segmentTitleFont = UIFont.WDTMedium(size: 14)
        selectedSegmentViewHeight = 3
        selectedSegmentViewColor = UIColor(r: 71, g: 211, b: 214, a: 1)
        segmentViewHeight = 44
        segmentShadow = SJShadow(offset: .zero, color: .clear, radius: 0, opacity: 0)
        
        delegate = self
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        reloadData()
    }
    
    private func reloadData() {
        for segmentVC in segmentControllers {
            (segmentVC as! UITableViewController).tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
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
            selectedSegment?.titleColor(UIColor(r: 68, g: 74, b: 89, a: 1))
        }

        selectedSegment = segment
        segment?.titleColor(UIColor(r: 71, g: 211, b: 214, a: 1))
    }
    
    
    @IBAction func showMyDownsViewController() {
        let feedVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
        feedVC.shouldRequestMyDowns = true
        feedVC.shouldShowSearch = false
        feedVC.title = "My Downs"
        
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
}
