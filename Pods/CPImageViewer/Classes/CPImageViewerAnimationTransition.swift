//
//  ImageViewerAnimationController.swift
//  EdusnsClient
//
//  Created by ZhaoWei on 16/2/2.
//  Copyright © 2016年 csdept. All rights reserved.
//

import UIKit

open class CPImageViewerAnimationTransition: NSObject, UIViewControllerAnimatedTransitioning {

    
    /// Be false when Push or Present, and true when Pop or Dismiss
    open var isBack = false
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        let style = transitionContext.presentationStyle
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        // Solving the error of location of image view after rotating device and returning to previous controller. See ImageViewerViewController.init()
        // The OverFullScreen style don't need add toVC.view
        // The style is None when ImageViewerViewController.viewerStyle is CPImageViewerStyle.Push
        if style != .overFullScreen && isBack {
            containerView.addSubview(toVC.view)
            containerView.sendSubview(toBack: toVC.view)
            
            if toVC.view.bounds.size != finalFrame.size {
                toVC.view.frame = finalFrame
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
            }
        }
        
        let backgroundView = UIView(frame: finalFrame)
        backgroundView.backgroundColor = UIColor.black
        containerView.addSubview(backgroundView)
        
        let fromImageView: UIImageView! = (fromVC as! CPImageControllerProtocol).animationImageView
        let toImageView: UIImageView! = (toVC as! CPImageControllerProtocol).animationImageView
        let fromFrame = fromImageView.convert((fromImageView.bounds), to: containerView)
        let toFrame = toImageView.convert((toImageView.bounds), to: containerView)
        
        let newImageView = UIImageView(frame: fromFrame)
        newImageView.image = fromImageView.image
        newImageView.contentMode = .scaleAspectFit
        containerView.addSubview(newImageView)
        
        if !isBack {
            backgroundView.alpha = 0.0
            fromImageView.alpha = 0.0
        } else {
            backgroundView.alpha = 1.0
            fromVC.view.alpha = 0.0
        }
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(), animations: {
            if !self.isBack {
                newImageView.frame = finalFrame
                backgroundView.alpha = 1.0
            } else {
                newImageView.frame = toFrame
                backgroundView.alpha = 0.0
            }
            }, completion: { finished in
                newImageView.removeFromSuperview()
                backgroundView.removeFromSuperview()
                
                let cancel = transitionContext.transitionWasCancelled
                
                if !self.isBack {
                    if cancel {
                        fromImageView.alpha = 1.0
                    } else {
                        containerView.addSubview(toVC.view)
                    }
                } else {
                    if cancel {
                        fromVC.view.alpha = 1.0
                        if style != .overFullScreen {
                            toVC.view.removeFromSuperview()
                        }
                    } else {
                        toImageView.alpha = 1.0
                    }
                }
                transitionContext.completeTransition(!cancel)
        })
    }
}
