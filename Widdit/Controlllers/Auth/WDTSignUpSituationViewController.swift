//
//  WDTSignUpSituationViewController.swift
//  Widdit
//
//  Created by JH Lee on 06/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

class WDTSignUpSituationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var m_tblSituation: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        m_tblSituation.rowHeight = UITableViewAutomaticDimension
        m_tblSituation.estimatedRowHeight = 44
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

    @IBAction func onClickBtnSkip(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startApplication(true)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed(String(describing: WDTProfileSituationTableViewCell.self), owner: nil, options: nil)?.first as! WDTProfileSituationTableViewCell
        if indexPath.row == 0 {
            cell.setView(.School)
        } else if indexPath.row == 1 {
            cell.setView(.Job)
        } else {
            cell.setView(.Open)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
}
