//
//  ImageViewController.swift
//  Smashtag
//
//  Created by WangQi on 16/7/6.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
        }
    }
    
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            scrollView?.setZoomScale(scrollViewZoomScale, animated: false)
            spinner?.stopAnimating()
        }
    }
    
    var imageURL: NSURL? {
        didSet {
            image = nil
            
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    var aspectRatio: Double?
    
    private func fetchImage() {
        if let url = imageURL {
            spinner?.startAnimating()
           
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let contentsOfURL = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL {
                        if let imageData = contentsOfURL {
                            self.image = UIImage(data: imageData)
                        } else {
                            self.spinner?.stopAnimating()
                        }
                    } else {
                        self.image = nil
                    }
                }
            }
        }
    }
    
    private var scrollViewcontentOffsetSize: CGPoint {
        if scrollView != nil {
            var x = scrollView.bounds.origin.x
            var y = scrollView.bounds.origin.y
            
            if scrollView.contentSize.width > scrollView.frame.width {
                x = (scrollView.contentSize.width - scrollView.frame.width ) / 2
            } else {
                y = (scrollView.contentSize.height - scrollView.frame.height) / 2
            }
            
            return CGPointMake(x, y)
        }
        
        return CGPointZero
    }
    
    private var scrollViewZoomScale: CGFloat {
        if let scrollView = scrollView, aspectRatio = aspectRatio, image = image {
            
            let zoomToWidth = scrollView.frame.width / image.size.width
            let zoomToHeight = (scrollView.frame.height - topLayoutGuide.length - bottomLayoutGuide.length) / image.size.height
            
            if aspectRatio < Double(scrollView.frame.width / scrollView.frame.height) {
                scrollView.minimumZoomScale = zoomToHeight
                scrollView.maximumZoomScale = zoomToWidth * 2
                
                return zoomToWidth
            }else {
                scrollView.minimumZoomScale = zoomToWidth
                scrollView.maximumZoomScale = zoomToHeight * 2
                
                return zoomToHeight
            }
        }
        return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        
        setupGestureRecognizer()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    // MARK: -UIScrollViewDelegate method
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: - Device Rotation

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition(nil) { context in
            self.scrollView.setZoomScale(self.scrollViewZoomScale, animated: false)
            self.scrollView.setContentOffset(self.scrollViewcontentOffsetSize, animated: false)
        }
    }
    
    // be centered on the screen
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    /* implement the double-tap to zoom up to maximum if it’s currently at the minimum zoom scale, otherwise the double-tap will zoom it down to the minimum,
     */
    private func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(ImageViewController.handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }

}
