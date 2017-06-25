//
//  WDTFeedViewController.swift
//  Widdit
//
//  Created by JH Lee on 07/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTFeedViewController: WDTFeedBaseViewController {
    
    var m_ctlRefresh = UIRefreshControl()
    
    
    override var shouldShowCategories: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let viewTitle = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imgTitle = UIImageView(image: UIImage(named: "icon_splash"))
        imgTitle.contentMode = .scaleAspectFit
        imgTitle.frame = viewTitle.bounds
        viewTitle.addSubview(imgTitle)
        navigationItem.titleView = viewTitle
        
        m_ctlRefresh.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        tableView.addSubview(m_ctlRefresh)
        
        showHud()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadFeed()
    }
    
    func loadFeed() {
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if let error = error {
                print(error.localizedDescription)
                self.hideHud()
            } else {
                WDTPost.sharedInstance().requestPosts(geoPoint: geoPoint, world: true, completion: { (aryPosts) in
                    self.m_aryPosts = aryPosts.reduce([], { (acc, current) -> [PFObject] in
                        if acc.contains( where: {
                            if ($0["user"] as! PFUser).objectId == (current["user"] as! PFUser).objectId {
                                return true
                            } else {
                                return false
                            }
                        })
                        {
                            return acc
                        } else {
                            return acc + [current]
                        }
                    })
                    
                    FollowersManager.getFollowing(completion: { [weak self] follows in
                        self?.m_aryPosts.sort(by: { (post1, post2) -> Bool in
                            if let post1User = post1["user"] as? PFUser, let post2User = post2["user"] as? PFUser {
                                if let post1UserId = post1User.objectId, let post2UserId = post2User.objectId {
                                    return follows.contains(where: { follow -> Bool in
                                        return follow.user.objectId == post1UserId
                                    }) && !follows.contains(where: { follow -> Bool in
                                        return follow.user.objectId == post2UserId
                                    })
                                }
                            }
                            return false
                        })
                        
                        WDTActivity.sharedInstance().requestMyDowns(completion: { [weak self] succeeded in
                            self?.hideHud()
                            self?.m_ctlRefresh.endRefreshing()
                            
                            self?.tableView.reloadData()
                        })
                    })
                })
            }
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

    @IBAction func onTapCategories(_ sender: Any) {
        let categoriesVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTCategoriesViewController.self)) as! WDTCategoriesViewController
        navigationController?.pushViewController(categoriesVC, animated: true)
    }
    
    override func setMorePosts(_ index: Int) -> Int {
        let post = m_aryPosts[index]
        return WDTPost.sharedInstance().m_aryAllPosts.filter { (tmpPost) -> Bool in
            return (post["user"] as! PFUser).objectId == (tmpPost["user"] as! PFUser).objectId
            }.count
    }
    
}
