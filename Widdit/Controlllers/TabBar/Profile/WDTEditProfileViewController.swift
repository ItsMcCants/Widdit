//
//  WDTEditProfileViewController.swift
//  Widdit
//
//  Created by JH Lee on 18/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class WDTEditProfileViewController: UITableViewController {

    @IBOutlet weak var m_btnLinkFacebook: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48.0
        
        m_btnLinkFacebook.isSelected = PFFacebookUtils.isLinked(with: PFUser.current()!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 || section == 3 {
            return 3
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = Bundle.main.loadNibNamed(String(describing: WDTAvatarTableViewCell.self), owner: nil, options: [:])?.first as! WDTAvatarTableViewCell
            cell.setView(self)
            
            return cell
        } else  if indexPath.section == 1 {
            let cell = Bundle.main.loadNibNamed(String(describing: WDTProfileTextTableViewCell.self), owner: nil, options: [:])?.first as! WDTProfileTextTableViewCell
            
            if indexPath.row == 0 {
                cell.setView(.Username)
            } else if indexPath.row == 1 {
                cell.setView(.Name)
            } else {
                cell.setView(.Email)
            }
            
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WDTProfileAboutTableViewCell", for: indexPath)
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed(String(describing: WDTProfileSituationTableViewCell.self), owner: nil, options: [:])?.first as! WDTProfileSituationTableViewCell
            
            if indexPath.row == 0 {
                cell.setView(.School)
            } else if indexPath.row == 1 {
                cell.setView(.Job)
            } else {
                cell.setView(.Open)
            }
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1
        } else if section == 1 || section == 3 {
            return 40
        } else {
            return 20
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 || section == 3 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
            
            let lblTitle = UILabel()
            lblTitle.text = section == 1 ? "PERSONAL DATA" : "SITUATION"
            lblTitle.font = UIFont.WDTRegular(size: 12)
            lblTitle.textColor = UIColor.WDTTealColor()
            headerView.addSubview(lblTitle)
            lblTitle.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.leading.equalTo(12)
            }
            
            return headerView
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let profileAboutVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTProfileAboutViewController.self)) as! WDTProfileAboutViewController
            navigationController?.pushViewController(profileAboutVC, animated: true)
        }
    }

    @IBAction func onClickBtnDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickBtnLinkFacebook(_ sender: Any) {
        let btnLinkFacebook = sender as! UIButton
        btnLinkFacebook.isSelected = !btnLinkFacebook.isSelected
        
        let objUser = PFUser.current()!
        
        if btnLinkFacebook.isSelected {
            PFFacebookUtils.linkUser(inBackground: objUser, withReadPermissions: nil, block: { (success, error) in
                if error == nil {
                    objUser["facebookVerified"] = true
                    objUser.saveInBackground()
                }
            })
        } else {
            PFFacebookUtils.unlinkUser(inBackground: objUser, block: { (success, error) in
                if error == nil {
                    objUser["facebookVerified"] = false
                    objUser.saveInBackground()
                }
            })
        }
    }
    
}
