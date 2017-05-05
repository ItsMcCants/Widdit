//
//  BaseViewController.swift
//  CPImageViewer
//
//  Created by ZhaoWei on 16/2/27.
//  Copyright © 2016年 cp3hnu. All rights reserved.
//

import UIKit

open class CPImageViewerAnimator: NSObject, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {

    fileprivate let animator = CPImageViewerAnimationTransition()
    fileprivate let interativeAnimator = CPImageViewerInteractiveTransition()

    //MARK: - UIViewControllerTransitioningDelegate
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if source is CPImageControllerProtocol && presenting is CPImageControllerProtocol && presented is CPImageViewerViewController {
            if let navi = presenting as? UINavigationController {
                navi.animationImageView = (source as! CPImageControllerProtocol).animationImageView
            } else if let tabBarVC = presenting as? UITabBarController {
                tabBarVC.animationImageView = (source as! CPImageControllerProtocol).animationImageView
            }
            
            interativeAnimator.wireToViewController(presented as! CPImageViewerViewController)
            interativeAnimator.isPresented = true
            animator.isBack = false
            return animator
        }
        
        return nil
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed is CPImageViewerViewController {
            animator.isBack = true
            return animator
        }
        
        return nil
    }
    
    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interativeAnimator.interactionInProgress ? interativeAnimator : nil
    }
    
    //MARK: - UINavigationDelegate
    open func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push && fromVC is CPImageControllerProtocol && toVC is CPImageViewerViewController {
            interativeAnimator.wireToViewController(toVC as! CPImageViewerViewController)
            interativeAnimator.isPresented = false
            animator.isBack = false
            return animator
        } else if operation == .pop  && fromVC is CPImageViewerViewController && toVC is CPImageControllerProtocol {
            animator.isBack = true
            return animator
        }
        
        return nil
    }
    
    open func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interativeAnimator.interactionInProgress ? interativeAnimator : nil
    }
}
