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
    
    // MARK: - Public API
    
    var tweet: Twitter.Tweet? {
        didSet {
            title = tweet?.user.screenName
            
            if let media = tweet?.media where media.count > 0 {
                mentionSections.append(MentionSection(
                    title: "Images",
                    data: media.map { MentionItem.Image($0.url, $0.aspectRatio) }
                ))
            }
            
            if let urls = tweet?.urls where urls.count > 0 {
                mentionSections.append(MentionSection(
                    title: "URLs",
                    data: urls.map { MentionItem.Text($0.keyword) }
                ))
            }
            
            if let hashtags = tweet?.hashtags where hashtags.count > 0 {
                mentionSections.append(MentionSection(
                    title: "Hashtags",
                    data: hashtags.map{ MentionItem.Text($0.keyword) }
                ))
            }
            
            if let users = tweet?.userMentions {
                var userItems = [MentionItem]()
                if let screenName = tweet?.user.screenName {
                    userItems += [MentionItem.Text("@" + screenName)]
                }
                if users.count > 0 {
                    userItems += users.map { MentionItem.Text($0.keyword) }
                }
                if userItems.count > 0 {
                    mentionSections.append(MentionSection(
                        title: "Users",
                        data: userItems))
                }
                
            }
        }
    }
    
    private var mentionSections: [MentionSection] = []
    
    private struct MentionSection: CustomStringConvertible {
        var title: String
        var data: [MentionItem]
        
        var description: String { return "\(title): \(data)" }
    }
    
    private enum MentionItem: CustomStringConvertible {
        case Text(String)
        case Image(NSURL, Double)
        
        var description: String {
            switch self {
            case .Text(let text):
                return text
            case .Image(let url, _):
                return url.path ?? ""
            }
        }
    }
    
    // MARK: - UITableViewDatasource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentionSections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionSections[section].data.count
    }
    
    private struct Storyboard {
        static let ImageCellIdentifier = "ImageCell"
        static let TextCellIdentifier = "TextCell"
        static let ShowImageSegue = "ShowImage"
        static let TwitterSearchSegue = "TwitterSearch"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let mention = mentionSections[indexPath.section].data[indexPath.row]
        
        switch mention {
        case .Text(let text):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TextCellIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = text
            
            return cell
        case .Image(let url, _):
            let cell = tableView.dequeueReusableCellWithIdentifier(
                Storyboard.ImageCellIdentifier,
                forIndexPath: indexPath
            )
            if let imageCell = cell as? MentionImageTableViewCell {
                imageCell.imageURL = url
            }
            return cell
        }  
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let mention = mentionSections[indexPath.section].data[indexPath.row]
        switch mention {
        case .Image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentionSections[section].title
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == Storyboard.TwitterSearchSegue {
            if let cell = sender as? UITableViewCell {
                if let url = cell.textLabel?.text {
                    if url.hasPrefix("http") {
                        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                        return false
                    }
                }
            }
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case Storyboard.ShowImageSegue:
                if let imagevc = segue.destinationViewController as? ImageViewController {
                    if let cell = sender as? MentionImageTableViewCell {
                        imagevc.imageURL = cell.imageURL
                        imagevc.title = title
                    }
                }
                
            case Storyboard.TwitterSearchSegue:
                if let ttvc = segue.destinationViewController as? TweetTableViewController,
                    let cell = sender as? UITableViewCell,
                    var text = cell.textLabel?.text {
                    if text.hasPrefix("@") {
                        text += " OR from:" + text
                    }
                    ttvc.searchText = text
                    
                }
            default:
                break
            }
        }
    }
}