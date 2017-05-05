//
//  WDTWebViewController.swift
//  Widdit
//
//  Created by JH Lee on 27/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

class WDTWebViewController: UIViewController, UIWebViewDelegate {

    var m_strUrl: URL?
    
    @IBOutlet weak var m_viewWeb: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        showHud()
        title = m_strUrl?.host
        m_viewWeb.loadRequest(URLRequest(url: m_strUrl!))
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

    @IBAction func onClickBtnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIWebViewDelegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideHud()
    }
}
