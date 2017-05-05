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
    func onClickBtnMore(_ objPost: PFObject)
    func onTapPostPhoto(_ objPost: PFObject)
    func onClickBtnMorePosts(_ objUser: PFUser?)
    func onTapUserAvatar(_ objUser: PFUser?)
    func onUpdateObject(_ objPost: PFObject)
    func onClickBtnReply(_ objPost: PFObject)
}

class WDTFeedTableViewCell: UITableViewCell {

    @IBOutlet weak var m_imgAvatar: UIImageView!
    @IBOutlet weak var m_lblName: UILabel!
    @IBOutlet weak var m_lblExpireDate: UILabel!
    @IBOutlet weak var m_lblLocation: UILabel!
    @IBOutlet weak var m_imgPhoto: UIImageView!
    @IBOutlet weak var m_constraintPhotoHeight: NSLayoutConstraint!
    @IBOutlet weak var m_imgPhotoTopEdgeConstraint: NSLayoutConstraint!
    @IBOutlet weak var m_lblPostText: ActiveLabel!
    @IBOutlet weak var m_btnMorePost: UIButton!
    @IBOutlet weak var m_constraintBtnMorePostsHeight: NSLayoutConstraint!
    @IBOutlet weak var m_btnReply: UIButton!
    @IBOutlet weak var m_btnDown: UIButton!
    @IBOutlet weak var m_linkPreviewView: LinkPreviewView!
    @IBOutlet weak var m_linkPreviewViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var m_linkPreviewViewVerticalOffsetConstraints: [NSLayoutConstraint]!
    
    
    
    var m_objPost: PFObject?
    var delegate: WDTFeedTableViewCellDelegate?
    
    
    var previewURLString: String?
    var didTapToLink: ((URL) -> Void)?
    
    
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
        
        //ExpireDate
        if let dateExpire = objPost["hoursexpired"] as? Date {
            m_lblExpireDate.text = dateExpire.timeLeft()
        }
        
        //Location
        if let _ = objPost["geoPoint"] as? PFGeoPoint {
            if let country = objPost["country"] as? String {
                m_lblLocation.text = "\(country), \(objPost["city"] as? String ?? "")"
            } else {
                m_lblLocation.text = objPost["city"] as? String ?? ""
            }
        } else {
            m_lblLocation.text = ""
        }
        
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
        
        //Photo
        let photo = objPost["photoUrl"] as? String ?? ""
        if photo.characters.count > 0 {
            m_imgPhoto.kf.setImage(with: URL(string: photo))
            self.m_imgPhotoTopEdgeConstraint.constant = 12
            self.m_constraintPhotoHeight.priority = 801
        }
        
        // Link preview
        if let imageUrl = objPost["linkPhotoUrl"] as? String,
            let title = objPost["linkTitle"] as? String,
            let description = objPost["linkDescription"] as? String,
            let site = objPost["linkSite"] as? String {
            
            m_linkPreviewView.linkImageView.kf.setImage(with: URL(string: imageUrl), placeholder: nil, completionHandler: { [weak self] (image, error, _, _) in                
                self?.m_linkPreviewViewHeightConstraint.priority = 200
                self?.delegate?.onUpdateObject(objPost)
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

        //if user is current user, disable buttons
        m_btnReply.isEnabled = (objPost["user"] as? PFUser)?.objectId != PFUser.current()?.objectId
        m_btnDown.isEnabled = (objPost["user"] as? PFUser)?.objectId != PFUser.current()?.objectId

        //check down
        if m_btnDown.isEnabled {
            m_btnDown.isSelected = WDTActivity.sharedInstance().myDowns.filter({ (down) -> Bool in
                let localPost = down["post"] as! PFObject
                return localPost.objectId == objPost.objectId
            }).count > 0
        }
    }
    
    func setMorePosts(_ postCount: Int) {
        if postCount > 1 {
            m_btnMorePost.setTitle("+\(String(postCount - 1))", for: UIControlState.normal)
        } else {
            m_constraintBtnMorePostsHeight.constant = 0
        }
    }
    
    @IBAction func onClickBtnMore(_ sender: Any) {
        if let objPost = m_objPost {
            delegate?.onClickBtnMore(objPost)
        }
    }
    
    @IBAction func onClickBtnMorePosts(_ sender: Any) {
        if let objPost = m_objPost {
            delegate?.onClickBtnMorePosts(objPost["user"] as? PFUser)
        }
    }
    
    @IBAction func onClickBtnReply(_ sender: Any) {
        if let objPost = m_objPost {
            delegate?.onClickBtnReply(objPost)
        }
    }
    
    @IBAction func onClickBtnDown(_ sender: Any) {
        let btnDown = sender as! UIButton
        btnDown.isSelected = !btnDown.isSelected
        
        if let objPost = m_objPost {
            if btnDown.isSelected {
                WDTActivity.addActivity(user: (objPost["user"] as! PFUser), post: objPost, type: .Down, completion: { _ in })
            } else {
                WDTActivity.deleteActivity(user: (objPost["user"] as! PFUser), post: objPost)
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
    
}
