//
//  WDTLogInViewController.swift
//  Widdit
//
//  Created by JH Lee on 06/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Parse

class WDTLogInViewController: WDTNoNavigationBaseViewController {

    @IBOutlet weak var m_txtUsername: SkyFloatingLabelTextField!
    @IBOutlet weak var m_txtPassword: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    @IBAction func onClickBtnLogin(_ sender: Any) {
        if validateForm() {
            showHud()
            PFUser.logInWithUsername(inBackground: m_txtUsername.text!.lowercased(), password: m_txtPassword.text!.lowercased()) { (user, error) in
                if let error = error {
                    self.hideHudWithError(error.localizedDescription)
                } else {
                    self.hideHud()
                    if let signUpFinished = user?["signUpFinished"] as? Bool, signUpFinished {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.startApplication(true)
                    } else {
                        if let phoneNumber = user?["phoneNumber"] as? String, phoneNumber.characters.isEmpty == false {
                            let signUpProfileVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTSignUpProfileViewController.self)) as! WDTSignUpProfileViewController
                            signUpProfileVC.m_currentUser = user!
                            self.navigationController?.pushViewController(signUpProfileVC, animated: true)
                        } else {
                            let signUpPhoneVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTSignUpPhoneViewController.self)) as! WDTSignUpPhoneViewController
                            signUpPhoneVC.m_currentUser = user!
                            self.navigationController?.pushViewController(signUpPhoneVC, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func validateForm() -> Bool {
        var isValid = true
        
        if m_txtUsername.text!.isEmpty {
            isValid = false
            m_txtUsername.errorMessage = Constants.String.NO_USERNAME
        } else {
            m_txtUsername.errorMessage = ""
        }
        
        if m_txtPassword.text!.characters.count < 6 {
            isValid = false
            m_txtPassword.errorMessage = Constants.String.SHORT_PASSWORD
        } else {
            m_txtPassword.errorMessage = ""
        }
        
        return isValid
    }
    
}
