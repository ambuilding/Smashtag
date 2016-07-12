//
//  Tweet.swift
//  Smashtag
//
//  Created by WangQi on 16/6/4.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class Tweet: NSManagedObject {
    
    class func tweetWithTwitterInfo(twitterInfo: Twitter.Tweet, inManagedObjectContext context: NSManagedObjectContext) -> Tweet? {
        
        let request = NSFetchRequest(entityName: "Tweet")
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo)
        
        if let tweet = (try? context.executeFetchRequest(request))?.first as? Tweet {
            return tweet
        } else if let tweet = NSEntityDescription.insertNewObjectForEntityForName("Tweet", inManagedObjectContext: context) as? Tweet {
            
            tweet.unique = twitterInfo.id
            tweet.text = twitterInfo.text
            tweet.posted = twitterInfo.created
            tweet.tweeter = TwitterUser.tweetWithTwitterInfo(twitterInfo.user, inManagedObjectContext: context)
            
            return tweet
        }
        return nil
    }
}
