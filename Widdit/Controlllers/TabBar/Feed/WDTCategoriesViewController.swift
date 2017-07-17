//
//  WDTCategoriesViewController.swift
//  Widdit
//
//  Created by JH Lee on 09/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTCategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var m_tblCategories: UITableView!
    
    fileprivate let refreshControl: UIRefreshControl = UIRefreshControl()
    
    var m_aryCategories = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self,
                                 action: #selector(WDTCategoriesViewController.refresh),
                                 for: .valueChanged)
        m_tblCategories.addSubview(refreshControl)


        requestCategories()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func requestCategories(completion: (() -> Void)? = nil) {
        showHud()
        WDTPost.sharedInstance().requestCategories { [weak self] (categories) in
            completion?()
            self?.hideHud()
            self?.m_aryCategories = categories
            self?.m_tblCategories.reloadData()
        }
    }
    
    
    func refresh() {
        refreshControl.beginRefreshing()
        requestCategories { [weak self] in
            if self?.refreshControl.isRefreshing == true {
                self?.refreshControl.endRefreshing()
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

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_aryCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WDTCategoryTableViewCell.self), for: indexPath) as! WDTCategoryTableViewCell
        cell.setViewWithPFObject(m_aryCategories[indexPath.row])
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objCategory = m_aryCategories[indexPath.row]
        
        let morePostsVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTMorePostsViewController.self)) as! WDTMorePostsViewController
        morePostsVC.m_strCategory = objCategory["title"] as? String
        morePostsVC.shouldShowSearchInNavigationBar = false
        navigationController?.pushViewController(morePostsVC, animated: true)
    }
    
}
