//
//  WDTActivityTableViewCell.swift
//  Widdit
//
//  Created by JH Lee on 19/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse
import RelativeFormatter


protocol WDTActivityTableViewCellDelegate {
    func onTapUserAvatar(_ objUser: PFUser?)
    func onClickBtnReply(_ objPost: PFObject, objUser: PFUser)
}

class WDTActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var m_imgAvatar: UIImageView!
    @IBOutlet weak var m_lblUsername: UILabel!
    @IBOutlet weak var m_lblLastMessage: UILabel!
    @IBOutlet weak var m_lblDescription: UILabel!
    @IBOutlet weak var m_activityTypeView: UIImageView!
    @IBOutlet weak var m_newPostIndicator: UIView!
    @IBOutlet weak var m_timeLabel: UILabel!
    @IBOutlet weak var m_arrowImageView: UIImageView!
    
    var m_objActivity: Activity?
    var delegate: WDTActivityTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapAvatar))
        m_imgAvatar.addGestureRecognizer(tap)
        
        m_arrowImageView.tintColor = UIColor(r: 189, g: 189, b: 189, a: 1)
        
        m_newPostIndicator.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setViewWithActivity(_ activity: Activity) {
        m_objActivity = activity
        
        let byUser = activity.by
        let toUser = activity.to
        
        self.m_lblDescription.text = activity.postText
        
        if byUser.username == PFUser.current()!.username {
            m_lblUsername.text = toUser["name"] as? String ?? toUser.username
            if let avaFile = toUser["ava"] as? PFFile {
                self.m_imgAvatar.kf.setImage(with: URL(string: avaFile.url!))
            }
        } else {
            m_lblUsername.text = byUser["name"] as? String ?? byUser.username
            if let avaFile = byUser["ava"] as? PFFile {
                self.m_imgAvatar.kf.setImage(with: URL(string: avaFile.url!))
            }
        }
        
        // Date label
        let date = activity.lastMessageDate
        let relativeDate = date.relativeFormatted(false, precision: .minute)
        m_timeLabel.text = relativeDate
        
        // Not watched activity indicator
        if let lastMessageUser = activity.lastMessageUser {
            lastMessageUser.fetchIfNeededInBackground(block: { [weak self] (_, _) in
                if lastMessageUser.username != PFUser.current()?.username {
                    self?.m_newPostIndicator.isHidden = activity.lastMessageRead
                } else {
                    self?.m_newPostIndicator.isHidden = true
                }
            })
        } else {
            m_newPostIndicator.isHidden = true
        }
        
        // Activity type image
        if activity.isDowned {
            m_activityTypeView.image = UIImage(named: "post_icon_down_selected")
        } else {
            m_activityTypeView.image = UIImage(named: "post_icon_reply_selected")
        }
        
        // Last message
        m_lblLastMessage.text = activity.lastMessageText
    }
    
    @IBAction func onClickBtnReply(_ sender: Any) {
        if let objActivity = m_objActivity {
            let objPost = objActivity.post
            objPost.fetchIfNeededInBackground(block: { (objPost, error) in
                if error == nil {
                    let byUser = self.m_objActivity?.by
                    let toUser = self.m_objActivity?.to
                    
                    var objUser: PFUser?
                    
                    if byUser?.objectId == PFUser.current()!.objectId {
                        objUser = toUser
                    } else {
                        objUser = byUser
                    }
                    
                    self.delegate?.onClickBtnReply(objPost!, objUser: objUser!)
                }
            })
        }
    }
    
    func onTapAvatar() {
        if let objActivity = m_objActivity {
            let byUser = objActivity.by
            let toUser = objActivity.to
            
            if byUser.username == PFUser.current()!.username {
                delegate?.onTapUserAvatar(toUser)
            } else {
                delegate?.onTapUserAvatar(byUser)
            }            
        }
    }
    
}
