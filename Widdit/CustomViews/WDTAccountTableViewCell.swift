//
//  WDTAccountTableViewCell.swift
//  Widdit
//
//  Created by JH Lee on 18/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

class WDTAccountTableViewCell: UITableViewCell {

    @IBOutlet weak var m_imgIcon: UIImageView!
    @IBOutlet weak var m_lblText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
