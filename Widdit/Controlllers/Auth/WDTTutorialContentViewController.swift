//
//  WDTTutorialContentViewController.swift
//  Widdit
//
//  Created by JH Lee on 04/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

class WDTTutorialContentViewController: UIViewController {

    @IBOutlet weak var m_lblBody: UILabel!
    @IBOutlet weak var m_imgPhoto: UIImageView!
    
    var body: String?
    var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        m_lblBody.text = body
        m_imgPhoto.image = photo
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

}
