//
//  WDTChatViewController.swift
//  Widdit
//
//  Created by JH Lee on 20/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Parse
import DKImagePickerController
import Kingfisher
import NYTPhotoViewer

class WDTChatViewController: JSQMessagesViewController {

    var m_objPost: PFObject?
    var m_objUser: PFUser?
    var m_isFeedChat = false
    
    var outgoingBubbleImageData: JSQMessagesBubbleImage?
    var incomingBubbleImageData: JSQMessagesBubbleImage?
    
    var senderAvatar: UIImage?
    var recipientAvatar: UIImage?
    
    var m_aryMessages = [JSQMessageData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupToolbar()

        // Do any additional setup after loading the view.
        let objUser = PFUser.current()!
        
        senderId = objUser.objectId
        if let strName = objUser["Name"] as? String {
            senderDisplayName = strName
        } else {
            senderDisplayName = objUser.username
        }
        
        if let avatarFile = objUser["ava"] as? PFFile {
            avatarFile.getDataInBackground(block: { [weak self] (data, error) in
                if let data = data {
                    self?.senderAvatar = UIImage(data: data)
                }
            })
        }
        
        if let avatarFile = m_objUser?["ava"] as? PFFile {
            avatarFile.getDataInBackground(block: { [weak self] (data, error) in
                if let data = data {
                    self?.recipientAvatar = UIImage(data: data)
                }
            })
        }
        
        collectionView.collectionViewLayout.messageBubbleFont = UIFont.WDTRegular(size: 16)
        
        outgoingBubbleImageData = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularTailless(),
                                                                capInsets: .zero)?
            .outgoingMessagesBubbleImage(with: UIColor(r: 71, g: 211, b: 214, a: 1))
        incomingBubbleImageData = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularTailless(),
                                                                capInsets: .zero)?
            .incomingMessagesBubbleImage(with: UIColor(r: 249, g: 249, b: 249, a: 1))
        
        showHud()
        getChatHistory()
    }
    
    fileprivate func setupToolbar() {
        self.inputToolbar.maximumHeight = 256
        self.inputToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.inputToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.inputToolbar.clipsToBounds = false
        self.inputToolbar.layer.shadowColor = UIColor(r: 206, g: 209, b: 210, a: 1).cgColor
        self.inputToolbar.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.inputToolbar.layer.shadowRadius = 3
        self.inputToolbar.layer.shadowOpacity = 0.5
        self.inputToolbar.contentView.backgroundColor = .white
        self.inputToolbar.contentView.textView.layer.borderWidth = 0
        self.inputToolbar.contentView.textView.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputToolbar.contentView.textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        inputToolbar.contentView.textView.resignFirstResponder()
    }
    
    func getChatHistory() {
        if let objPost = m_objPost,
           let objUser = m_objUser {
            WDTActivity.isDownAndReverseDown(user: objUser, post: objPost) { (down) in
                if let down = down, let activityID = down.objectId {
                    let relation = down.relation(forKey: "replies")
                    let query = relation.query()// PFQuery(className: "replies")
                    query.addAscendingOrder("createdAt")
                    query.includeKey("by")
                    query.includeKey("to")
                    query.whereKey("activityID", equalTo: activityID)
                    query.findObjectsInBackground(block: { (replies, err) in
                        self.hideHud()
                        
                        if err == nil {
                            
                            if (down["lastMessageUser"] as? PFUser)?.objectId != PFUser.current()?.objectId {
                                down["lastMessageRead"] = true
                                down.saveInBackground()
                            }
                            
                            for objReply in replies! {
                                let sender = objReply["by"] as! PFUser
                                var senderName = ""
                                var text = ""
                                
                                if let strName = sender["name"] as? String {
                                    senderName = strName
                                } else {
                                    senderName = sender.username!
                                }
                                
                                if let body = objReply["body"] as? String,
                                    body.characters.count > 0 {
                                    text = body
                                    
                                    self.m_aryMessages.append(JSQMessage(senderId: sender.objectId, displayName: senderName, text: text))
                                } else if let photoURLString = objReply["photoURL"] as? String,
                                          let photoURL = URL(string: photoURLString) {
                                    let index = self.m_aryMessages.count
                                    let media = JSQPhotoMediaItem(maskAsOutgoing: true)
                                    media?.appliesMediaViewMaskAsOutgoing = (sender.objectId == PFUser.current()?.objectId)
                                    if let message = JSQMessage(senderId: sender.objectId,
                                                                displayName: senderName,
                                                                media: media) {
                                        self.m_aryMessages.append(message)
                                        self.finishSendingMessage()
                                    }
                                    KingfisherManager.shared.retrieveImage(with: photoURL,
                                                                           options: nil,
                                                                           progressBlock: nil,
                                                                           completionHandler:
                                        { [weak self] (image, error, _, _) in
                                            if let image = image {
                                                let media = JSQPhotoMediaItem(image: image)
                                                media?.appliesMediaViewMaskAsOutgoing = (sender.objectId == PFUser.current()?.objectId)
                                                if let message = JSQMessage(senderId: sender.objectId,
                                                                            displayName: senderName,
                                                                            media: media) {
                                                    self?.m_aryMessages.remove(at: index)
                                                    self?.m_aryMessages.insert(message, at: index)
                                                    self?.finishSendingMessage()
                                                }
                                            }
                                    })
                                }
                            }
                            
                            self.finishReceivingMessage()
                        }
                    })
                } else {
                    self.hideHud()
                }
            }
        } else {
            self.hideHud()
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

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        WDTActivity.isDownAndReverseDown(user: m_objUser!, post: m_objPost!) { (down) in
            if let down = down, let activity = Activity(pfObject: down) {
                self.sendMessage(activity, text: text)
            } else {
                WDTActivity.addActivity(user: self.m_objUser!, post: self.m_objPost!, type: .Undown, completion: { (activityObj) in
                    if let activity = Activity(pfObject: activityObj) {
                        self.sendMessage(activity, text: text)
                    }
                })
            }
        }
        
        if let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text) {
            m_aryMessages.append(message)
        }
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        showPhotoPicker()
    }
    
    func sendMessage(_ activity: Activity, text: String) {
        if let by = PFUser.current(), let to = m_objUser, let activityID = activity.object.objectId {
            let reply = Reply(activityID: activityID,
                              by: by,
                              to: to,
                              body: text,
                              photoURL: nil,
                              isDown: false)
            
            WDTPush.sendPushAfterReply(toUsername: to.username ?? "",
                                       msg: text,
                                       postId: to.objectId!,
                                       comeFromTheFeed: true)
            
            reply.send {
                activity.addReply(reply, completion: nil)
            }
        }
    }
    
    func sendMessage(_ activity: Activity, photo: UIImage) {
        if let by = PFUser.current(), let to = m_objUser, let activityID = activity.object.objectId {
            let reply = Reply(activityID: activityID,
                              by: by,
                              to: to,
                              body: nil,
                              photoURL: nil,
                              isDown: false)
            
            WDTPush.sendPushAfterReply(toUsername: to.username ?? "",
                                       msg: "Photo",
                                       postId: to.objectId!,
                                       comeFromTheFeed: true)
            
            if let photoData = UIImageJPEGRepresentation(photo, 0.5) {
                if let photoFile = PFFile(name: "postPhoto.jpg", data: photoData) {
                    photoFile.saveInBackground(block: { (success, error) in
                        if let url = photoFile.url {
                            reply.photoURL = url
                            reply.send {
                                activity.addReply(reply, completion: nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return m_aryMessages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return m_aryMessages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let objMessage = m_aryMessages[indexPath.item]
        if objMessage.senderId() == senderId {
            return outgoingBubbleImageData
        } else {
            return incomingBubbleImageData
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let objMessage = m_aryMessages[indexPath.item]
        if objMessage.senderId() == senderId {
            return JSQMessagesAvatarImageFactory.avatarImage(with: senderAvatar ?? UIImage(named: "common_avatar_placeholder"),
                                                             diameter: 30)
        } else {
            return JSQMessagesAvatarImageFactory.avatarImage(with: recipientAvatar ?? UIImage(named: "common_avatar_placeholder"),
                                                             diameter: 30)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let objMessage = m_aryMessages[indexPath.item]
        if objMessage.senderId() == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor(r: 68, g: 74, b: 89, a: 1)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let objMessage = m_aryMessages[indexPath.item]
        
        if objMessage.isMediaMessage() {
            if let photoItem = objMessage.media?() as? JSQPhotoMediaItem {
                let photo = photoItem.image
                
                let photos = [NYTPhotoObject(image: photo)]
                let controller = PhotosViewController(photos: photos)
                controller.rightBarButtonItem = nil
                
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    
    
    fileprivate func showPhotoPicker() {
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = 1
        pickerController.assetType = .allPhotos
        
        var pickedPhoto: UIImage?
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            var pendingAssets = assets.count
            
            func removePendingAsset() {
                pendingAssets -= 1
                
                if pendingAssets <= 0 {
                    if let pickedPhoto = pickedPhoto {
                        WDTActivity.isDownAndReverseDown(user: self.m_objUser!, post: self.m_objPost!) { (down) in
                            if let down = down, let activity = Activity(pfObject: down) {
                                self.sendMessage(activity, photo: pickedPhoto)
                            } else {
                                WDTActivity.addActivity(user: self.m_objUser!, post: self.m_objPost!, type: .Undown, completion: { (activityObj) in
                                    if let activity = Activity(pfObject: activityObj) {
                                        self.sendMessage(activity, photo: pickedPhoto)
                                    }
                                })
                            }
                        }
                        
                        let media = JSQPhotoMediaItem(image: pickedPhoto)
                        if let message = JSQMessage(senderId: self.senderId,
                                                    displayName: self.senderDisplayName,
                                                    media: media) {
                            self.m_aryMessages.append(message)
                            self.finishSendingMessage()
                        }
                    }
                }
            }
            
            assets.forEach {
                $0.fetchOriginalImageWithCompleteBlock({ (image, _) in
                    pickedPhoto = image
                    
                    removePendingAsset()
                })
            }
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
}


extension JSQMessagesBubbleImageFactory {

    private struct OnceDispatcher {
        static var isDispatched = false
    }
    
    override open static func initialize() {
        super.initialize()
        
        if !OnceDispatcher.isDispatched {
            swizzleInit()
            OnceDispatcher.isDispatched = true
        }
    }
    
    
    private static func swizzleInit() {
        let oldSelector = #selector(JSQMessagesBubbleImageFactory.init(bubble:capInsets:))
        let newSelector = #selector(JSQMessagesBubbleImageFactory.customInit(bubble:capInsets:))
        
        let oldMethod = class_getInstanceMethod(JSQMessagesBubbleImageFactory.self, oldSelector)
        let newMethod = class_getInstanceMethod(JSQMessagesBubbleImageFactory.self, newSelector)
        
        method_exchangeImplementations(oldMethod, newMethod)
    }
    
    
    func customInit(bubble bubbleImage: UIImage, capInsets: UIEdgeInsets) -> JSQMessagesBubbleImageFactory {
        return self.customInit(bubble: UIImage.jsq_bubbleRegularTailless(), capInsets: capInsets)
    }

}
