//
//  MentionImageTableViewCell.swift
//  Smashtag
//
//  Created by WangQi on 16/7/5.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import UIKit
import Twitter

class MentionImageTableViewCell: UITableViewCell {
    
    // MARK: - Public API

    var imageURL: NSURL? {
        didSet {
            updateUI()
        }
    }
    
    
    @IBOutlet weak var mentionImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    private func updateUI() {
        
        if let url = imageURL {
            spinner?.startAnimating()
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let contentsOfURL = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL {
                        if let imageData = contentsOfURL{
                            self.mentionImageView?.image = UIImage(data: imageData)
                        }
                    }
                    self.spinner?.stopAnimating()
                }   
            }
        }
    }
}
