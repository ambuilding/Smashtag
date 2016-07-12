//
//  MentionTableViewController.swift
//  Smashtag
//
//  Created by WangQi on 16/7/5.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import UIKit
import Twitter

class MentionTableViewController: UITableViewController {
    
    var tweet: Twitter.Tweet? {
        didSet {
            if let tweet = tweet {
                title = tweet.user.name
                
                // images
                if tweet.media.count > 0 {
                    var mediaItems = [KeywordA]()
                    for mediaItem in tweet.media {
                        mediaItems.append(KeywordA.Image(mediaItem))
                    }
                    addKeywordsAs(mediaItems)
                }
                
                // hashtags
                if tweet.hashtags.count > 0 {
                    var hashtags = [KeywordA]()
                    for hashtag in tweet.hashtags {
                        hashtags.append(KeywordA.Hashtag(hashtag.keyword))
                    }
                    addKeywordsAs(hashtags)
                }
                
                // URLs
                if tweet.urls.count > 0 {
                    var urls = [KeywordA]()
                    for url in tweet.urls {
                        urls.append(KeywordA.URL(url.keyword))
                    }
                    addKeywordsAs(urls)
                }
                
                // users
                var userMentions = [KeywordA]()
                userMentions.append(KeywordA.UserMention("@\(tweet.user.screenName)"))
                if tweet.userMentions.count > 0 {
                    for userMention in tweet.userMentions {
                        userMentions.append(KeywordA.UserMention(userMention.keyword))
                    }
                }
                addKeywordsAs(userMentions)
            }
        }
    }
    
    private var keywordAs = [[KeywordA]]()
    private func addKeywordsAs(keywordAsToInsert: [KeywordA]) {
        keywordAs.insert(keywordAsToInsert, atIndex: keywordAs.count)
    }
    
    private enum KeywordA {
        case Image(MediaItem)
        case Hashtag(String)
        case URL(String)
        case UserMention(String)
        
        var description: String {
            
            switch self {
            case .Image(let mediaItem): return mediaItem.url.absoluteString
            case .Hashtag(let hashtag): return hashtag
            case .URL(let url): return url
            case .UserMention(let userMention): return userMention
            }
        }
        
        var type: String {
            
            switch self {
            case .Image(_): return "Images"
            case .Hashtag(_): return "Hashtags"
            case .URL(_): return "Urls"
            case .UserMention(_): return "UserMentions"
            }
        }
    }
    
    private struct Storyboard {
        static let ImageCellIdentifier = "ImageCell"
        static let TextCellIdentifier = "TextCell"
        static let ShowImageSegue = "ShowImage"
        static let TwitterSearchSegue = "TwitterSearch"
    }

    private struct Constants {
        static let goldenRatio = (1 + sqrt(5.0))/2
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let keywordA = keywordAs[indexPath.section][indexPath.row]
        
        switch keywordA {
        case .Image(_):
            return view.bounds.width / CGFloat(Constants.goldenRatio)
        default:
            return UITableViewAutomaticDimension
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - UITableViewDatasource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keywordAs.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywordAs[section].count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keywordAs[section].first!.type
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let keywordA = keywordAs[indexPath.section][indexPath.row]
        
        switch keywordA {
        case .Image(let mediaItem):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellIdentifier, forIndexPath: indexPath) as! MentionImageTableViewCell
            cell.mediaItem = mediaItem
            
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TextCellIdentifier, forIndexPath: indexPath) as! MentionTextTableViewCell
            cell.keywordA = keywordA.description
            
            return cell
        }

    }


    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            let keywordA = keywordAs[indexPath.section][indexPath.row]
            switch keywordA {
            case .URL(let urlString):
                if let url = NSURL(string: urlString) {
                    UIApplication.sharedApplication().openURL(url)
                }
                return false
            default: break
            }
        }
        
        return true
    }

     //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case Storyboard.ShowImageSegue:
                if let ivc = segue.destinationViewController as? ImageViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let keywordA = keywordAs[indexPath.section][indexPath.row]
                        switch keywordA {
                        case .Image(let media):
                            ivc.imageURL = media.url
                            ivc.aspectRatio = media.aspectRatio
                        default:
                            break
                        }
                    }
                }
            case Storyboard.TwitterSearchSegue:
                if let tvc = segue.destinationViewController as? TweetTableViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let keywordA = keywordAs[indexPath.section][indexPath.row]
                        switch keywordA {
                        case .UserMention:
                            let userScreenName = keywordA.description.stringByReplacingOccurrencesOfString("@", withString: "")
                            let userAtName = keywordA.description
                            tvc.setNewSearchRequest("from:\(userScreenName) OR \(userAtName)")
                            
                        default:
                            tvc.setNewSearchRequest(keywordA.description)
                        }
                        
                    }
                }
            default:
                break
            }
        }
    }

}

