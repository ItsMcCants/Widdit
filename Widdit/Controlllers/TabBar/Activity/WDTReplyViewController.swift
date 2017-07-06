//
//  WDTReplyViewController.swift
//  Widdit
//
//  Created by JH Lee on 20/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTReplyViewController: UIViewController {

    var m_imgAvatar: UIImageView!
    @IBOutlet weak var m_lblUsername: UILabel!
    @IBOutlet weak var m_lblPostText: UILabel!
//    @IBOutlet weak var m_lblPostDowns: UILabel!
//    @IBOutlet weak var m_lblPostReplies: UILabel!
    @IBOutlet weak var m_viewChatContainer: UIView!
//    @IBOutlet weak var m_viewPostInfo: UIView!
//    @IBOutlet weak var m_viewPostInfoHeightConstraint: NSLayoutConstraint!
    
    var m_objPost: PFObject?
    var m_objUser: PFUser?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
//        m_viewPostInfoHeightConstraint.constant = 0

        // Do any additional setup after loading the view.
        
        if let objUser = m_objUser {
            objUser.fetchIfNeededInBackground(block: { (user, error) in
                if error == nil {
                    if let avatarFile = objUser["ava"] as? PFFile {
                        self.m_imgAvatar.kf.setImage(with: URL(string: avatarFile.url!))
                    }
                    
                    if let strName = objUser["name"] as? String {
                        self.m_lblUsername.text = strName.uppercased()
                    } else {
                        self.m_lblUsername.text = objUser.username?.uppercased()
                    }
                    
                    self.m_lblUsername.sizeToFit()
                    
                    if let author = self.m_objPost?["user"] as? PFUser {
                        author.fetchIfNeededInBackground(block: { (author, _) in
                            if let author = author as? PFUser,
                                let postText = self.m_objPost?["postText"] as? String {
                                self.setupPostInfoView(user: author, text: postText)
//                              self.updateDowns()
//                              self.updateReplies()
                            }
                        })
                    }
                    
                    self.m_lblPostText.isUserInteractionEnabled = true
                    self.m_lblPostText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WDTReplyViewController.presentPost)))
                }
            })
            
            let chatVC = WDTChatViewController()
            chatVC.m_objPost = m_objPost
            chatVC.m_objUser = objUser
            addChildViewController(chatVC)
            m_viewChatContainer.addSubview(chatVC.view)
            chatVC.view.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    
    fileprivate func setupNavigationBar() {
        navigationItem.titleView = m_lblUsername
        
        let avatarView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        avatarView.layer.cornerRadius = 18
        avatarView.clipsToBounds = true
        avatarView.contentMode = .scaleAspectFill
        
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WDTReplyViewController.presentProfile)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarView)
        
        self.m_imgAvatar = avatarView
    }
    
    
    fileprivate func setupPostInfoView(user: PFUser, text: String) {
        if let userName = user["name"] as? String ?? user.username {
            let resultString = NSMutableAttributedString(string: "\(userName)'S POST: ".uppercased(), attributes: [
                NSForegroundColorAttributeName: UIColor(r: 195, g: 199, b: 199, a: 1)
            ])
            let postTextString = NSAttributedString(string: text, attributes: [
                NSForegroundColorAttributeName: UIColor(r: 68, g: 74, b: 89, a: 1)
            ])
            resultString.append(postTextString)
            m_lblPostText.attributedText = resultString
        }
    }
    
//    fileprivate func updateDowns() {
//        if let objPost = m_objPost {
//            let objUser = objPost["user"] as! PFUser
//            
//            var totalDowns = 0
//            
//            var pendingRequests = 2
//            func incrementTotalDowns(by count: Int) {
//                totalDowns += count
//                
//                pendingRequests -= 1
//                
//                if pendingRequests <= 0 {
//                    self.m_lblPostDowns.text = "\(totalDowns)"
//                    
//                    if totalDowns > 0 {
//                        self.m_viewPostInfoHeightConstraint.constant = 18
//                    }
//                }
//            }
//            
//            let activity = WDTActivity()
//            activity.post = objPost
//            activity.requestDowns(completion: { succeeded in
//                let downs = activity.downs.count
//                incrementTotalDowns(by: downs)
//            })
//            activity.requestMyDowns(completion: { succeeded in
//                let downs = activity.myDowns.count
//                incrementTotalDowns(by: downs)
//            })
//        }
//    }
//    
//    fileprivate func updateReplies() {
//        if let objPost = m_objPost {
//            let objUser = objPost["user"] as! PFUser
//            WDTActivity.isDownAndReverseDown(user: objUser, post: objPost) { down in
//                if let down = down {
//                    let relation = down.relation(forKey: "replies")
//                    let query = relation.query()
//                    let replies = query.countObjects(nil)
//                    self.m_lblPostReplies.text = "\(replies)"
//                    
//                    if replies > 0 {
//                        self.m_viewPostInfoHeightConstraint.constant = 18
//                    }
//                }
//            }
//        }
//    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setTabBarHidden(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setTabBarHidden(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func setTabBarHidden(_ hidden: Bool) {
        if let wdt_tabBarController = tabBarController as? WDTTabBarController {
            wdt_tabBarController.animationTabBarHidden(hidden)
        } else {
            tabBarController?.hideTabBarAnimated(hide: hidden)
        }
    }
    
    
    @IBAction func presentProfile() {
        let profileVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTProfileViewController.self)) as! WDTProfileViewController
        profileVC.m_objUser = m_objUser
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func presentPost() {
        let morePostsVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
        morePostsVC.m_objPost = m_objPost
        morePostsVC.shouldShowSearch = false
        navigationController?.pushViewController(morePostsVC, animated: true)
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
