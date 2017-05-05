//
//  WDTCategoryTableViewCell.swift
//  Widdit
//
//  Created by JH Lee on 09/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var m_lblName: UILabel!
    @IBOutlet weak var m_lblPostCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setViewWithPFObject(_ objCategory: PFObject) {
        m_lblName.text = "#" + (objCategory["title"] as? String)!
        m_lblPostCount.text = "+" + String(WDTPost.sharedInstance().getPosts(user: nil, category: objCategory["title"] as? String).count)
    }
}
