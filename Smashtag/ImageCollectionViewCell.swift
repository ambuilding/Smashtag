//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by WangQi on 16/8/10.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import UIKit


class ImageCollectionViewCell: UICollectionViewCell {

    var cache: NSCache?
    var imageURL: NSURL? {
        didSet {
            backgroundColor = UIColor.darkGrayColor()
            image = nil
            fetchImage()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            spinner.stopAnimating()
        }
    }
    
    private func fetchImage() {
        
        if let url = imageURL {
            spinner?.startAnimating()
            
            let imageData = cache?.objectForKey(imageURL!) as? NSData
            guard imageData == nil else { image = UIImage(data: imageData!); return }
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let contentsOfURL = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL {
                        if let imageData = contentsOfURL {
                            self.image = UIImage(data: imageData)
                            self.cache?.setObject(
                                imageData,
                                forKey: self.imageURL!,
                                cost: imageData.length / 1024
                            )
                        } else {
                            self.image = nil
                        }
                    }
                }
            }
            
        }
    }
    
}
