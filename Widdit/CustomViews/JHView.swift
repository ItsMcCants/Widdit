//
//  JHView.swift
//  Widdit
//
//  Created by JH Lee on 07/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

@IBDesignable class JHView: UIView {
    @IBInspectable var CornerRadius: CGFloat = 0
    @IBInspectable var BorderWidth: CGFloat = 0
    @IBInspectable var BorderColor: UIColor = UIColor.clear
    
    override func draw(_ rect: CGRect) {
        layer.masksToBounds = true
        layer.cornerRadius = CornerRadius
        layer.borderWidth = BorderWidth
        layer.borderColor = BorderColor.cgColor
    }
}
