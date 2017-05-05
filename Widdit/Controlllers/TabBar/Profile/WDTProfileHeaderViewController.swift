//
//  WDTProfileHeaderViewController.swift
//  Widdit
//
//  Created by JH Lee on 17/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTProfileHeaderViewController: UIViewController, UIScrollViewDelegate {

    var m_objUser: PFUser?
    var m_parentVC: UIViewController?
    
    @IBOutlet weak var m_sclAvatar: UIScrollView!
    @IBOutlet weak var m_btnBack: UIButton!
    @IBOutlet weak var m_btnSettings: UIButton!
    @IBOutlet weak var m_lblName: UILabel!
    @IBOutlet weak var m_pgControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        m_btnSettings.isHidden = m_objUser?.objectId != PFUser.current()?.objectId
        m_btnBack.isHidden = m_objUser?.objectId == PFUser.current()?.objectId
        
        if let userName = m_objUser?["name"] as? String {
            m_lblName.text = userName
        } else {
            m_lblName.text = m_objUser?.username
        }
        
        // setup avatar scrollview
        initAvatarScrollView()
    }
    
    public func initAvatarScrollView() {
        // remove containerView
        for view in m_sclAvatar.subviews {
            view.removeFromSuperview()
        }
        
        var aryAvatars = [String]()
        
        if let ava = m_objUser?["ava"] as? PFFile {
            aryAvatars.append(ava.url!)
        }
        
        if let ava = m_objUser?["ava2"] as? PFFile {
            aryAvatars.append(ava.url!)
        }
        
        if let ava = m_objUser?["ava3"] as? PFFile {
            aryAvatars.append(ava.url!)
        }
        
        m_pgControl.numberOfPages = aryAvatars.count
        
        let viewContainer = UIView()
        viewContainer.backgroundColor = UIColor.clear
        m_sclAvatar.addSubview(viewContainer)
        viewContainer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(aryAvatars.count > 0 ? aryAvatars.count : 1)
        }
        
        var preView: UIView?
        
        for nIndex in 0..<aryAvatars.count {
            let imgAvatar = UIImageView(frame: .zero)
            imgAvatar.clipsToBounds = true
            imgAvatar.contentMode = .scaleAspectFill
            imgAvatar.kf.setImage(with: URL(string: aryAvatars[nIndex]))
            
            viewContainer.addSubview(imgAvatar)
            imgAvatar.snp.makeConstraints({ (make) in
                make.height.equalToSuperview()
                make.centerY.equalToSuperview()
                
                if nIndex == 0 {
                    make.left.equalToSuperview()
                }
                
                if nIndex == aryAvatars.count - 1 {
                    make.right.equalToSuperview()
                }
                
                if preView != nil {
                    make.left.equalTo(preView!.snp.right)
                    make.width.equalTo(preView!)
                }
            })
            
            preView = imgAvatar
        }
        
        if aryAvatars.count == 0 {
            let imgAvatar = UIImageView(frame: .zero)
            imgAvatar.clipsToBounds = true
            imgAvatar.contentMode = .scaleAspectFill
            imgAvatar.image = UIImage(named: "common_avatar_placeholder")
            
            viewContainer.addSubview(imgAvatar)
            imgAvatar.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
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

    @IBAction func onClickBtnBack(_ sender: Any) {
        if let navigationController = m_parentVC?.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @IBAction func onClickBtnSettings(_ sender: Any) {
        let alert = UIAlertController(title: Constants.String.APP_NAME, message: "", preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit Profile", style: .default) { (_) in
            let editProfileNC = self.storyboard?.instantiateViewController(withIdentifier: "WDTEditProfileNavigationController")
            self.m_parentVC?.present(editProfileNC!, animated: true, completion: nil)
        }
        alert.addAction(editAction)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            PFUser.logOut()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let rootNC = appDelegate.window?.rootViewController as! UINavigationController
            rootNC.popToRootViewController(animated: false)
        }
        alert.addAction(logoutAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        m_parentVC?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = view.frame.size.width
        let nPage = (scrollView.contentOffset.x + width / 2) / width
        
        m_pgControl.currentPage = Int(nPage)
    }
    
}
