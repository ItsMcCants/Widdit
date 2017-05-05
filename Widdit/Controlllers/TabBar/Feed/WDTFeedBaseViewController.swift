//
//  WDTFeedBaseViewController.swift
//  Widdit
//
//  Created by JH Lee on 07/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse
import CPImageViewer

class WDTFeedBaseViewController: UITableViewController, CPImageControllerProtocol, WDTFeedTableViewCellDelegate {
    
    var animationImageView: UIImageView!
    var animator = CPImageViewerAnimator()
    var m_aryPosts = [PFObject]()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48.0
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
    
    @IBAction func onClickBtnAddPost(_ sender: Any) {
        let addPostNC = storyboard?.instantiateViewController(withIdentifier: "WDTAddPostNavigationController") as! UINavigationController
        present(addPostNC, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_aryPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed(String(describing: WDTFeedTableViewCell.self), owner: nil, options: nil)?.first as! WDTFeedTableViewCell
        cell.setViewWithPFObject(m_aryPosts[indexPath.row])
        cell.setMorePosts(self.setMorePosts(indexPath.row))
        
        cell.m_lblPostText.enabledTypes = [.hashtag, .url]
        cell.m_lblPostText.hashtagColor = UIColor.WDTTealColor()
        cell.m_lblPostText.handleHashtagTap { (hashtag) in
            let morePostsVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
            morePostsVC.m_strCategory = hashtag
            self.navigationController?.pushViewController(morePostsVC, animated: true)
        }
        cell.didTapToLink = { [weak self] url in
            let webNC = self?.storyboard?.instantiateViewController(withIdentifier: "WDTWebNavigationController") as! UINavigationController
            let webVC = webNC.viewControllers[0] as! WDTWebViewController
            webVC.m_strUrl = url
            self?.present(webNC, animated: true, completion: nil)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func setMorePosts(_ index: Int) -> Int {
        return 1
    }
    
    // MARK: - WDTFeedTableViewCellDelegate
    func onClickBtnMore(_ objPost: PFObject) {
        let alert = UIAlertController(title: "", message: Constants.String.APP_NAME, preferredStyle: .actionSheet)
        
        if (objPost["user"] as? PFUser)?.objectId == PFUser.current()?.objectId {
            let actionEdit = UIAlertAction(title: "Edit", style: .default) { (_) in
                let addPostVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTAddPostViewController.self)) as! WDTAddPostViewController
                addPostVC.m_objPost = objPost
                self.present(addPostVC, animated: true, completion: nil)
            }
            alert.addAction(actionEdit)
            
            let actionDelete = UIAlertAction(title: "Delete", style: .default) { (_) in
                let confirmAlert = UIAlertController(title: Constants.String.APP_NAME, message: "Are you sure to remove this post?", preferredStyle: .alert)
                
                let actionYes = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                    WDTPost.deletePost(post: objPost, completion: { (success) in
                        if success {
                            let index = self.m_aryPosts.index(where: { (post) -> Bool in
                                return post.objectId == objPost.objectId
                            })
                            self.tableView.deleteRows(at: [IndexPath.init(row: index!, section: 0)], with: .automatic)
                        }
                    })
                })
                confirmAlert.addAction(actionYes)
                
                let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
                confirmAlert.addAction(actionNo)
                
                self.present(confirmAlert, animated: true, completion: nil)
            }
            alert.addAction(actionDelete)
        } else {
            let actionReport = UIAlertAction(title: "Report", style: .default) { (_) in
                self.showInfoAlert("Post reported. We’ll take a look at it. Thanks!")
            }
            alert.addAction(actionReport)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func onClickBtnMorePosts(_ objUser: PFUser?) {
        let morePostsVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
        morePostsVC.m_objUser = objUser
        navigationController?.pushViewController(morePostsVC, animated: true)
    }
    
    func onTapPostPhoto(_ objPost: PFObject) {
        let index = self.m_aryPosts.index(where: { (post) -> Bool in
            return post.objectId == objPost.objectId
        })
        
        let cell = tableView.cellForRow(at: IndexPath(row: index!, section: 0)) as! WDTFeedTableViewCell
        animationImageView = cell.m_imgPhoto
        
        let controller = CPImageViewerViewController()
        controller.transitioningDelegate = animator
        controller.image = animationImageView.image
        present(controller, animated: true, completion: nil)
    }
    
    func onTapUserAvatar(_ objUser: PFUser?) {
        let profileVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTProfileViewController.self)) as! WDTProfileViewController
        profileVC.m_objUser = objUser
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func onUpdateObject(_ objPost: PFObject) {
        let index = self.m_aryPosts.index(where: { (post) -> Bool in
            return post.objectId == objPost.objectId
        })
        
        tableView.reloadRows(at: [IndexPath(row: index!, section: 0)], with: .automatic)
    }

    func onClickBtnReply(_ objPost: PFObject) {
        let replyVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTReplyViewController.self)) as! WDTReplyViewController
        replyVC.m_objPost = objPost
        replyVC.m_objUser = objPost["user"] as? PFUser
        navigationController?.pushViewController(replyVC, animated: true)
    }
    
}
