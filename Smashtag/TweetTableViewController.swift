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
    
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            title = searchText
            
            if let searchText = searchText {
                searchTerms.insert(searchText, atIndex: 0)
            }
        }
    }
    
    let userDefaults = UserDefaults()
    
    var searchTerms: [String] {
        get { return userDefaults.fetchSearchTerms() }
        set { userDefaults.storeSearchTerms(newValue) }
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
    

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        searchText = "#stanford"
//
//    }
    
    private func updateDatabase(newTweets: [Twitter.Tweet]) {
        managedObjectContext?.performBlock {
            for twitterInfo in newTweets {
                _ = Tweet.tweetWithTwitterInfo(twitterInfo, inManagedObjectContext: self.managedObjectContext!)
            }
            do {
                try self.managedObjectContext?.save()
            }catch let error {
                print("Core Data Error: \(error)")
            }
        }
        printDatabaseStatistics()
        print("done printing database statistics")
    }
    
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    // MARK: Contants
    
    private struct StoryBoard {
        static let TweetCellIdentifier = "Tweet"
        static let ShowMentionSegue = "ShowMentionSegue"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.TweetCellIdentifier, forIndexPath: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
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
        
        setNewSearchRequest(searchText)
        return true
    }
    
    func setNewSearchRequest(searchText: String?) {
        searchTextField.text = searchText
        searchForTweets()
        tweets.removeAll()
        tableView.reloadData()
        //refresh()
        
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
   
    // MARK: - Navigation
    
    @IBAction func goBack(segue: UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TweetersMentioningSearchTerm" {
            if let tweetersTVC = segue.destinationViewController as? TweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.managedObjectContext = managedObjectContext
            }
        } else if segue.identifier == StoryBoard.ShowMentionSegue {
            if let vc = segue.destinationViewController as? MentionTableViewController {
                if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
                    vc.tweet = tweets[indexPathForSelectedRow.section][indexPathForSelectedRow.row]
                }
            }
        }
    }
    
}
