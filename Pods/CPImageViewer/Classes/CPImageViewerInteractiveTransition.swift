//
//  InteractiveTransition.swift
//  CPImageViewer
//
//  Created by ZhaoWei on 16/2/27.
//  Copyright © 2016年 cp3hnu. All rights reserved.
//

import UIKit

open class CPImageViewerInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning, UIGestureRecognizerDelegate {
    
    /// Be true when Present, and false when Push
    open  var isPresented = true
    
    /// Whether is interaction in progress. Default is false
    fileprivate(set) open var interactionInProgress = false
    
    fileprivate weak var imageViewerVC: CPImageViewerViewController!
    fileprivate var distance = UIScreen.main.bounds.size.height/2
    fileprivate var shouldCompleteTransition = false
    fileprivate var startInteractive = false
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    fileprivate var toVC: UIViewController!
    fileprivate var newImageView: UIImageView!
    fileprivate var backgroundView: UIView!
    fileprivate var toImageView: UIImageView!
    fileprivate var fromFrame: CGRect = CGRect.zero
    fileprivate var toFrame: CGRect = CGRect.zero
    fileprivate var style = UIModalPresentationStyle.fullScreen
    
    /**
     Install the pan gesture recognizer on view of *vc*
     
     - parameter vc: The *CPImageViewerViewController* view controller
     */
    open func wireToViewController(_ vc: CPImageViewerViewController) {
        imageViewerVC = vc
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CPImageViewerInteractiveTransition.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        panGesture.delegate = self
        vc.view.addGestureRecognizer(panGesture)
    }
    
    //MARK: - UIViewControllerInteractiveTransitioning
    open func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        startInteractive = true
        self.transitionContext = transitionContext
        style = transitionContext.presentationStyle
        
        toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        // Solving the error of location of image view after rotating device and returning to previous controller. See ImageViewerViewController.init()
        // The OverFullScreen style don't need add toVC.view
        // The style is None when ImageViewerViewController.viewerStyle is CPImageViewerStyle.Push
        if style != .overFullScreen {
            containerView.addSubview(toVC.view)
            containerView.sendSubview(toBack: toVC.view)
            
            if toVC.view.bounds.size != finalFrame.size {
                toVC.view.frame = finalFrame
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
            }
        }
        
        backgroundView = UIView(frame: finalFrame)
        backgroundView.backgroundColor = UIColor.black
        containerView.addSubview(backgroundView)
        
        let fromImageView: UIImageView! = imageViewerVC.animationImageView
        toImageView = (toVC as! CPImageControllerProtocol).animationImageView
        fromFrame = fromImageView.convert(fromImageView.bounds, to: containerView)
        toFrame = toImageView.convert(toImageView.bounds, to: containerView)
    
        newImageView = UIImageView(frame: fromFrame)
        newImageView.image = fromImageView.image
        newImageView.contentMode = .scaleAspectFit
        containerView.addSubview(newImageView)
        
        imageViewerVC.view.alpha = 0.0
    }
    
    //MARK: - UIPanGestureRecognizer
    @objc fileprivate func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        let currentPoint = gesture.translation(in: imageViewerVC.view)
        switch (gesture.state) {
        case .began:
            interactionInProgress = true
            if isPresented {
                imageViewerVC.dismiss(animated: true, completion: nil)
            } else {
                _ = imageViewerVC.navigationController?.popViewController(animated: true)
            }
        
        case .changed:
            updateInteractiveTransition(currentPoint)
            
        case .ended, .cancelled:
            interactionInProgress = false
            if (!shouldCompleteTransition || gesture.state == .cancelled) {
                cancelTransition()
            } else {
                completeTransition()
            }
            
        default:
            break
        }
    }
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let currentPoint = panGesture.translation(in: imageViewerVC.view)
            return fabs(currentPoint.y) > fabs(currentPoint.x)
        }
        
        return true
    }
    
    //MARK: - Update & Complete & Cancel
    fileprivate func updateInteractiveTransition(_ currentPoint: CGPoint) {
        guard startInteractive else { return }
        
        let percent = min(fabs(currentPoint.y) / distance, 1)
        
        shouldCompleteTransition = (percent > 0.3)
        transitionContext?.updateInteractiveTransition(percent)
        backgroundView.alpha = 1 - percent
        newImageView.frame.origin.y = fromFrame.origin.y + currentPoint.y
        
        if (fromFrame.width > UIScreen.main.bounds.size.width - 60)
        {
            newImageView.frame.size.width = fromFrame.width - percent * 60.0
            newImageView.frame.origin.x = fromFrame.origin.x + percent * 30.0
        }
    }
    
    fileprivate func completeTransition() {
        guard startInteractive else { return }
        
        let duration = 0.3
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.newImageView.frame = self.toFrame
            self.backgroundView.alpha = 0.0
            }, completion: { finished in
                self.startInteractive = false
                
                self.newImageView.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
                
                self.toImageView.alpha = 1.0
                
                self.transitionContext?.finishInteractiveTransition()
                self.transitionContext?.completeTransition(true)
        })
    }
    
    fileprivate func cancelTransition() {
        guard startInteractive else { return }
        
        let duration = 0.3
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.newImageView.frame = self.fromFrame
            self.backgroundView.alpha = 1.0
            }, completion: { finished in
                self.startInteractive = false
                
                self.newImageView.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
                
                self.imageViewerVC.view.alpha = 1.0
                if self.style != .overFullScreen {
                    self.toVC.view.removeFromSuperview()
                }
                
                self.transitionContext?.cancelInteractiveTransition()
                self.transitionContext?.completeTransition(false)
        })
    }
}
