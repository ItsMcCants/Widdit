//
//  WDTActivityTableViewCell.swift
//  Widdit
//
//  Created by JH Lee on 19/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

protocol WDTActivityTableViewCellDelegate {
    func onTapUserAvatar(_ objUser: PFUser?)
    func onClickBtnReply(_ objPost: PFObject, objUser: PFUser)
}

class WDTActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var m_imgAvatar: UIImageView!
    @IBOutlet weak var m_lblUsername: UILabel!
    @IBOutlet weak var m_lblComment: UILabel!
    @IBOutlet weak var m_lblDescription: UILabel!
    @IBOutlet weak var m_btnReply: UIButton!
    
    var m_objActivity: PFObject?
    var delegate: WDTActivityTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapAvatar))
        m_imgAvatar.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setViewWithActivity(_ objActivity: PFObject, isDown: Bool) {
        m_objActivity = objActivity
        
        let byUser = objActivity["by"] as! PFUser
        let toUser = objActivity["to"] as! PFUser
        
        let objPost = objActivity["post"] as! PFObject
        objPost.fetchIfNeededInBackground { (_, _) in
            self.m_lblDescription.text = objPost["postText"] as? String
        }
        
        if byUser.username == PFUser.current()!.username {
            if let avaFile = toUser["ava"] as? PFFile {
                self.m_imgAvatar.kf.setImage(with: URL(string: avaFile.url!))
            }
        } else {
            if let avaFile = byUser["ava"] as? PFFile {
                self.m_imgAvatar.kf.setImage(with: URL(string: avaFile.url!))
            }
        }
        
        if isDown {
            if byUser.username == PFUser.current()!.username {
                m_lblUsername.text = "You"
                m_lblComment.text = "down for this post"
                m_btnReply.isHidden = true
            } else {
                m_lblUsername.text = byUser.username
                m_lblComment.text = "is down for your post"
            }
        } else {
            if let whoRepliedLast = objActivity["whoRepliedLast"] as? PFUser {
                if let firstMessage = objActivity["comeFromTheFeed"] as? Bool {
                    if firstMessage {
                        m_lblUsername.text = whoRepliedLast.username
                        m_lblComment.text = "replied to your post"
                    } else {
                        if PFUser.current()!.username == byUser.username {
                            m_lblUsername.text = toUser.username
                            if whoRepliedLast.username == byUser.username {
                                m_lblComment.text = ""
                            } else {
                                m_lblComment.text = "replied back"
                            }
                            
                        } else {
                            m_lblUsername.text = byUser.username
                            
                            if whoRepliedLast.username == byUser.username {
                                m_lblComment.text = "replied back"
                            } else {
                                m_lblComment.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onClickBtnReply(_ sender: Any) {
        if let objActivity = m_objActivity {
            let objPost = objActivity["post"] as! PFObject
            objPost.fetchIfNeededInBackground(block: { (objPost, error) in
                if error == nil {
                    let byUser = self.m_objActivity?["by"] as! PFUser
                    let toUser = self.m_objActivity?["to"] as! PFUser
                    
                    var objUser: PFUser?
                    
                    if byUser.objectId == PFUser.current()!.objectId {
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
            let byUser = objActivity["by"] as! PFUser
            let toUser = objActivity["to"] as! PFUser
            
            if byUser.username == PFUser.current()!.username {
                delegate?.onTapUserAvatar(toUser)
            } else {
                delegate?.onTapUserAvatar(byUser)
            }            
        }
    }
    
}
