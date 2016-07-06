//
//  PostCell.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import Parse
import SimpleAlert

class WDTCAShapeLayer: CAShapeLayer {
    var tag: Int?
}

class WDTCellCardView: UIView {
    
    var shadowLayer:WDTCAShapeLayer? = nil
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        
        if self.shadowLayer == nil {
            let maskPath = UIBezierPath(roundedRect: bounds,
                                        byRoundingCorners: [.TopLeft, .TopRight],
                                        cornerRadii: CGSize(width: 4.0, height: 4.0))
            
            self.shadowLayer = WDTCAShapeLayer()
            self.shadowLayer!.tag = 1
            self.shadowLayer!.path = maskPath.CGPath
            self.shadowLayer!.fillColor = UIColor.WDTGrayBlueColor().CGColor
            
            self.shadowLayer!.shadowColor = UIColor.darkGrayColor().CGColor
            self.shadowLayer!.shadowPath = self.shadowLayer!.path
            self.shadowLayer!.shadowOffset = CGSize(width: 0.0, height: 2.0)
            self.shadowLayer!.shadowOpacity = 0.5
            self.shadowLayer!.shadowRadius = 2
            
            layer.insertSublayer(self.shadowLayer!, atIndex: 0)
        }
    }
    
    func updateLayer() {
        layer.sublayers?.forEach {
            if let layer = $0 as? WDTCAShapeLayer {
                if layer.tag == 1 {
                    layer.removeFromSuperlayer()
                    self.shadowLayer = nil
                }
            }
        }
    }
}

import Kingfisher
import AFImageHelper

class PostCell: UITableViewCell {
    
    var avaImage: UIImageView = UIImageView()
    var postPhoto: UIImageView = UIImageView()
    
    var postText: UITextView = UITextView()
    var moreBtn: UIButton = UIButton(type: .Custom)
    var timeLbl: UILabel = UILabel()
    var firstNameLbl: UILabel = UILabel()
    var userNameLbl: UILabel = UILabel()
    var settings: UIButton = UIButton()
    var cardView: WDTCellCardView = WDTCellCardView()
    
    var morePostsButton: UIButton = UIButton(type: .Custom)
    var distanceLbl: UILabel = UILabel()
    
    var vertLineView = UIView()
    var geoPoint: PFGeoPoint?
    
    var user: PFUser!
    var post: PFObject!
    
    var viewController: WDTFeed!
    var tableView: UITableView!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        selectionStyle = .None
    }
    
    // We won’t use this but it’s required for the class to compile
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configureSubviews() {
        backgroundColor = UIColor.whiteColor()
        cardView.backgroundColor = UIColor.clearColor()
        
        self.contentView.addSubview(cardView)

        cardView.addSubview(avaImage)
        cardView.addSubview(postPhoto)
        cardView.addSubview(postText)
        cardView.addSubview(timeLbl)
        cardView.addSubview(firstNameLbl)
        cardView.addSubview(userNameLbl)
        cardView.addSubview(moreBtn)
        cardView.addSubview(settings)

        cardView.addSubview(vertLineView)
        cardView.addSubview(distanceLbl)
        
        
        settings.setImage(UIImage(named: "more"), forState: .Normal)
        settings.addTarget(self, action: #selector(settingsButtonTapped), forControlEvents: .TouchUpInside)
        
        vertLineView.backgroundColor = UIColor.grayColor()
        vertLineView.alpha = 0.5
        
        
        postPhoto.contentMode = .ScaleAspectFit
        
        postText.backgroundColor = UIColor.WDTGrayBlueColor()
        postText.textColor = UIColor.grayColor()
        postText.editable = false
        postText.scrollEnabled = false
        postText.userInteractionEnabled = true;
        postText.dataDetectorTypes = [.Link, .PhoneNumber]
        
        
        // Rounded Square Image
        avaImage.layer.cornerRadius = 8.0
        avaImage.clipsToBounds = true
        
        userNameLbl.font = UIFont.WDTAgoraRegular(12)
        userNameLbl.textColor = UIColor.WDTBlueColor()
        
        moreBtn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        moreBtn.titleLabel?.font = UIFont.WDTAgoraRegular(12)
        moreBtn.setTitleColor(UIColor.WDTBlueColor(), forState: .Normal)
        moreBtn.setTitle("More posts...", forState: .Normal)
        
        
        firstNameLbl.textColor = UIColor.grayColor()
        firstNameLbl.font = UIFont.WDTAgoraRegular(12)
        
        timeLbl.textColor = UIColor.grayColor()
        timeLbl.font = UIFont.WDTAgoraRegular(12)
        
        distanceLbl.textColor = UIColor.grayColor()
        distanceLbl.font = UIFont.WDTAgoraRegular(12)
        
    }
    
    func settingsButtonTapped() {
        //let alert = SimpleAlert.Controller(title: "", message: "", style: .ActionSheet)
        let alert = SimpleAlert.Controller(view: nil, style: .ActionSheet)
        
        if user.username == PFUser.currentUser()?.username {
            alert.addAction(SimpleAlert.Action(title: "Edit", style: .Default) { action in
                
                let newPostVC = NewPostVC()
                
                let nc = UINavigationController(rootViewController: newPostVC)
                self.viewController.presentViewController(nc, animated: true, completion:  {
                    newPostVC.editMode(self.post, postPhoto: self.postPhoto.image)    
                })
            
            })
            
            alert.addAction(SimpleAlert.Action(title: "Delete", style: .Destructive) { action in
                WDTPost.deletePost(self.post, completion: { (success) in
                    self.viewController.loadPosts()
                })
            })
            
        } else {
            alert.addAction(SimpleAlert.Action(title: "Report", style: .Default) { action in
                let reportAlert = SimpleAlert.Controller(title: "Report", message: "[message]", style: .Alert)
                reportAlert.addAction(SimpleAlert.Action(title: "OK", style: .OK))
                self.viewController.presentViewController(reportAlert, animated: true, completion: nil)
            })
        }
        

        
        alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
        
        viewController.presentViewController(alert, animated: true, completion: nil)
        

    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var isHeightCalculated: Bool = false
    
    override func updateConstraints() {
        

        postText.snp_remakeConstraints(closure: { (make) in
            if let _ = self.postPhoto.image {
                make.top.equalTo(postPhoto.snp_bottom).offset(10)
            } else {
                make.top.equalTo(avaImage.snp_bottom).offset(10)
            }
            make.left.equalTo(cardView).offset(10)
            make.right.equalTo(cardView).offset(-10)
            make.bottom.equalTo(cardView).offset(-25)
            
        })



        if isHeightCalculated == false {
            
            postPhoto.snp_remakeConstraints(closure: { (make) in
                make.top.equalTo(avaImage.snp_bottom).offset(15)
                make.left.equalTo(cardView).offset(10)
                make.right.equalTo(cardView).offset(-10)
                make.height.equalTo(postPhoto.snp_width)

//                if let img = postPhoto.image {
//                    let scale = img.size.height / img.size.width
//                    make.height.equalTo(postPhoto.snp_width).multipliedBy(scale)
//                } else {
//                    make.height.equalTo(postPhoto.snp_width).multipliedBy(0.625)
//                }
                
            })


            cardView.snp_remakeConstraints { (make) in
                make.top.equalTo(contentView).offset(10)
                make.left.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-10)
                make.bottom.equalTo(contentView).priority(751)
            }
            
            avaImage.snp_remakeConstraints(closure: { (make) in
                make.top.equalTo(cardView).offset(10)
                make.left.equalTo(cardView).offset(10)
                make.width.equalTo(50)
                make.height.equalTo(50)
            })
            
            userNameLbl.snp_remakeConstraints(closure: { (make) in
                make.left.equalTo(avaImage.snp_right).offset(7)
                make.top.equalTo(cardView).offset(5)
            })
        
            firstNameLbl.snp_remakeConstraints(closure: { (make) in
                make.left.equalTo(avaImage.snp_right).offset(7)
                make.top.equalTo(userNameLbl.snp_bottom).offset(3)
            })
            
            settings.snp_remakeConstraints(closure: { (make) in
                make.right.equalTo(cardView).offset(-10)
                make.top.equalTo(cardView).offset(10)
                make.width.equalTo(25)
                make.height.equalTo(25)
            })

            timeLbl.snp_remakeConstraints(closure: { (make) in
                make.right.equalTo(cardView).offset(-10)
                make.top.equalTo(settings.snp_bottom).offset(10)
            })
        
            distanceLbl.snp_remakeConstraints(closure: { (make) in
                make.right.equalTo(cardView).offset(-10)
                make.top.equalTo(timeLbl.snp_bottom).offset(5)
            })
        

            moreBtn.snp_remakeConstraints { (make) in
                make.top.equalTo(postText.snp_bottom).offset(2)
                make.right.equalTo(cardView).offset(-10)
            }

        
        }
            isHeightCalculated = true
        
        
        
        super.updateConstraints()
    }

    
    
    func fillCell(post: PFObject) {
        let user = post["user"] as! PFUser
        
        let username = user.username
        userNameLbl.text = username
        self.post = post
        self.user = user
        
        postText.text = post["postText"] as! String
        firstNameLbl.text = user["firstName"] as? String
        userNameLbl.hidden = false
        moreBtn.hidden = false
        
        // Place Profile Picture
        if let avaFile = user["ava"] as? PFFile {
            avaImage.kf_setImageWithURL(NSURL(string: avaFile.url!)!)
        }
        
        if let photoFile = post["photoFile"] as? PFFile  {
            
            let placeholderImage = UIImage(color: UIColor.WDTGrayBlueColor(), size: CGSizeMake(CGFloat(320), CGFloat(320)))
            
            postPhoto.kf_setImageWithURL(NSURL(string: photoFile.url!)!, placeholderImage: placeholderImage, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
            })
        } else {
            postPhoto.image = nil
        }
        self.updateConstraints()
        self.cardView.updateLayer()
        
        let hoursexpired = post["hoursexpired"] as! NSDate
        let timeLeft = hoursexpired.timeIntervalSince1970 - NSDate().timeIntervalSince1970
        
        timeLbl.text = NSDateComponentsFormatter.wdtLeftTime(Int(timeLeft)) + " left"
        
        if let postGeoPoint = post["geoPoint"] {
            distanceLbl.text = String(format: "%.1f mi", postGeoPoint.distanceInMilesTo(geoPoint))
        } else {
            distanceLbl.text = ""
        }
    }
    
    
    
    @IBAction func morePostsButtonPressed(sender: UIButton) {

    }
    

}
