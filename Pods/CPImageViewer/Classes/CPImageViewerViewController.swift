//
//  DeleteImageViewController.swift
//  EdusnsClient
//
//  Created by ZhaoWei on 16/2/2.
//  Copyright © 2016年 csdept. All rights reserved.
//

import UIKit

public enum CPImageViewerStyle {
    /// Present style
    case presentation
    
    /// Navigation style
    case push
}

open class CPImageViewerViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, CPImageControllerProtocol {
    
    /// The animation imageView conforming to `CPImageControllerProtocol`
    open var animationImageView: UIImageView!
    
    /// The viewer style. Defaults to **Presentation**
    open var viewerStyle = CPImageViewerStyle.presentation
    
    /// The image of animation image view
    open var image: UIImage?
    
    /// The title of *navigationItem.rightBarButtonItem* when viewerStyle is Push
    open var rightBarItemTitle: String?
    
    /// The image of *navigationItem.rightBarButtonItem* when viewerStyle is Push
    open var rightBarItemImage: UIImage?
    
    /// The action of *navigationItem.rightBarButtonItem* when viewerStyle is Push
    open var rightAction: ((Void) -> (Void))?
    
    fileprivate var scrollView: UIScrollView!
    
    fileprivate var isViewDidAppear = false
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        //Solving the error of location of image view after rotating device and returning to previous controller.
        modalPresentationStyle = .overFullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.black
        scrollView.maximumZoomScale = 5.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView" : scrollView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView" : scrollView]))
        
        animationImageView = UIImageView()
        animationImageView.image = image
        scrollView.addSubview(animationImageView)
        
        if viewerStyle == .presentation {
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissImageViewer))
            scrollView.addGestureRecognizer(tap)
        } else if let title = rightBarItemTitle {
            let rightItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarItemAction))
            navigationItem.rightBarButtonItem = rightItem
        } else if let image = rightBarItemImage {
            let rightItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rightBarItemAction))
            navigationItem.rightBarButtonItem = rightItem
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isViewDidAppear = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.zoomScale = 1.0
        scrollView.contentInset = UIEdgeInsets.zero
        animationImageView.frame = centerFrameForImageView()
    }
    
    open override var prefersStatusBarHidden: Bool {
        if viewerStyle == .presentation && isViewDidAppear {
            return true
        }
        
        return super.prefersStatusBarHidden
    }
    
    //MARK: - Custom Methods
    fileprivate func centerFrameForImageView() -> CGRect {
        guard let aImage = image else { return CGRect.zero }
        
        let viewWidth = scrollView.frame.size.width
        let viewHeight = scrollView.frame.size.height
        let imageWidth = aImage.size.width
        let imageHeight = aImage.size.height
        let newWidth = min(viewWidth, CGFloat(floorf(Float(imageWidth * (viewHeight / imageHeight)))))
        let newHeight = min(viewHeight, CGFloat(floorf(Float(imageHeight * (viewWidth / imageWidth)))))
        
        return CGRect(x: (viewWidth - newWidth)/2, y: (viewHeight - newHeight)/2, width: newWidth, height: newHeight)
    }
    
    fileprivate func centerScrollViewContents() {
        let viewWidth = scrollView.frame.size.width
        let viewHeight = scrollView.frame.size.height
        let imageWidth = animationImageView.frame.size.width
        let imageHeight = animationImageView.frame.size.height
        
        let originX = max(0, (viewWidth - imageWidth)/2)
        let originY = max(0, (viewHeight - imageHeight)/2)
        animationImageView.frame.origin = CGPoint(x: originX, y: originY)
    }

    //MARK: - Button Action
    @objc fileprivate func rightBarItemAction() {
        navigationController!.popViewController(animated: true)
        if let block = rightAction {
            block()
        }
    }
    
    @objc fileprivate func dismissImageViewer() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UIScrollViewDelegate
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return animationImageView
    }
    
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
