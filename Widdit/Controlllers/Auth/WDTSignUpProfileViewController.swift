//
//  WDTSignUpProfileViewController.swift
//  Widdit
//
//  Created by JH Lee on 06/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse
import SkyFloatingLabelTextField
import NSStringALEmail
import ALCameraViewController

class WDTSignUpProfileViewController: UIViewController {

    var m_currentUser = PFUser()
    var m_isFacebook = false
    
    @IBOutlet weak var m_imgAvatar: UIImageView!
    @IBOutlet weak var m_lblAvatarStatus: UILabel!
    
    @IBOutlet weak var m_txtUsername: SkyFloatingLabelTextField!
    @IBOutlet weak var m_txtName: SkyFloatingLabelTextField!
    @IBOutlet weak var m_txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var m_txtPassword: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if m_isFacebook {
            m_txtPassword.isEnabled = false
            m_txtEmail.isEnabled = false
        }
        
        if let fileAvatar = m_currentUser["ava"] as? PFFile {
            fileAvatar.getDataInBackground(block: { (dataAvatar, error) in
                if let dataAvatar = dataAvatar {
                    self.m_imgAvatar.image = UIImage(data: dataAvatar)
                    self.m_lblAvatarStatus.text = "Choose another photo"
                }
            })
        }
        
        if let name = m_currentUser["name"] as? String {
            m_txtName.text = name;
        }
        
        if let email = m_currentUser["email"] as? String {
            m_txtEmail.text = email;
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(onTapUserAvatar))
        m_imgAvatar.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
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
    
    @IBAction func onClickBtnRegister(_ sender: Any) {
        view.endEditing(true)
        
        if validateForm() {
            let userQuery = PFUser.query()
            showHud()
            userQuery!.whereKey("username", equalTo: m_txtUsername.text!)
            userQuery!.findObjectsInBackground(block: { (aryUsers, error) in
                if let error = error {
                    self.hideHudWithError(error.localizedDescription)
                } else {
                    if let _ = aryUsers!.first {
                        self.hideHudWithError("Username already exists")
                    } else {
                        let userQuery = PFUser.query()
                        userQuery!.whereKey("email", equalTo: self.m_txtEmail.text!)
                        userQuery!.findObjectsInBackground(block: { (aryUsers, error) in
                            self.hideHud()
                            if let _ = aryUsers!.first {
                                self.showErrorAlert("Email already exists")
                            } else {
                                self.m_currentUser.username = self.m_txtUsername.text!.lowercased()
                                self.m_currentUser["name"] = self.m_txtName.text!
                                self.m_currentUser["email"] = self.m_txtEmail.text!
                                self.m_currentUser.password = self.m_txtPassword.text!.lowercased()
                                self.m_currentUser["signUpFinished"] = true
                                self.m_currentUser["situationSchool"] = false
                                self.m_currentUser["situationWork"] = false
                                self.m_currentUser["situationOpportunity"] = false                                
                                
                                if self.m_isFacebook {
                                    self.m_currentUser["facebookVerified"] = true
                                    self.m_currentUser.saveInBackground(block: { (success, error) in
                                        if let error = error {
                                            self.hideHudWithError(error.localizedDescription)
                                        } else {
                                            self.hideHud()
                                            let signUpSituation = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTSignUpSituationViewController.self)) as! WDTSignUpSituationViewController
                                            self.navigationController?.pushViewController(signUpSituation, animated: true)
                                        }
                                    })
                                } else {
                                    self.m_currentUser.signUpInBackground(block: { (success, error) in
                                        if let error = error {
                                            self.hideHudWithError(error.localizedDescription)
                                        } else {
                                            self.hideHud()
                                            let signUpSituation = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTSignUpSituationViewController.self)) as! WDTSignUpSituationViewController
                                            self.navigationController?.pushViewController(signUpSituation, animated: true)
                                        }
                                    })
                                }
                            }
                        })
                    }
                }
            })
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
        
        if m_txtName.text!.isEmpty {
            isValid = false
            m_txtName.errorMessage = Constants.String.NO_NAME
        } else {
            m_txtName.errorMessage = ""
        }
        
        if m_txtEmail.text!.isValidEmail() {
            m_txtEmail.errorMessage = ""
        } else {
            isValid = false
            m_txtEmail.errorMessage = Constants.String.INVALID_EMAIL
        }
        
        if !m_isFacebook && m_txtPassword.text!.characters.count < 6 {
            isValid = false
            m_txtPassword.errorMessage = Constants.String.SHORT_PASSWORD
        } else {
            m_txtPassword.errorMessage = ""
        }
        
        return isValid
    }

    func onTapUserAvatar() {
        let cameraVC = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { (image, asset) in
            if let image = image {
                let dataAvatar = UIImageJPEGRepresentation(image.resizeImage(CGFloat(Constants.Integer.AVATAR_SIZE)), 0.5)
                let fileAvatar = PFFile(name: "ava.jpg", data: dataAvatar!)
                self.m_currentUser["ava"] = fileAvatar
                
                self.m_imgAvatar.image = image
                self.m_lblAvatarStatus.text = "Choose another photo"
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
        present(cameraVC, animated: true, completion: nil)
    }
    
}
