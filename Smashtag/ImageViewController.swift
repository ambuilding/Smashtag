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
        if let imageURL = imageURL {
            spinner?.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                if let imageData = NSData(contentsOfURL: imageURL) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if imageURL == self.imageURL {
                            self.image = UIImage(data: imageData)
                        } else {
                            self.image = nil
                        }
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

 /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
