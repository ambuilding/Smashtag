//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by WangQi on 16/5/27.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Model
    
    /*
     if this is nil, then we simply don't update the database
     probably it would be better to subclass TweetTVC
     and set this var in that subclass and then use that subclass in our storyboard
     the onlypurpose of that ubclass would be to pick what database we're using
     */
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? = "#coffee" {
        didSet {
            tweets.removeAll()
            lastTwitterRequest = nil
            searchTextField.text = searchText
            searchForTweets()
            title = searchText
            RecentSearches().insertRecentSearch(searchText!)
        }
    }
    
    
    // MARK: Fetching Tweets
    
    private var twitterRequet: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText where !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: 100)
            }
        }
        return lastTwitterRequest?.requestForNewer
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        
        if let request = twitterRequet {
            lastTwitterRequest = request
            
            request.fetchTweets { [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                            weakSelf?.updateDatabase(newTweets)
                        }
                    }
                    weakSelf?.refreshControl?.endRefreshing()
                }
            }
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    // add the Twitter.Tweet to the database
    
    private func updateDatabase(newTweets: [Twitter.Tweet]) {
        managedObjectContext?.performBlock {
            for twitterInfo in newTweets {
                // the _ = just lets readers of the code know
                // that we are intentionally igmoring the return value
                _ = Tweet.tweetWithTwitterInfo(twitterInfo, inManagedObjectContext: self.managedObjectContext!)
            }
            // there is a method in AppDelegate which will save the context as well
            // save and catch any error
            do {
                try self.managedObjectContext?.save()
            }catch let error {
                print("Core Data Error: \(error)")
            }
        }
        printDatabaseStatistics()
        /*
         even though we do this print()
         after printDatabaseStatistics() is called
         it will print  before because printDatabaseStatistics()
         returns immediately after putting a closure on the context's queue
         that closure then runs sometime later, after this print()
         */
        print("done printing database statistics")
    }
    
    /*
     print out how many Tweets and TwitterUsers are in the database
     uses two different ways of counting them
     the countForFetchRequest is much more efficient 
     since it does the count in the database itself
     */
    
    private func printDatabaseStatistics() {
        managedObjectContext?.performBlock {
            if let  results = try? self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "TwitterUser")) {
                print("\(results.count) TwitterUsers")
            }
            // a more efficient way to count objects ...
            let tweetCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
            print("\(tweetCount) Tweets")
        }
    }
    
    
    
    @IBAction func refresh(sender: UIRefreshControl) {
        searchForTweets()
    }
    

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count - section)"
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.TweetCellIdentifier, forIndexPath: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
    
    // MARK: Contants
    
    private struct StoryBoard {
        static let TweetCellIdentifier = "Tweet"
        static let ShowMentionSegue = "ShowMentionSegue"
        static let ShowImagesSegue = "ShowImages"
        static let TweetersMentioningSearchTermSegue = "TweetersMentioningSearchTerm"
    }

    
    // MARK: Outlets
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    // MARK: UITExtFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    

    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    

    @IBAction func showImages(sender: AnyObject) {
         performSegueWithIdentifier(StoryBoard.ShowImagesSegue, sender: sender)
    }
   
    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == StoryBoard.ShowMentionSegue {
            if let tweetCell = sender as? TweetTableViewCell {
                if tweetCell.tweet!.hashtags.count + tweetCell.tweet!.urls.count + tweetCell.tweet!.userMentions.count + tweetCell.tweet!.media.count == 0 {
                    return false
                }
            }
        }
        return true
    }
    
    //@IBAction func unwindToRoot(sender: UIStoryboardSegue) { }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // prepare for the segue that happens 
        // when the user hits the Tweeters bar button item
        
        if segue.identifier == StoryBoard.TweetersMentioningSearchTermSegue {
            if let tweetersTVC = segue.destinationViewController as? TweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.managedObjectContext = managedObjectContext
            }
        } else if segue.identifier == StoryBoard.ShowMentionSegue {
            if let mtvc = segue.destinationViewController as? MentionTableViewController {
                let tweetCell = sender as? TweetTableViewCell
                mtvc.tweet = tweetCell?.tweet
                
            }
        } else if segue.identifier == StoryBoard.ShowImagesSegue {
            if let icvc = segue.destinationViewController as? ImageCollectionViewController {
                icvc.tweets = tweets
                icvc.title = "\(searchText!)"
            }
        }
    }
    
}

//@IBAction func goBack(segue: UIStoryboardSegue) { }
// click hashtag or username in the MentionTableViewController, go back to search

