//
//  WDTActivitiesViewController.swift
//  Widdit
//
//  Created by JH Lee on 18/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTActivitiesViewController: UITableViewController, WDTActivityTableViewCellDelegate {

    let segmentedControl = UISegmentedControl(items: ["REPLIES", "DOWNS"])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48.0
        
        segmentedControl.addTarget(self, action: #selector(onSegmentValueChanged), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        navigationItem.titleView = segmentedControl
        
        showHud()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeRequest()
    }
    
    func onSegmentValueChanged() {
        makeRequest()
    }
    
    func makeRequest() {
        if segmentedControl.selectedSegmentIndex == 1 {
            WDTActivity.sharedInstance().requestDowns { (success) in
                self.hideHud()
                self.tableView.reloadData()
            }
        } else {
            WDTActivity.sharedInstance().requestChats { (success) in
                self.hideHud()
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - TableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 1 {
            return WDTActivity.sharedInstance().downs.count
        } else {
            return WDTActivity.sharedInstance().chats.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed(String(describing: WDTActivityTableViewCell.self), owner: nil, options: [:])?.first as! WDTActivityTableViewCell
        if segmentedControl.selectedSegmentIndex == 1 {
            let objActivity = WDTActivity.sharedInstance().downs[indexPath.row]
            cell.setViewWithActivity(objActivity, isDown: true)
        } else {
            let objActivity = WDTActivity.sharedInstance().chats[indexPath.row]
            cell.setViewWithActivity(objActivity, isDown: false)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var objPost: PFObject?
        
        if segmentedControl.selectedSegmentIndex == 1 {
            let objActivity = WDTActivity.sharedInstance().downs[indexPath.row]
            objPost = objActivity["post"] as? PFObject
        } else {
            let objActivity = WDTActivity.sharedInstance().chats[indexPath.row]
            objPost = objActivity["post"] as? PFObject
        }
        
        let morePostsVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
        morePostsVC.m_objPost = objPost
        navigationController?.pushViewController(morePostsVC, animated: true)
    }

    // MARK: - WDTActivityTableViewCellDelegate
    func onTapUserAvatar(_ objUser: PFUser?) {
        let profileVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTProfileViewController.self)) as! WDTProfileViewController
        profileVC.m_objUser = objUser
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func onClickBtnReply(_ objPost: PFObject, objUser: PFUser) {
        let replyVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTReplyViewController.self)) as! WDTReplyViewController
        replyVC.m_objPost = objPost
        replyVC.m_objUser = objUser
        navigationController?.pushViewController(replyVC, animated: true)
    }
}
