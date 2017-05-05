//
//  WDTPush.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 20.06.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import Foundation
import Parse

class WDTPush {
    
    private class func sendPush(toUsername: String, data: [String: AnyObject]) {
        var data = data
        data["receiver"] = toUsername as AnyObject?
        PFCloud.callFunction(inBackground: "sendPush", withParameters: data, block: { (response, error) in
            let resp2 = response as? String
            print(resp2 ?? "Sent push")
        })
    }
    
    class func sendPushAfterDownTapped(toUsername: String, postId: String) {
        guard let username = PFUser.current()?.username else {
            print("username is not set")
            return
        }
        
        guard let userObjectId = PFUser.current()?.objectId! else {
            return
        }
        
        let data = ["alert": "\(username) is down for your post", "badge": "Increment", "sound": "notification.mp3", "who": userObjectId, "post": postId, "type": "down"]
        WDTPush.sendPush(toUsername: toUsername, data: data as [String : AnyObject])
    }
    
    class func sendPushAfterReply(toUsername: String, msg: String, postId: String, comeFromTheFeed: Bool) {
        guard let username = PFUser.current()?.username else {
            print("username is not set")
            return
        }
        
        guard let userObjectId = PFUser.current()?.objectId! else {
            return
        }
        
        var message: String = ""
        
        if comeFromTheFeed {
            message = "replied to your post"
        } else {
            message = "replied back"
        }
        
        let data = ["alert": "\(username) \(message)", "badge": "Increment", "sound": "notification.mp3", "who": userObjectId, "post": postId, "type": "reply"]
        WDTPush.sendPush(toUsername: toUsername, data: data as [String : AnyObject])
    }
}
