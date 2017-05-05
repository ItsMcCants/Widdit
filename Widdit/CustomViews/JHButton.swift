//
//  JHButton.swift
//  Widdit
//
//  Created by JH Lee on 04/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

@IBDesignable class JHButton: UIButton {
    @IBInspectable var CornerRadius: CGFloat = 0
    @IBInspectable var BorderWidth: CGFloat = 0
    @IBInspectable var BorderColor: UIColor = UIColor.clear
    @IBInspectable var TitleLines: Int = 1
    @IBInspectable var VerticalAlign: Bool = false
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        titleLabel?.numberOfLines = TitleLines
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
        
        layer.masksToBounds = true
        layer.borderWidth = BorderWidth
        layer.borderColor = BorderColor.cgColor
        layer.cornerRadius = CornerRadius
        
        setLayout()
    }
    
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)
        setLayout()
    }
    
    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        setLayout()
    }
    
    func setLayout() {
        if(VerticalAlign) {
            let imageSize = imageView?.frame.size
            titleEdgeInsets = UIEdgeInsetsMake(0.0,
                                               -imageSize!.width,
                                               -(imageSize!.height + 6.0),
                                               0.0);
            
            // raise the image and push it right so it appears centered
            //  above the text
            let titleSize = titleLabel?.frame.size;
            imageEdgeInsets = UIEdgeInsetsMake(-(titleSize!.height + 6.0),
                                               0.0,
                                               0.0,
                                               -titleSize!.width);
        }
    }
}
