//
//  WDTPost.swift
//  Widdit
//
//  Created by Igor Kuznetsov on 20.06.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import Foundation
import Parse

class WDTPost {
    static var _wdtPost: WDTPost? = nil
    var m_aryAllPosts = [PFObject]()
    
    static func sharedInstance() -> WDTPost {
        if _wdtPost == nil {
            _wdtPost = WDTPost()
        }
        
        return _wdtPost!
    }
    
    class func deletePost(post: PFObject, completion: @escaping (_ success: Bool) -> Void) {
        let query = PFQuery(className: "posts")
        query.getObjectInBackground(withId: post.objectId!) { (object, error) in
            object?.deleteInBackground(block: { (success, error) in
                completion(success)
            })
        }
    }
    
    func requestPosts(geoPoint: PFGeoPoint?, world: Bool?, completion: @escaping (_ posts: [PFObject]) -> Void) {
        let query = PFQuery(className: "posts")
        query.addDescendingOrder("createdAt")
        query.includeKey("user")
        query.whereKeyExists("user")
        query.whereKey("hoursexpired", greaterThan: Date())
        
        if let geoPoint = geoPoint {
            if world == false {
                query.whereKey("geoPoint", nearGeoPoint: geoPoint, withinMiles: Constants.Integer.FEED_REGION)
            }
        }
        
        query.findObjectsInBackground(block: { (posts, error) in
            if let posts = posts {
                self.m_aryAllPosts = posts
                completion(posts);
            } else {
                completion([PFObject]())
            }
        })
    }
    
    func requestCategories(completion: @escaping(_ categories: [PFObject]) -> Void) {
        let query = PFQuery(className: "categories")
        query.order(byDescending: "updatedAt")
        query.findObjectsInBackground(block: { (categories, error) in
            if let _ = error {
                completion([PFObject]())
            } else {
                if let categories = categories {
                    completion(categories.filter({ (tmpCategory) -> Bool in
                        return self.getPosts(user: nil, category: tmpCategory["title"] as? String).count > 0
                    }))
                } else {
                    completion([PFObject]())
                }
            }
        })
    }
    
    func getPosts(user: PFUser?, category: String?) -> [PFObject] {
        return m_aryAllPosts.filter { (post) -> Bool in
            if let user = user {
                return ((post["user"] as? PFUser)?.objectId == user.objectId)
            } else {
                if let aryCategories = post["hashtags"] as? [String] {
                    return aryCategories.contains(category!)
                } else {
                    return false
                }
            }
        }
    }
}
