//
//  JHShadowView.swift
//  Widdit
//
//  Created by JH Lee on 07/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

@IBDesignable class JHShadowView: UIView {
    @IBInspectable var ShadowRadius: CGFloat = 0.0
    @IBInspectable var ShadowOpacity: Float = 0.0
    
    override func draw(_ rect: CGRect) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = ShadowRadius
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowOpacity = ShadowOpacity
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}
