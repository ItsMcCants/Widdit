//
//  WDTMorePostsViewController.swift
//  Widdit
//
//  Created by JH Lee on 09/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTMorePostsViewController: WDTFeedBaseViewController {

    var m_objUser: PFUser?
    var m_strCategory: String?
    var m_objPost: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let objUser = m_objUser {
            if let name = objUser["name"] as? String {
                title = name
            } else {
                title = objUser.username
            }
            
            m_aryPosts = WDTPost.sharedInstance().getPosts(user: objUser, category: nil)
        } else if let strCategory = m_strCategory {
            title = "#\(strCategory)"
            m_aryPosts = WDTPost.sharedInstance().getPosts(user: nil, category: strCategory)
        } else if let objPost = m_objPost {
            title = "Post"
            m_aryPosts = [objPost]
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
    
    @IBAction override func onClickBtnAddPost(_ sender: Any) {
        if let strCategory = m_strCategory {
            let addPostNC = storyboard?.instantiateViewController(withIdentifier: "WDTAddPostNavigationController") as! UINavigationController
            let addPostVC = addPostNC.viewControllers[0] as! WDTAddPostViewController
            addPostVC.m_strPlaceholder = "#\(strCategory)"            
            present(addPostNC, animated: true, completion: nil)
        } else {
            super.onClickBtnAddPost(sender)
        }
    }

}
