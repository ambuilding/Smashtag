//
//  RecentTableViewController.swift
//  Smashtag
//
//  Created by WangQi on 16/7/11.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import UIKit

class RecentSearchTableViewController: UITableViewController {
    
    // MARK: - life cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    private struct Storyboard {
        static let RecentSearchCellIdentifier = "RecentSearch"
        static let SearchTweetsSegue = "SearchTweets"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecentSearches().recentSearches.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.RecentSearchCellIdentifier, forIndexPath: indexPath)

        cell.textLabel?.text = RecentSearches().recentSearches[indexPath.row]
        return cell
    }
    
    // Override to support conditional editing of the table view.
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            RecentSearches().removeRecentSearchAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - Navigation

    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            
            switch identifier {
            case Storyboard.SearchTweetsSegue:
                if let cell = sender as? UITableViewCell, let text = cell.textLabel?.text {
                    if let tvc = segue.destinationViewController as? TweetTableViewController {
                        tvc.searchText = text
                    }
                }
            default:
                break
            }
        }
    }
    
}
