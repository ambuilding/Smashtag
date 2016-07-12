//
//  RecentTableViewController.swift
//  Smashtag
//
//  Created by WangQi on 16/7/11.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import UIKit

class RecentSearchTableViewController: UITableViewController {
    
    private let userDefaults = UserDefaults()
    private var recentSearches: [String] {
        return userDefaults.fetchSearchTerms()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Recent Searches"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private struct Storyboard {
        static let RecentSearchCell = "RecentSearch"
        // TableViewReusableCellidentifier
        static let SearchTweetsSegueIdentifier = "SearchTweets"
        //SegueIdentifier
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.RecentSearchCell, forIndexPath: indexPath)

        cell.textLabel?.text = recentSearches[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            userDefaults.deleteSearchTerm(removeAtIndexPath: indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SearchTweetsSegueIdentifier:
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
