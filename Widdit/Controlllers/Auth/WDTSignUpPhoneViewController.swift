//
//  WDTSignUpPhoneViewController.swift
//  Widdit
//
//  Created by JH Lee on 06/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import PhoneNumberKit
import SinchVerification
import Parse

class WDTSignUpPhoneViewController: WDTNoNavigationBaseViewController, UITextFieldDelegate {

    @IBOutlet weak var m_txtPhoneNumber: UITextField!
    
    var m_currentUser = PFUser()
    var m_isFacebook = false
    
    let phoneNumberKit = PhoneNumberKit()
    let region = "US"
    var strPhoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        m_txtPhoneNumber.becomeFirstResponder()
        m_txtPhoneNumber.text = ""
        strPhoneNumber = ""
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
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {        
        if let letter = string.characters.first {
            strPhoneNumber.append(letter)
        } else {
            let index = strPhoneNumber.endIndex
            strPhoneNumber = strPhoneNumber.substring(to: strPhoneNumber.index(before: index))
        }
        
        textField.text = PartialFormatter().formatPartial(strPhoneNumber)
        
        do {
            let phoneNumber = try phoneNumberKit.parse(textField.text!, withRegion: region, ignoreType: true)
            let formattedString = phoneNumberKit.format(phoneNumber, toType: .e164)
            
            showHud()
            let userQuery = PFUser.query()
            userQuery?.whereKey("phoneNumber", equalTo: formattedString)
            userQuery?.findObjectsInBackground(block: { (aryUsers, error) in
                guard let aryUsers = aryUsers, aryUsers.isEmpty else {
                    self.hideHud()
                    self.showErrorAlert("Phone number already exists")
                    return
                }
                
                let verification = SMSVerification(Constants.SMSVerification.APPLICATION_KEY, phoneNumber: formattedString)
                verification.initiate({ (result, error) in
                    if result.success {
                        self.hideHud()
                        let signUpVerificiationVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTSignUpVerificationViewController.self)) as! WDTSignUpVerificationViewController
                        signUpVerificiationVC.m_isFacebook = self.m_isFacebook
                        signUpVerificiationVC.m_objVerification = verification
                        self.m_currentUser["phoneNumber"] = formattedString
                        signUpVerificiationVC.m_currentUser = self.m_currentUser
                        
                        self.navigationController?.pushViewController(signUpVerificiationVC, animated: true)
                    } else {
                        self.hideHudWithError(error?.localizedDescription ?? "Error sending SMS")
                    }                    
                })
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return false
    }
}
