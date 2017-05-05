//
//  WDTProfileAboutViewController.swift
//  Widdit
//
//  Created by JH Lee on 18/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTProfileAboutViewController: UIViewController {

    @IBOutlet weak var m_txtAbout: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        m_txtAbout.becomeFirstResponder()
        
        m_txtAbout.text = PFUser.current()?["about"] as? String
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

    @IBAction func onClickBtnSave(_ sender: Any) {
        let objUser = PFUser.current()!
        
        objUser["about"] = m_txtAbout.text
        objUser.saveInBackground()
        
        navigationController!.popViewController(animated: true)
    }
    
}
