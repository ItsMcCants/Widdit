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

    @IBOutlet var m_viewTitle: UIView!
    @IBOutlet weak var m_imgAvatar: UIImageView!
    @IBOutlet weak var m_lblUsername: UILabel!
    @IBOutlet weak var m_lblPostText: UILabel!
    @IBOutlet weak var m_viewChatContainer: UIView!
    
    var m_objPost: PFObject?
    var m_objUser: PFUser?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let objUser = m_objUser {
            objUser.fetchIfNeededInBackground(block: { (_, error) in
                if error == nil {
                    if let avatarFile = objUser["ava"] as? PFFile {
                        self.m_imgAvatar.kf.setImage(with: URL(string: avatarFile.url!))
                    }
                    
                    if let strName = objUser["name"] as? String {
                        self.m_lblUsername.text = strName
                    } else {
                        self.m_lblUsername.text = objUser.username
                    }
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
        
        if let objPost = m_objPost {
            m_lblPostText.text = objPost["postText"] as? String
        }
        
        navigationItem.titleView = m_viewTitle
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
