//
//  WDTWelcomeViewController.swift
//  Widdit
//
//  Created by JH Lee on 04/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class WDTWelcomeViewController: WDTNoNavigationBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if UserDefaults.isFirstStart() {
            let tutorialVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTTutorialViewController.self)) as! WDTTutorialViewController
            present(tutorialVC, animated: false, completion: nil)
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
    
    @IBAction func onClickBtnSignUp(_ sender: Any) {
        let signUpPhoneVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTSignUpPhoneViewController.self))
        navigationController?.pushViewController(signUpPhoneVC!, animated: true)
    }
    
    @IBAction func onClickBtnFBLogin(_ sender: Any) {
        PFFacebookUtils.logInInBackground(withReadPermissions: ["email", "public_profile"]) { (user, error) in
            if let error = error {
                self.showErrorAlert(error.localizedDescription)
            } else {
                if let signUpFinished = user?["signUpFinished"] as? Bool, signUpFinished {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.startApplication(true)
                } else {
                    self.showHud()
                    FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (connection, result, error) in
                        if let error = error {
                            self.hideHudWithError(error.localizedDescription)
                        } else {
                            self.hideHud()
                            if let result = result as? [String: Any] {
                                user?["email"] = result["email"]
                                user?["name"] = result["name"]
                                if let userID = result["id"] as? String {
                                    do {
                                        let imgAvatar = try UIImage(data: Data(contentsOf: URL(string: "https://graph.facebook.com/\(userID)/picture?type=large")!))
                                        let dataAvatar = UIImageJPEGRepresentation(imgAvatar!.resizeImage(CGFloat(Constants.Integer.AVATAR_SIZE)), 0.5)
                                        let fileAvatar = PFFile(name: "ava.jpg", data: dataAvatar!)
                                        user?["ava"] = fileAvatar
                                    } catch let error as NSError {
                                        print(error.localizedDescription)
                                    }
                                }
                            
                                if let phoneNumber = user?["phoneNumber"] as? String, phoneNumber.characters.isEmpty == false {
                                    let signUpProfileVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTSignUpProfileViewController.self)) as! WDTSignUpProfileViewController
                                    signUpProfileVC.m_currentUser = user!
                                    signUpProfileVC.m_isFacebook = true
                                    self.navigationController?.pushViewController(signUpProfileVC, animated: true)
                                } else {
                                    let signUpPhoneVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: WDTSignUpPhoneViewController.self)) as! WDTSignUpPhoneViewController
                                    signUpPhoneVC.m_currentUser = user!
                                    signUpPhoneVC.m_isFacebook = true
                                    self.navigationController?.pushViewController(signUpPhoneVC, animated: true)
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func onClickBtnLogIn(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: String(describing: WDTLogInViewController.self))
        navigationController?.pushViewController(loginVC!, animated: true)
    }
    
}
