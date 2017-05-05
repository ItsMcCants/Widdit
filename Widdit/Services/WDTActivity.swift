//
//  WDTActivity.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 20.06.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import Foundation
import Parse

class WDTActivity {
    
    enum WDTActivityType: String {
        case Down = "down"
        case Undown = "undown"
    }

    let currentUser = PFUser.current()!
    var chats: [PFObject] = []
    var downs: [PFObject] = []
    var myDowns: [PFObject] = []
    var chatsAndDowns: [PFObject] = []
    
    static var _wdtActivity: WDTActivity? = nil
    
    static func sharedInstance() -> WDTActivity {
        if _wdtActivity == nil {
            _wdtActivity = WDTActivity()
        }
        
        return _wdtActivity!
    }
    
    class func isDown(user: PFUser, post: PFObject, completion: @escaping (_ down: PFObject?) -> Void) {
        let didDown = PFQuery(className: "Activity")
        didDown.whereKey("by", equalTo: PFUser.current()!)
        didDown.whereKey("to", equalTo: user)
        didDown.whereKey("post", equalTo: post)
        
        didDown.findObjectsInBackground(block: { (objects, error) in
            if let object = objects?.first {
                completion(object)
            } else {
                completion(nil)
            }
        })
    }
    
    class func isDownAndReverseDown(user: PFUser, post: PFObject, completion: @escaping (_ down: PFObject?) -> Void) {
        let didDown = PFQuery(className: "Activity")
        didDown.whereKey("by", equalTo: PFUser.current()!)
        didDown.whereKey("to", equalTo: user)
        didDown.whereKey("post", equalTo: post)
        
        let reverseDidDown = PFQuery(className: "Activity")
        reverseDidDown.whereKey("by", equalTo: user)
        reverseDidDown.whereKey("to", equalTo: PFUser.current()!)
        reverseDidDown.whereKey("post", equalTo: post)
        
        let allQueries = PFQuery.orQuery(withSubqueries: [didDown, reverseDidDown])
        
        allQueries.findObjectsInBackground(block: { (objects, error) in
            if let object = objects?.first {
                completion(object)
            } else {
                completion(nil)
            }
        })
    }
    
    class func addActivity(user: PFUser, post: PFObject, type: WDTActivityType, completion:@escaping (_ activityObj: PFObject) -> Void) {
        WDTPush.sendPushAfterDownTapped(toUsername: user.username!, postId: post.objectId!)
        
        WDTActivity.isDown(user: user, post: post) { (down) in
            if let down = down {
                down["type"] = type.rawValue
                down.saveInBackground(block: { (success, error) in
                    completion(down)
                    WDTActivity.sharedInstance().requestMyDowns(completion: { (success) in})
                })
            } else {
                let activityObj = PFObject(className: "Activity")
                activityObj["by"] = PFUser.current()
                activityObj["to"] = user
                activityObj["post"] = post
                activityObj["postText"] = post["postText"]
                activityObj["type"] = type.rawValue
                
                activityObj.saveInBackground(block: { (success, error) in
                    completion(activityObj)
                    WDTActivity.sharedInstance().requestMyDowns(completion: { (success) in})
                })
            }
        }
    }
    
    class func deleteActivity(user: PFUser, post: PFObject) {
        WDTActivity.isDown(user: user, post: post) { (down) in
            if let down = down {
                down["type"] = WDTActivityType.Undown.rawValue
                down.saveInBackground(block: { (success, error) in
                    WDTActivity.sharedInstance().requestMyDowns(completion: { (success) in})
                })
            }
        }
    }
    
    func requestMyDowns(completion: @escaping (_ success: Bool) -> Void) {
        
        let activitiesQuery = PFQuery(className: "Activity")
        activitiesQuery.whereKey("by", equalTo: currentUser)
        activitiesQuery.whereKey("type", equalTo: "down")
        activitiesQuery.includeKey("post")
        activitiesQuery.addDescendingOrder("createdAt")
        
        activitiesQuery.findObjectsInBackground(block: { (myDowns, error) in
            if let myDowns = myDowns {
                self.myDowns = myDowns.filter({
                    if let _ = $0["post"] {
                        return true
                    } else {
                        return false
                    }
                })
                
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func requestDowns(completion: @escaping (_ success: Bool) -> Void) {
        let activitiesQuery = PFQuery(className: "Activity")
        activitiesQuery.whereKey("to", equalTo: currentUser)
        activitiesQuery.whereKey("type", equalTo: "down")
        activitiesQuery.includeKey("post")
        activitiesQuery.includeKey("by")
        activitiesQuery.includeKey("to")
        activitiesQuery.addDescendingOrder("createdAt")
        
        activitiesQuery.findObjectsInBackground(block: { (downs, error) in
            if let downs = downs {
                self.downs = downs.filter({
                    if let _ = $0["post"] {
                        return true
                    } else {
                        return false
                    }
                })

                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func requestChats(completion: @escaping (_ success: Bool) -> Void) {
        
        let activitiesToMeQuery = PFQuery(className: "Activity")
        activitiesToMeQuery.whereKey("by", equalTo: currentUser)
        activitiesToMeQuery.whereKey("comeFromTheFeed", equalTo: false)
        activitiesToMeQuery.whereKeyExists("whoRepliedLast")
        
        let activitiesFromMeQuery = PFQuery(className: "Activity")
        activitiesFromMeQuery.whereKey("to", equalTo: currentUser)
        activitiesFromMeQuery.whereKeyExists("whoRepliedLast")
        
        let activitiesQuery = PFQuery.orQuery(withSubqueries: [activitiesToMeQuery, activitiesFromMeQuery])
        activitiesQuery.includeKey("post")
        activitiesQuery.includeKey("by")
        activitiesQuery.includeKey("to")
        activitiesQuery.includeKey("whoRepliedLast")
        activitiesQuery.addDescendingOrder("createdAt")
        
        activitiesQuery.findObjectsInBackground(block: { (chats, error) in
            if let chats = chats {
                
                self.chats = chats.filter({
                    if let _ = $0["post"] {
                        return true
                    } else {
                        return false
                    }
                })
                
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}
