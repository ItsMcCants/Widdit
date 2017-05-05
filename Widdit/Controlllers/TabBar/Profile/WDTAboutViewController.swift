//
//  WDTAboutViewController.swift
//  Widdit
//
//  Created by JH Lee on 18/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTAboutViewController: UITableViewController {

    var m_objUser: PFUser?
    
    let arySections = ["ABOUT", "SITUATION", "VERIFICATION"]
    
    let aryAccounts = [
        [
            ""
        ],
        [
            ["icon": "profile_icon_school", "text": "I'm in school"],
            ["icon": "profile_icon_job", "text": "I have a job"],
            ["icon": "profile_icon_open", "text": "I'm open to new things"]
        ],
        [
            ["icon": "profile_icon_phone", "text": "Phone"],
            ["icon": "profile_icon_email", "text": "E-mail"],
            ["icon": "profile_icon_facebook", "text": "Facebook"]
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return aryAccounts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryAccounts[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = Bundle.main.loadNibNamed(String(describing: WDTAboutTableViewCell.self), owner: nil, options: [:])?.first as! WDTAboutTableViewCell
            if let about = m_objUser?["about"] as? String {
                cell.m_lblAbout.text = about
                
                cell.m_lblAbout.enabledTypes = [.url]
                cell.m_lblAbout.hashtagColor = UIColor.WDTTealColor()
                cell.m_lblAbout.handleURLTap { (url) in
                    let webNC = self.storyboard?.instantiateViewController(withIdentifier: "WDTWebNavigationController") as! UINavigationController
                    let webVC = webNC.viewControllers[0] as! WDTWebViewController
                    webVC.m_strUrl = url
                    self.present(webNC, animated: true, completion: nil)
                }
            } else {
                cell.m_lblAbout.text = "Tell us about yourself"
                cell.m_lblAbout.alpha = 0.3
            }
            
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed(String(describing: WDTAccountTableViewCell.self), owner: nil, options: [:])?.first as! WDTAccountTableViewCell
            let accountInfo = aryAccounts[indexPath.section][indexPath.row] as? [String: String]
            
            cell.m_imgIcon.image = UIImage(named: (accountInfo?["icon"])!)
            cell.m_lblText.text = accountInfo?["text"]
            
            if indexPath.section == 1 {
                if indexPath.row == 0 { //school
                    if let school = m_objUser?["situationSchool"] as? Bool, school == true {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                } else if indexPath.row == 1 {
                    if let job = m_objUser?["situationWork"] as? Bool, job == true {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                } else {
                    if let open = m_objUser?["situationOpportunity"] as? Bool, open == true {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                }
            } else {
                if indexPath.row == 0 {
                    if let _ = m_objUser?["phoneNumber"] {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                } else if indexPath.row == 1 {
                    if let _ = m_objUser?["email"] {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                } else {
                    if let facebook = m_objUser?["facebookVerified"] as? Bool, facebook == true {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                }
            }
            
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        
        let lblTitle = UILabel()
        lblTitle.text = arySections[section]
        lblTitle.font = UIFont.WDTRegular(size: 12)
        lblTitle.textColor = UIColor.WDTTealColor()
        headerView.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(12)
        }
        
        return headerView
    }

}
