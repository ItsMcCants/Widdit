//
//  WDTTabItemAnimation.swift
//  Widdit
//
//  Created by JH Lee on 07/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController

class WDTTabItemAnimation: RAMItemAnimation {
    /**
     Start animation, method call when UITabBarItem is selected
     
     - parameter icon:      animating UITabBarItem icon
     - parameter textLabel: animating UITabBarItem textLabel
     */
    override open func playAnimation(_ icon : UIImageView, textLabel : UILabel) {
        playBounceAnimation(icon)
        icon.image = UIImage(named: "tabbar_icon_\(textLabel.text!.lowercased())_active")
    }
    
    /**
     Start animation, method call when UITabBarItem is unselected
     
     - parameter icon:      animating UITabBarItem icon
     - parameter textLabel: animating UITabBarItem textLabel
     - parameter defaultTextColor: default UITabBarItem text color
     - parameter defaultIconColor: default UITabBarItem icon color
     */
    override open func deselectAnimation(_ icon : UIImageView, textLabel : UILabel, defaultTextColor : UIColor, defaultIconColor: UIColor) {
        icon.image = UIImage(named: "tabbar_icon_\(textLabel.text!.lowercased())")
    }
    
    /**
     Method call when TabBarController did load
     
     - parameter icon:      animating UITabBarItem icon
     - parameter textLabel: animating UITabBarItem textLabel
     */
    override open func selectedState(_ icon : UIImageView, textLabel : UILabel) {
        icon.image = UIImage(named: "tabbar_icon_\(textLabel.text!.lowercased())_active")
    }
    
    func playBounceAnimation(_ icon : UIImageView) {
        
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(duration)
        bounceAnimation.calculationMode = kCAAnimationCubic
        
        icon.layer.add(bounceAnimation, forKey: nil)
    }
}
