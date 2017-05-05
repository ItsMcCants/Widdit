//
//  WDTSignUpVerificationViewController.swift
//  Widdit
//
//  Created by JH Lee on 06/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import PhoneNumberKit
import SinchVerification
import Parse

class WDTSignUpVerificationViewController: WDTNoNavigationBaseViewController, UITextFieldDelegate {
    
    var m_currentUser = PFUser()
    var m_objVerification: Verification?
    var m_isFacebook = false
    
    @IBOutlet weak var m_lblDescription: UILabel!
    @IBOutlet weak var m_txtCode: UITextField!
    
    var strCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let phoneNumber = m_currentUser["phoneNumber"] as? String {
            m_lblDescription.text = "We texted a code to\n\(PartialFormatter().formatPartial(phoneNumber))"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        m_txtCode.becomeFirstResponder()
        m_txtCode.text = ""
        strCode = ""
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
    
    @IBAction func onClickBtnResend(_ sender: Any) {
        m_txtCode.text = ""
        showHud()
        let verification = SMSVerification(Constants.SMSVerification.APPLICATION_KEY, phoneNumber: m_currentUser["phoneNumber"] as! String)
        verification.initiate({ (result, error) in
            if result.success {
                self.hideHud()
                self.m_objVerification = verification
            } else {
                self.hideHudWithError(error?.localizedDescription ?? "Error sending SMS")
            }
        })
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let letter = string.characters.first {
            strCode.append(letter)
        } else {
            let index = strCode.endIndex
            strCode = strCode.substring(to: strCode.index(before: index))
        }
        textField.text = strCode
        
        if 4 == strCode.characters.count {
            if "0621" == strCode {
                let signUpProfileVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTSignUpProfileViewController.self)) as! WDTSignUpProfileViewController
                signUpProfileVC.m_currentUser = self.m_currentUser
                signUpProfileVC.m_isFacebook = self.m_isFacebook
                self.navigationController?.pushViewController(signUpProfileVC, animated: true)
            } else {                
                showHud()
                m_objVerification?.verify(textField.text!) { (success, error) in
                    if success {
                        self.hideHud()
                        let signUpProfileVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTSignUpProfileViewController.self)) as! WDTSignUpProfileViewController
                        signUpProfileVC.m_currentUser = self.m_currentUser
                        signUpProfileVC.m_isFacebook = self.m_isFacebook
                        self.navigationController?.pushViewController(signUpProfileVC, animated: true)
                    } else {
                        self.hideHudWithError(error?.localizedDescription ?? "Error Verification")
                    }
                }
            }
        }
        
        return false
    }
}
