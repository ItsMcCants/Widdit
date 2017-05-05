//
//  WDTTutorialViewController.swift
//  Widdit
//
//  Created by JH Lee on 04/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import SnapKit
import PermissionScope

class WDTTutorialViewController: UIViewController {
    
    @IBOutlet weak var m_sclMain: UIScrollView!
        
    @IBOutlet weak var m_btnSkip: UIButton!
    @IBOutlet weak var m_constraintBtnSkipTailing: NSLayoutConstraint!
    
    @IBOutlet weak var m_ctlPage: UIPageControl!
    @IBOutlet weak var m_btnLocation: JHButton!
    @IBOutlet weak var m_btnNotification: JHButton!
    
    var m_3rdContentVC: WDTTutorialContentViewController?
    var aryPages = [WDTTutorialContentViewController]()
    var currentPage = 0
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        
        m_btnLocation.isHidden = true
        m_btnNotification.isHidden = true
        
        let viewContainer = UIView()
        viewContainer.backgroundColor = UIColor.clear
        m_sclMain.addSubview(viewContainer)
        viewContainer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Constants.Arrays.TUTORIAL_TITLES.count)
        }
        
        var preView: UIView?
        
        for nIndex in 0..<Constants.Arrays.TUTORIAL_TITLES.count {
            let contentVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTTutorialContentViewController.self)) as! WDTTutorialContentViewController
            contentVC.body = Constants.Arrays.TUTORIAL_TITLES[nIndex]
            contentVC.photo = UIImage(named: "tutorial_image_\(nIndex + 1)")!
            
            if nIndex == 3 {
                m_3rdContentVC = contentVC
                
                let btnDown = UIButton(type: .custom)
                btnDown.addTarget(self, action: #selector(onClickBtnDown), for: .touchUpInside)
                
                contentVC.view.addSubview(btnDown)
                btnDown.snp.makeConstraints({ (make) in
                    make.left.equalTo(contentVC.m_imgPhoto.snp.centerX)
                    make.right.equalTo(contentVC.m_imgPhoto)
                    make.bottom.equalTo(contentVC.m_imgPhoto).offset(-10)
                    make.width.equalTo(btnDown.snp.height).multipliedBy(4)
                })
            }
            
            viewContainer.addSubview(contentVC.view)
            contentVC.view.snp.makeConstraints({ (make) in
                make.height.equalToSuperview()
                make.centerY.equalToSuperview()
                
                if nIndex == 0 {
                    make.left.equalToSuperview()
                } else {
                    if nIndex == Constants.Arrays.TUTORIAL_TITLES.count - 1 {
                        make.right.equalToSuperview()
                    }
                    
                    make.left.equalTo(preView!.snp.right)
                    make.width.equalTo(preView!)
                }
            })
            
            preView = contentVC.view
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
    
    func onClickBtnDown(_ sender: Any) {
        m_btnSkip.isHidden = false
        m_3rdContentVC?.m_lblBody.text = "How it works: Only the person who made the post knows you're down. No one else 😇"
    }
    
    func setSkipButtonOnLeft() {
        m_constraintBtnSkipTailing.priority = 749
    }
    
    func setUpViewWithPage() {
        switch currentPage {
        case 3:
            m_btnSkip.isHidden = true
            break
            
        case 4:
            m_btnSkip.isHidden = false
            setSkipButtonOnLeft()
            m_btnSkip.setTitle("Skip", for: .normal)
            m_btnNotification.isHidden = false
            m_btnLocation.isHidden = true
            break
            
        case 5:
            m_btnNotification.isHidden = true
            m_btnLocation.isHidden = false
            break
            
        default:
             break
        }
    }
    
    @IBAction func onClickBtnSkip(_ sender: Any) {
        if currentPage == Constants.Arrays.TUTORIAL_TITLES.count - 1 {
            dismiss(animated: false, completion: nil)
        } else {
            currentPage += 1
            m_ctlPage.currentPage = currentPage
            setUpViewWithPage()
            
            let width = m_sclMain.frame.size.width
            m_sclMain.setContentOffset(CGPoint(x: m_sclMain.contentOffset.x + width,
                                               y: 0),
                                       animated: true)
        }
    }
    
    @IBAction func onClickBtnLocation(_ sender: Any) {
        PermissionScope().requestLocationInUse()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onClickBtnNotification(_ sender: Any) {
        PermissionScope().requestNotifications()
        onClickBtnSkip(m_btnSkip)
        m_btnNotification.isHidden = true
        m_btnLocation.isHidden = false
    }
    
}
