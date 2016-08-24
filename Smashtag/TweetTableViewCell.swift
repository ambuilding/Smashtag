//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by WangQi on 16/6/1.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
 
    var tweet: Twitter.Tweet? {
        didSet {
            update()
        }
    }
    
    private func update() {
        
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet {
            
            setBodyText(tweet)
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    let contentsOfURL = NSData(contentsOfURL: profileImageURL)
                    dispatch_async(dispatch_get_main_queue()) {
                        if let imageData = contentsOfURL { // blocks main thread!
                            self.tweetProfileImageView?.image = UIImage(data: imageData)
                        }
                    }
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        } 
    }
    
    func setBodyText(tweet: Twitter.Tweet) {
        
        var text = tweet.text
        tweetTextLabel?.text = text
        
        if tweetTextLabel?.text != nil {
            for _ in tweet.media {
                text += " 📷"
            }
        }
        
        let tweetText = NSMutableAttributedString(string: text)
        
        if !tweet.hashtags.isEmpty {
            for hashtag in tweet.hashtags {
                tweetText.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: hashtag.nsrange)
            }
        }
        
        if !tweet.urls.isEmpty {
            for url in tweet.urls {
                tweetText.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: url.nsrange)
            }
        }
        
        if !tweet.userMentions.isEmpty {
            for userMention in tweet.userMentions {
                tweetText.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: userMention.nsrange)
            }
        }
        
        tweetTextLabel?.attributedText = tweetText
        
    }
    
}


