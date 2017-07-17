//
//  WDTFeedBaseViewController.swift
//  Widdit
//
//  Created by JH Lee on 07/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse
import CPImageViewer
import NYTPhotoViewer
import Kingfisher

class WDTFeedBaseViewController: UITableViewController, CPImageControllerProtocol, WDTFeedTableViewCellDelegate {
    
    var animationImageView: UIImageView!
    var animator = CPImageViewerAnimator()
    var m_aryPosts = [PFObject]()
    var m_searchedPosts = [PFObject]()
    var m_searchedCategories = [String]()
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    var shouldShowCategories: Bool {
        return false
    }
    
    var shouldShowSearch: Bool = true
    var shouldShowSearchInNavigationBar: Bool = true
    var shouldSearchCategories: Bool = false
    
    var cachedTitleView: UIView?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        disablesAutomaticKeyboardDismissal = false

        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48.0
        
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.searchBar.resignFirstResponder()
        view.endEditing(true)
        
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        if shouldShowSearchInNavigationBar {
            searchController.searchBar.tintColor = UIColor.white
            searchController.searchBar.searchBarStyle = .minimal
            searchController.searchBar.setTextColor(color: UIColor.white)
            searchController.searchBar.setTextFieldClearButtonColor(color: UIColor.white)
            searchController.searchBar.setSearchImageColor(color: UIColor.white)
            searchController.searchBar.setPlaceholderTextColor(color: UIColor.white)
            searchController.searchBar.setTextFieldColor(color: UIColor(r: 255, g: 255, b: 255, a: 0.2))
        } else {
            searchController.searchBar.tintColor = UIColor.WDTPrimaryColor()
            searchController.searchBar.setTextColor(color: UIColor.WDTPrimaryColor())
            searchController.searchBar.barTintColor = .white
            searchController.searchBar.backgroundImage = UIImage.shadowImage(with: UIColor.white)
            searchController.searchBar.setTextFieldColor(color: UIColor.lightGray.withAlphaComponent(0.35))
        }
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.subviews.flatMap { $0 as? UITextField }.first?.clearButtonMode = .whileEditing
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
        if shouldShowSearch {
            if shouldShowSearchInNavigationBar {
                addSearchBarItem()
            } else {
                tableView.tableHeaderView = searchController.searchBar
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    fileprivate func addSearchBarItem() {
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace,
                                     target: nil,
                                     action: nil)
        spacer.width = -10
        
        let search = UIBarButtonItem(image: UIImage(named: "common_icon_search"),
                                     style: UIBarButtonItemStyle.plain,
                                     target: self,
                                     action: #selector(WDTFeedBaseViewController.onTapToSearch))
        navigationItem.rightBarButtonItems?.append(contentsOf: [search])
    }
    
    func onTapToSearch() {
        navigationItem.rightBarButtonItems?.removeLast()
        
        cachedTitleView = navigationItem.titleView
        navigationItem.titleView = searchController.searchBar
        
        navigationItem.titleView?.isUserInteractionEnabled = true
        
        searchController.searchBar.setSearchImageColor(color: UIColor.white)
        searchController.searchBar.setPlaceholderTextColor(color: UIColor.white)
    }
    
    @IBAction func onClickBtnAddPost(_ sender: Any) {
        let addPostNC = storyboard?.instantiateViewController(withIdentifier: "WDTAddPostNavigationController") as! UINavigationController
        present(addPostNC, animated: true, completion: nil)
    }

    
    // MARK: - UITableViewDataSource
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if shouldShowCategories {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowCategories && section == 0 {
            return 1
        } else {
            if searchController.isActive && (searchController.searchBar.text ?? "").characters.count > 2 {
                if shouldSearchCategories {
                    return m_searchedCategories.count
                }
                return m_searchedPosts.count
            }
            return m_aryPosts.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowCategories && indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath)
        } else {
            if shouldSearchCategories {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
                
                cell.textLabel?.text = m_searchedCategories[indexPath.row]
                
                return cell
            } else {
                let cell = Bundle.main.loadNibNamed(String(describing: WDTFeedTableViewCell.self), owner: nil, options: nil)?.first as! WDTFeedTableViewCell
                if searchController.isActive && (searchController.searchBar.text ?? "").characters.count > 2 {
                    cell.setViewWithPFObject(m_searchedPosts[indexPath.row])
                } else {
                    cell.setViewWithPFObject(m_aryPosts[indexPath.row])
                }
                cell.setMorePosts(self.setMorePosts(indexPath.row))
                
                cell.m_btnMorePost?.tintColor = morePostsButtonColor(at: indexPath.row)
                cell.m_btnMorePost?.setTitleColor(morePostsButtonColor(at: indexPath.row), for: .normal)
                cell.m_btnMorePost?.BorderColor = morePostsButtonColor(at: indexPath.row)
                
                cell.m_lblPostText.enabledTypes = [.hashtag, .url]
                cell.m_lblPostText.hashtagColor = UIColor.WDTTealColor()
                cell.m_lblPostText.handleHashtagTap { (hashtag) in
                    let morePostsVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
                    morePostsVC.m_strCategory = hashtag
                    morePostsVC.shouldShowSearchInNavigationBar = false
                    self.navigationController?.pushViewController(morePostsVC, animated: true)
                }
                cell.didTapToLink = { [weak self] url in
                    let webNC = self?.storyboard?.instantiateViewController(withIdentifier: "WDTWebNavigationController") as! UINavigationController
                    let webVC = webNC.viewControllers[0] as! WDTWebViewController
                    webVC.m_strUrl = url
                    self?.present(webNC, animated: true, completion: nil)
                }
                
                cell.delegate = self
                
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldSearchCategories {
            if (shouldShowCategories && indexPath.section == 1) || (shouldSearchCategories && indexPath.section == 0) {
                let objCategory = m_searchedCategories[indexPath.row]
                
                let morePostsVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
                morePostsVC.m_strCategory = objCategory
                morePostsVC.shouldShowSearchInNavigationBar = false
                navigationController?.pushViewController(morePostsVC, animated: true)
            }
        }
    }
    
    func setMorePosts(_ index: Int) -> Int {
        return 1
    }
    
    func morePostsButtonColor(at index: Int) -> UIColor {
        return UIColor.WDTPrimaryColor()
    }
    
    // MARK: - WDTFeedTableViewCellDelegate
    func onClickButtonReport(_ objPost: PFObject) {
        let alert = UIAlertController(title: "", message: Constants.String.APP_NAME, preferredStyle: .actionSheet)
        
        if (objPost["user"] as? PFUser)?.objectId == PFUser.current()?.objectId {
            let actionEdit = UIAlertAction(title: "Edit", style: .default) { (_) in
                let addPostNC = self.storyboard?.instantiateViewController(withIdentifier: "WDTAddPostNavigationController") as! UINavigationController
                let addPostVC = addPostNC.viewControllers[0] as! WDTAddPostViewController
                addPostVC.m_objPost = objPost
                self.present(addPostNC, animated: true, completion: nil)
            }
            alert.addAction(actionEdit)
            
            let actionDelete = UIAlertAction(title: "Delete", style: .default) { (_) in
                let confirmAlert = UIAlertController(title: Constants.String.APP_NAME, message: "Are you sure to remove this post?", preferredStyle: .alert)
                
                let actionYes = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                    WDTPost.deletePost(post: objPost, completion: { (success) in
                        if success {
                            if let index = self.m_aryPosts.index(where: { (post) -> Bool in
                                return post.objectId == objPost.objectId
                            }) {
                                self.m_aryPosts.remove(at: index)
                                self.tableView.deleteRows(at: [IndexPath.init(row: index,
                                                                              section: self.shouldShowCategories ? 1 : 0)],
                                                          with: .automatic)
                            }
                        }
                    })
                })
                confirmAlert.addAction(actionYes)
                
                let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
                confirmAlert.addAction(actionNo)
                
                self.present(confirmAlert, animated: true, completion: nil)
            }
            alert.addAction(actionDelete)
        } else {
            let actionReport = UIAlertAction(title: "Report", style: .default) { (_) in
                self.showInfoAlert("Post reported. We’ll take a look at it. Thanks!")
            }
            alert.addAction(actionReport)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func onClickBtnMorePosts(_ objUser: PFUser?) {
        let morePostsVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
        morePostsVC.m_objUser = objUser
        morePostsVC.shouldShowSearchInNavigationBar = false
        navigationController?.pushViewController(morePostsVC, animated: true)
    }
    
    func onTapPostPhoto(_ objPost: PFObject) {
        let photoURLs = objPost["photoURLs"] as? [String] ?? []
        let photos = photoURLs.map { _ in NYTPhotoObject() }
        let controller = PhotosViewController(photos: photos)
        controller.rightBarButtonItem = nil
        
        self.present(controller, animated: true, completion: nil)
        
        loadPhotos(for: photoURLs,
                   loaded:
        { image, index in
            photos[index].image = image
            controller.updateImage(for: photos[index])
        })
    }
    
    func onTapUserAvatar(_ objUser: PFUser?) {
        let profileVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTProfileViewController.self)) as! WDTProfileViewController
        profileVC.m_objUser = objUser
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func onUpdateObject(_ objPost: PFObject) {
        let index = self.m_aryPosts.index(where: { (post) -> Bool in
            return post.objectId == objPost.objectId
        })
        
        tableView.reloadRows(at: [IndexPath(row: index!,
                                            section: shouldShowCategories ? 1 : 0)],
                             with: .automatic)
    }

    func onClickBtnReply(_ objPost: PFObject) {
        let replyVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTReplyViewController.self)) as! WDTReplyViewController
        replyVC.m_objPost = objPost
        replyVC.m_objUser = objPost["user"] as? PFUser
        navigationController?.pushViewController(replyVC, animated: true)
    }
    
    func onClickToDeletePost(_ objPost: PFObject) {
        let confirmAlert = UIAlertController(title: Constants.String.APP_NAME, message: "Are you sure to remove this post?", preferredStyle: .alert)
        
        let actionYes = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            WDTPost.deletePost(post: objPost, completion: { (success) in
                if success {
                    if let index = self.m_aryPosts.index(where: { (post) -> Bool in
                        return post.objectId == objPost.objectId
                    }) {
                        self.m_aryPosts.remove(at: index)
                        self.tableView.deleteRows(at: [IndexPath.init(row: index,
                                                                      section: self.shouldShowCategories ? 1 : 0)],
                                                  with: .automatic)
                    }
                }
            })
        })
        confirmAlert.addAction(actionYes)
        
        let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
        confirmAlert.addAction(actionNo)
        
        self.present(confirmAlert, animated: true, completion: nil)
    }
    
    func onClickEditPost(_ objPost: PFObject) {
        let addPostNC = self.storyboard?.instantiateViewController(withIdentifier: "WDTAddPostNavigationController") as! UINavigationController
        let addPostVC = addPostNC.viewControllers[0] as! WDTAddPostViewController
        addPostVC.m_objPost = objPost
        self.present(addPostNC, animated: true, completion: nil)
    }
    
    
    
    
    
    fileprivate func loadPhotos(for photoURLs: [String],
                                loaded: @escaping (UIImage?, Int) -> Void,
                                completion: (() -> Void)? = nil) {
        if photoURLs.count > 0 {
            var photosLoaded = 0
            for (index, path) in photoURLs.enumerated() {
                guard let url = URL(string: path) else {
                    photosLoaded += 1
                    
                    if photosLoaded >= photoURLs.count {
                        completion?()
                    }
                    return
                }
                
                KingfisherManager.shared.retrieveImage(with: url,
                                                       options: nil,
                                                       progressBlock: nil,
                                                       completionHandler:
                    { (image, _, _, _) in
                        loaded(image, index)
                        
                        photosLoaded += 1
                        if photosLoaded >= photoURLs.count {
                            completion?()
                        }
                })
            }
        } else {
            completion?()
        }
    }
    
}


extension WDTFeedBaseViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchString = searchController.searchBar.text {
            shouldSearchCategories = searchString.hasPrefix("#") && searchString.characters.count > 2
            
            if shouldSearchCategories {
                m_searchedCategories = m_aryPosts
                    .flatMap { post in
                        return post["hashtags"] as? [String]
                    }
                    .flatMap { $0 }
                    .unique
                    .filter { $0.contains(searchString.replacingOccurrences(of: "#", with: "")) }
            } else {
                let l = PFUser.current()?["geoPoint"] as? PFGeoPoint
                m_searchedPosts = m_aryPosts.filter { post in
                    var result = false
                    
                    if let text = post["postText"] as? String {
                        result = result || text.lowercased().contains(searchString.lowercased())
                    }
                    if let linkText = post["linkDescription"] as? String {
                        result = result || linkText.lowercased().contains(searchString.lowercased())
                    }
                    if let linkTitle = post["linkTitle"] as? String {
                        result = result || linkTitle.lowercased().contains(searchString.lowercased())
                    }
                    
                    if let location = post["geoPoint"] as? PFGeoPoint {
                        if let distance = l?.distanceInMiles(to: location) {
                            result = result && distance <= 25
                        }
                    }
                    
                    return result
                }.sorted(by: { (post1, post2) -> Bool in
                    if let l1 = post1["geoPoint"] as? PFGeoPoint, let l2 = post2["geoPoint"] as? PFGeoPoint {
                        let d1 = l?.distanceInMiles(to: l1) ?? 999
                        let d2 = l?.distanceInMiles(to: l2) ?? 999
                        return d1 < d2
                    }
                    return false
                })
            }
        } else {
            m_searchedPosts = []
        }
        
        tableView.reloadData()
    }
}

extension WDTFeedBaseViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if shouldShowSearch && shouldShowSearchInNavigationBar {
            navigationItem.titleView = cachedTitleView
            addSearchBarItem()
        }
    }

}



final class NYTPhotoObject: NSObject, NYTPhoto {
    
    var image: UIImage?
    var imageData: Data?
    var placeholderImage: UIImage?
    var attributedCaptionTitle: NSAttributedString?
    var attributedCaptionCredit: NSAttributedString?
    var attributedCaptionSummary: NSAttributedString?
    
    init(image: UIImage? = nil, imageData: Data? = nil, attributedCaptionTitle: NSAttributedString? = nil) {
        self.image = image
        self.imageData = imageData
        self.attributedCaptionTitle = attributedCaptionTitle
        
        super.init()
    }
    
}


final class PhotosViewController: NYTPhotosViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
