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
    
    var mediaItem: Twitter.MediaItem? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var mentionImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var mentionImage: UIImage? {
        didSet {
            mentionImageView.image = mentionImage
            activityIndicator?.stopAnimating()
        }
    }
    
    private func updateUI() {
        mentionImageView?.image = nil
        
        if let mediaItem = mediaItem {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            activityIndicator.startAnimating()
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                if let imageData = NSData(contentsOfURL: mediaItem.url) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if mediaItem.url == self.mediaItem?.url {
                            self.mentionImage = UIImage(data: imageData)
                        }
                    }
                }
            }
            
        }
        
    }

}
