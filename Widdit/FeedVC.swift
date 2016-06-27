//
//  FeedVC.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import ImageViewer



class FeedVC: UITableViewController {
    
    // UI Objects
    @IBOutlet weak var ivarcator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    // Page Size
    var page : Int = 10
    
    var geoPoint: PFGeoPoint?
    let wdtPost = WDTPost()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBottomBorderColor()
        
        
        let queryOfAllUsers = PFUser.query()
        queryOfAllUsers?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Total users: " + String(objects!.count), style: .Done, target: self, action: #selector(self.nothingToDo))
        })
        
        
        let shadowPath = UIBezierPath(rect: self.tabBarController!.tabBar.bounds)
        self.tabBarController!.tabBar.layer.masksToBounds = false
        self.tabBarController!.tabBar.layer.shadowColor = UIColor.blackColor().CGColor
        self.tabBarController!.tabBar.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        self.tabBarController!.tabBar.layer.shadowOpacity = 0.5
        self.tabBarController!.tabBar.layer.shadowPath = shadowPath.CGPath
        self.tabBarController!.tabBar.layer.cornerRadius = 4.0
        
        
        
        configuration = ImageViewerConfiguration(imageSize: CGSize(width: 10, height: 10), closeButtonAssets: buttonAssets)
        
        // Title at the Top
        self.navigationItem.title = "The World"
        
        // Pull to Refresh
        refresher.addTarget(self, action: #selector(loadPosts), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
        // Receive Notification from PostCell if Post is Downed, to update CollectionView
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedVC.refresh), name: "downed", object: nil)

        // Receive Notification from NewPostVC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedVC.uploaded(_:)), name: "uploaded", object: nil)
    
        self.tableView.registerClass(FeedFooter.self, forHeaderFooterViewReuseIdentifier: "FeedFooter")
        self.tableView.registerClass(PostCell.self, forCellReuseIdentifier: "PostCell")
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 150.0;
        self.tableView.separatorStyle = .None

        self.loadPosts()
    }
    
    func nothingToDo() {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func refresh() {
        self.tableView.reloadData()
    }
    
    // reloading func with posts after received notification
    func uploaded(notification: NSNotification) {
        loadPosts()
        
    }
    
    func loadPosts() {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            
            if error == nil {
                self.geoPoint = geoPoint
            }
        }
        
        wdtPost.requestPosts { (success) in
            self.tableView.reloadData()
            self.refresher.endRefreshing()
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
//            loadMore()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.wdtPost.collectionOfPosts.count
    }
    
    // Create table view rows
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = self.tableView!.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        let post = self.wdtPost.collectionOfPosts[indexPath.section]
        
        cell.userNameBtn.tag = indexPath.section
        cell.moreBtn.tag = indexPath.section
        cell.moreBtn.addTarget(self, action: #selector(moreBtnTapped), forControlEvents: .TouchUpInside)
        cell.geoPoint = self.geoPoint
        cell.fillCell(post)
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(FeedVC.avaImageTapped(_:)))
        cell.avaImage.tag = indexPath.section
        cell.avaImage.userInteractionEnabled = true
        cell.avaImage.addGestureRecognizer(tapGestureRecognizer)
//        cell.isHeightCalculated = false
        
        let postsCount = self.wdtPost.collectionOfAllPosts.filter({
            let user1 = post["user"] as! PFUser
            return user1.username == ($0["user"] as! PFUser).username
        }).count
        
        cell.moreBtn.hidden = postsCount == 1
        
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! PostCell
        
        if let img = currentCell.postPhoto.image {
            
            imageProvider.image = img
            let imageViewer = ImageViewer(imageProvider: imageProvider, configuration: configuration, displacedView: currentCell.postPhoto)
            
            self.presentImageViewer(imageViewer)
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let post = self.wdtPost.collectionOfPosts[section]
        let user = post["user"] as! PFUser
        
        if PFUser.currentUser()?.username == user.username {
            return 0
        } else {
            return 55
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footer = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("FeedFooter")
        let footerView = footer as! FeedFooter
        let post = self.wdtPost.collectionOfPosts[section]
        let user = post["user"] as! PFUser
        
        if PFUser.currentUser()?.username == user.username {
            return nil
        } else {
            
            footerView.setDown(user, post: post)
            footerView.imDownBtn.tag = section
            footerView.replyBtn.tag = section
            footerView.replyBtn.addTarget(self, action: #selector(replyBtnTapped), forControlEvents: .TouchUpInside)
            footerView.imDownBtn.addTarget(self, action: #selector(downBtnTapped), forControlEvents: .TouchUpInside)
            
        }
        
        return footerView
    }
    
    func avaImageTapped(sender: AnyObject) {
        let tapGR = sender as! UITapGestureRecognizer
        let destVC = UserVC()
        let post = self.wdtPost.collectionOfPosts[tapGR.view!.tag]
        destVC.user = post.objectForKey("user") as! PFUser
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    func downBtnTapped(sender: AnyObject) {
        let button: UIButton = sender as! UIButton
        let post = self.wdtPost.collectionOfPosts[button.tag]
        let user = post["user"] as! PFUser
        
        if button.selected == true {
            print("UnDown")
            button.selected = false
            WDTActivity.deleteActivity(user, post: post)
        } else {
            print("Downed")
            button.selected = true
            WDTActivity.addActivity(user, post: post, type: .Down, completion: { _ in })
        }
    }
    
    func replyBtnTapped(sender: AnyObject) {
        let destVC = ReplyViewController()
        let post = self.wdtPost.collectionOfPosts[sender.tag]
        let user = post["user"] as! PFUser
        destVC.toUser = user
        destVC.usersPost = post
        
        
        
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    func moreBtnTapped(sender: AnyObject) {
        let post = self.wdtPost.collectionOfPosts[sender.tag]
        let user = post["user"] as! PFUser
            let guest = MorePostsVC()
            guest.user = user
            guest.geoPoint = self.geoPoint
            guest.collectionOfPosts = self.wdtPost.collectionOfAllPosts.filter({
                let u = $0["user"] as! PFUser
                if u.username == user.username {
                    return true
                } else {
                    return false
                }
            })
            self.navigationController?.pushViewController(guest, animated: true)
    }
    
}

