//
//  JHTextField.swift
//  LiveNation
//
//  Created by JH Lee on 4/2/16.
//  Copyright © 2016 JH Lee. All rights reserved.
//

import UIKit

@IBDesignable class JHTextField: UITextField {
    @IBInspectable var CornerRadius: CGFloat = 0
    @IBInspectable var BorderWidth: CGFloat = 0
    @IBInspectable var BorderColor: UIColor = UIColor.clear
    @IBInspectable var LeftPadding: CGFloat = 10
    
    override func draw(_ rect: CGRect) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: LeftPadding, height: 20))
        leftView = paddingView;
        leftViewMode = .always;
        
        layer.masksToBounds = true
        layer.cornerRadius = CornerRadius
        layer.borderWidth = BorderWidth
        layer.borderColor = BorderColor.cgColor
    }
}
