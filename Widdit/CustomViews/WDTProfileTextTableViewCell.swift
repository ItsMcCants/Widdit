//
//  WDTProfileTextTableViewCell.swift
//  Widdit
//
//  Created by JH Lee on 18/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse

class WDTProfileTextTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var m_lblTitle: UILabel!
    @IBOutlet weak var m_txtValue: UITextField!    
    
    var m_dataType: WDTPersonalData?
    
    enum WDTPersonalData: Int {
        case Username
        case Name
        case Email
        
        func getDescription() -> (String, String?) {
            let objUser = PFUser.current()!
            
            switch self {
            case .Username:
                return ("Username", objUser.username)
            case .Name:
                return ("Name", objUser["name"] as? String)
            case .Email:
                return ("Email", objUser["email"] as? String)
            }
        }
        
        func setDescription(_ value: String?) {
            let objUser = PFUser.current()!
            
            switch self {
            case .Username:
                objUser.username = value
                break
            case .Name:
                objUser["name"] = value
                break;
            case .Email:
                objUser["email"] = value
                break;
            }
            
            objUser.saveInBackground()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setView(_ type: WDTPersonalData) {
        m_dataType = type
        
        let (title, value) = type.getDescription()
        m_lblTitle.text = title
        m_txtValue.text = value
        
        if type == .Email {
            m_txtValue.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        m_txtValue.resignFirstResponder()
        if (m_txtValue.text?.characters.count)! > 0 {
            m_dataType?.setDescription(m_txtValue.text)
        }
    }
    
}
