//
//  WDTFeedTableViewCell.swift
//  Widdit
//
//  Created by JH Lee on 07/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import ActiveLabel
import Parse
import Kingfisher
import SwiftLinkPreview

protocol WDTFeedTableViewCellDelegate {
    func onClickButtonReport(_ objPost: PFObject)
    func onTapPostPhoto(_ objPost: PFObject)
    func onClickBtnMorePosts(_ objUser: PFUser?)
    func onTapUserAvatar(_ objUser: PFUser?)
    func onUpdateObject(_ objPost: PFObject)
    func onClickBtnReply(_ objPost: PFObject)
    func onClickToDeletePost(_ objPost: PFObject)
    func onClickEditPost(_ objPost: PFObject)
}

class WDTFeedTableViewCell: UITableViewCell {

    @IBOutlet weak var m_imgAvatar: UIImageView!
    @IBOutlet weak var m_lblName: UILabel!
    @IBOutlet weak var m_lblExpireDate: UILabel!
    @IBOutlet weak var m_imageLocation: UIImageView!
    @IBOutlet weak var m_imageLocationWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var m_imageLocationLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var m_lblLocation: UILabel!
    @IBOutlet weak var m_imgPhoto: UIImageView!
    @IBOutlet weak var m_imgManyPhotosIndicator: UIImageView!
    @IBOutlet weak var m_constraintPhotoHeight: NSLayoutConstraint!
    @IBOutlet weak var m_imgPhotoTopEdgeConstraint: NSLayoutConstraint!
    @IBOutlet weak var m_lblPostText: ActiveLabel!
    @IBOutlet weak var m_btnMorePost: JHButton!
    @IBOutlet weak var m_buttonReport: UIButton!
    @IBOutlet weak var m_constraintBtnMorePostsHeight: NSLayoutConstraint!
    @IBOutlet weak var m_bottomLeftButton: UIButton!
    @IBOutlet weak var m_bottomRightButton: UIButton!
    @IBOutlet weak var m_linkPreviewView: LinkPreviewView!
    @IBOutlet weak var m_linkPreviewViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var m_linkPreviewViewVerticalOffsetConstraints: [NSLayoutConstraint]!
    
    @IBOutlet weak var m_lblPostDowns: UILabel!
    @IBOutlet weak var m_lblPostReplies: UILabel!
//    @IBOutlet weak var m_viewPostInfo: UIView!
    
    
    var m_objPost: PFObject?
    var delegate: WDTFeedTableViewCellDelegate?
    
    
    var previewURLString: String?
    var didTapToLink: ((URL) -> Void)?
    
    
    var isCurrentUserCell: Bool {
        return (m_objPost?["user"] as? PFUser)?.objectId == PFUser.current()?.objectId
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(onTapUserAvatar))
        m_imgAvatar.addGestureRecognizer(avatarTap)
        
        let photoTap = UITapGestureRecognizer(target: self, action: #selector(onTapPhoto))
        m_imgPhoto.addGestureRecognizer(photoTap)
        
        m_lblPostText.handleURLTap { [weak self] url in
            self?.onTapToLink(url: url)
        }
        
        m_linkPreviewView.onTap = { [weak self] in
            if let urlString = self?.previewURLString, let url = URL(string: urlString) {
                self?.onTapToLink(url: url)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        m_imgAvatar.layer.cornerRadius = m_imgAvatar.frame.width * 0.5
    }
    
    fileprivate func onTapToLink(url: URL?) {
        if let url = url {
            self.didTapToLink?(url)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setViewWithPFObject(_ objPost: PFObject) {
        m_objPost = objPost
        
        //User
        if let user = objPost["user"] as? PFUser {
            user.fetchIfNeededInBackground(block: { (user, error) in
                if let user = user as? PFUser {
                    if let fileAvatar = user["ava"] as? PFFile {
                        self.m_imgAvatar.kf.setImage(with: URL(string: fileAvatar.url!))
                    }
                    
                    if let userName = user["name"] as? String {
                        self.m_lblName.text = userName
                    } else {
                        self.m_lblName.text = user.username
                    }
                }
            })
        }
        
        // Report
        m_buttonReport.isHidden = isCurrentUserCell
        
        //ExpireDate
        if let dateExpire = objPost["hoursexpired"] as? Date {
            m_lblExpireDate.text = dateExpire.timeLeft()
        }
        
        //Location
        if let _ = objPost["geoPoint"] as? PFGeoPoint {
            if let fullLocation = objPost["fullLocation"] as? String {
                m_lblLocation.text = fullLocation
            }
//            if let country = objPost["country"] as? String {
//                m_lblLocation.text = "\(country), \(objPost["city"] as? String ?? "")"
//            } else {
//                m_lblLocation.text = objPost["city"] as? String ?? ""
//            }
        } else {
            m_lblLocation.text = ""
        }
        
        m_imageLocation.isHidden = m_lblLocation.text == nil || m_lblLocation.text?.characters.count == 0
        m_imageLocationWidthConstraint.constant = m_imageLocation.isHidden ? 0 : 18
        m_imageLocationLeftConstraint.constant = m_imageLocation.isHidden ? 0 : 4
        
        //Text
        if let text = objPost["postText"] as? String {
            m_lblPostText.text = text;
        
            //Get Urls for preview link
            let matches = WDTTextParser.getElements(from: text, with: WDTTextParser.urlPattern)
            if matches.count > 0 {
                let match = matches[0]
                let nsstring = text as NSString
                previewURLString = nsstring.substring(with: match.range)
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
        } else {
            m_lblPostText.text = ""
        }
        
        //Photos
        let photoURLs = objPost["photoURLs"] as? [String] ?? []
        let photoIsExists = photoURLs.count > 0
        if photoIsExists {
            m_imgPhoto.kf.setImage(with: URL(string: photoURLs[0]))
            self.m_imgPhotoTopEdgeConstraint.constant = 12
            self.m_constraintPhotoHeight.priority = 801
            
            if photoURLs.count > 1 {
                m_imgManyPhotosIndicator.isHidden = false
            } else {
                m_imgManyPhotosIndicator.isHidden = true
            }
        } else {
            m_imgManyPhotosIndicator.isHidden = true
        }
        
        // Link preview
        if !photoIsExists {
            if let imageUrl = objPost["linkPhotoUrl"] as? String,
                let title = objPost["linkTitle"] as? String,
                let description = objPost["linkDescription"] as? String,
                let site = objPost["linkSite"] as? String {
                
                m_linkPreviewView.linkImageView.kf.setImage(with: URL(string: imageUrl), placeholder: nil, completionHandler: { [weak self] (image, error, _, _) in
                    if image != nil && error == nil {
                        self?.m_linkPreviewViewHeightConstraint.priority = 200
                        self?.delegate?.onUpdateObject(objPost)
                    }
                })
                m_linkPreviewView.linkTitleLabel.text = title
                m_linkPreviewView.linkDescriptionLabel.text = description
                m_linkPreviewView.linkSiteLabel.text = site
                
                m_linkPreviewViewHeightConstraint.priority = 600
                m_linkPreviewViewVerticalOffsetConstraints.forEach { $0.constant = 12 }
            } else if let previewURLString = previewURLString {
                m_linkPreviewViewHeightConstraint.priority = 1000
                
                let sl = SwiftLinkPreview()
                sl.preview(previewURLString, onSuccess: { (result) in
                    if let imageUrl = result[.image] as? String,
                        let title = result[.title] as? String,
                        let description = result[.description] as? String,
                        let site = result[.canonicalUrl] as? String {
                        
                        objPost["linkPhotoUrl"] = imageUrl
                        objPost["linkTitle"] = title
                        objPost["linkDescription"] = description
                        objPost["linkSite"] = site
                        objPost.saveInBackground(block: { (success, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                self.delegate?.onUpdateObject(objPost)
                            }
                        })
                    }
                }, onError: { (error) in
                    print(error.description)
                })
            } else {
                m_linkPreviewViewHeightConstraint.priority = 1000
            }
        } else {
            m_linkPreviewViewHeightConstraint.priority = 1000
        }
        
        // Replies and downs
        
//        m_viewPostInfo.isHidden = !isCurrentUserCell
        

        // Bottom buttons
        
        //if user is current user, show remove and edit buttons
        if isCurrentUserCell {
            m_bottomLeftButton.isSelected = false
            m_bottomRightButton.isSelected = false
            
            m_bottomLeftButton.setTitle("Remove Post", for: .normal)
            m_bottomRightButton.setTitle("Edit Post", for: .normal)
            m_bottomLeftButton.setTitle("Remove Post", for: .selected)
            m_bottomRightButton.setTitle("Edit Post", for: .selected)
            
            m_bottomLeftButton.setImage(nil, for: .normal)
            m_bottomRightButton.setImage(nil, for: .normal)
            m_bottomLeftButton.setImage(nil, for: .selected)
            m_bottomRightButton.setImage(nil, for: .selected)
        } else {
            m_bottomLeftButton.setTitle("Reply", for: .normal)
            m_bottomRightButton.setTitle("I'm Down", for: .normal)
            m_bottomLeftButton.setTitle("Reply", for: .selected)
            m_bottomRightButton.setTitle("I'm Down", for: .selected)
            
            m_bottomLeftButton.setImage(UIImage(named: "post_icon_reply"),
                                        for: .normal)
            m_bottomRightButton.setImage(UIImage(named: "post_icon_down"),
                                         for: .normal)
            m_bottomLeftButton.setImage(UIImage(named: "post_icon_reply_selected"),
                                        for: .selected)
            m_bottomRightButton.setImage(UIImage(named: "post_icon_down_selected"),
                                         for: .selected)
            
            if !isCurrentUserCell {
                m_bottomRightButton.isSelected = WDTActivity.sharedInstance().myDowns.filter({ (down) -> Bool in
                    let localPost = down["post"] as! PFObject
                    return localPost.objectId == objPost.objectId
                }).count > 0
            
//                updateMyReplies()
            }
        }
        
//        updateDowns()
//        updateReplies()
    }
    
    func setMorePosts(_ postCount: Int) {
        if postCount > 1 {
            m_btnMorePost.isHidden = false
            m_btnMorePost.setTitle("+\(String(postCount - 1))", for: UIControlState.normal)
            m_constraintBtnMorePostsHeight.constant = 30
        } else {
            m_btnMorePost.isHidden = true
            m_constraintBtnMorePostsHeight.constant = 0
        }
    }
    
    @IBAction func onClickButtonReport(_ sender: Any) {
        if let objPost = m_objPost {
            delegate?.onClickButtonReport(objPost)
        }
    }
    
    @IBAction func onClickBtnMorePosts(_ sender: Any) {
        if let objPost = m_objPost {
            delegate?.onClickBtnMorePosts(objPost["user"] as? PFUser)
        }
    }
    
    @IBAction func onClickBottomLeftButton(_ sender: Any) {
        if let objPost = m_objPost {
            if isCurrentUserCell {
                delegate?.onClickToDeletePost(objPost)
            } else {
                delegate?.onClickBtnReply(objPost)
            }
        }
    }
    
    @IBAction func onClickBottomRightButton(_ sender: Any) {
        if let objPost = m_objPost {
            if isCurrentUserCell {
                delegate?.onClickEditPost(objPost)
            } else {
                let btnDown = sender as! UIButton
                btnDown.isSelected = !btnDown.isSelected
                
                if btnDown.isSelected {
                    if let user = objPost["user"] as? PFUser {
                        WDTActivity.isDownAndReverseDown(user: user,
                                                         post: objPost) { [weak self] (down) in
                            if let down = down, let activity = Activity(pfObject: down) {
                                self?.sendMessage("I'm down",
                                                  activity: activity,
                                                  to: user)
                            } else {
                                WDTActivity.addActivity(user: user,
                                                        post: objPost,
                                                        type: .Down,
                                                        completion: { [weak self] (activityObj) in
                                    if let activity = Activity(pfObject: activityObj) {
                                        self?.sendMessage("I'm down",
                                                          activity: activity,
                                                          to: user)
                                    }
                                })
                            }
                        }
                    }
                } else {
//                    WDTActivity.deleteActivity(user: (objPost["user"] as! PFUser), post: objPost)
                }
            }
        }
    }
    
    
    fileprivate func sendMessage(_ message: String, activity: Activity, to: PFUser) {
        if let by = PFUser.current(), let activityID = activity.object.objectId {
            let reply = Reply(activityID: activityID,
                              by: by,
                              to: to,
                              body: message,
                              photoURL: nil,
                              isDown: true)
            
            WDTPush.sendPushAfterReply(toUsername: to.username ?? "",
                                       msg: message,
                                       postId: to.objectId!,
                                       comeFromTheFeed: true)
            
            reply.send {
                activity.addReply(reply, completion: { [weak self] _ in
                    self?.updateDowns()
                })
            }
        }
    }
    
    
    func onTapPhoto() {
        if let objPost = m_objPost {
            delegate?.onTapPostPhoto(objPost)
        }
    }
    
    func onTapUserAvatar() {
        if let objPost = m_objPost {
            delegate?.onTapUserAvatar(objPost["user"] as? PFUser)
        }
    }
    
    
    
    
    
    fileprivate func updateDowns() {
        if let objPost = m_objPost {
//            let objUser = objPost["user"] as! PFUser

//            var totalDowns = 0
//
//            var pendingRequests = 2
//            func incrementTotalDowns(by count: Int) {
//                totalDowns += count
//
//                pendingRequests -= 1
//
//                if pendingRequests <= 0 {
////                    self.m_lblPostDowns.text = "\(totalDowns)"
//                }
//            }
//
            let activity = WDTActivity.sharedInstance()
//            activity.post = objPost
//            activity.requestDowns(completion: { succeeded in
//                let downs = activity.downs.count
//                incrementTotalDowns(by: downs)
//            })
            activity.requestMyDowns(completion: { [weak self] succeeded in
                if self?.isCurrentUserCell == false {
                    self?.m_bottomRightButton.isSelected = activity.myDowns.filter({ (down) -> Bool in
                        let localPost = down["post"] as! PFObject
                        return localPost.objectId == objPost.objectId
                    }).count > 0
                }
                
//                incrementTotalDowns(by: downs)
            })
        }
    }
//
//    fileprivate func updateReplies() {
//        if let objPost = m_objPost {
//            let objUser = objPost["user"] as! PFUser
//            WDTActivity.isDownAndReverseDown(user: objUser, post: objPost) { down in
//                if let down = down {
//                    let relation = down.relation(forKey: "replies")
//                    let query = relation.query()
//                    query.countObjectsInBackground(block: { (replies, error) in
//                        self.m_lblPostReplies.text = "\(replies)"
//                    })
//                }
//            }
//        }
//    }
    
//    fileprivate func updateMyReplies() {
//        if let objPost = m_objPost {
//            let objUser = objPost["user"] as! PFUser
//            WDTActivity.isDownAndReverseDown(user: objUser, post: objPost) { down in
//                if let down = down {
//                    let relation = down.relation(forKey: "replies")
//                    let query = relation.query()
//                    query.includeKey("by")
//                    if let me = PFUser.current() {
//                        query.whereKey("by", equalTo: me)
//                    }
//                    query.countObjectsInBackground(block: { [weak self] (replies, error) in
//                        if replies > 0 {
//                            self?.m_bottomLeftButton.isSelected = true
//                        } else {
//                            self?.m_bottomLeftButton.isSelected = false
//                        }
//                    })
//                }
//            }
//        }
//    }
    
}
