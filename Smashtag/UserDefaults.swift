//
//  UserDefaults.swift
//  Smashtag
//
//  Created by WangQi on 16/7/11.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import Foundation

class UserDefaults {
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private struct Key {
        static let RecentSearchTerms = "UserDefaults.Key.RecentSearches"
    }
    
    func storeSearchTerms(recentSearchTerms: [String]) {
        
        var searchTerms = recentSearchTerms
        let exceedMax = searchTerms.count - 100
        if exceedMax > 0 {
            for _ in 1...exceedMax {
                searchTerms.removeLast()
            }
        }
        
        userDefaults.setObject(searchTerms, forKey: Key.RecentSearchTerms)
    }
    
    func fetchSearchTerms() -> [String] {
        return userDefaults.objectForKey(Key.RecentSearchTerms) as? [String] ?? []
    }
    
    func deleteSearchTerm(removeAtIndexPath indexPath: NSIndexPath) {
        if var searchTerms = userDefaults.objectForKey(Key.RecentSearchTerms) as? [String] {
            searchTerms.removeAtIndex(indexPath.row)
            storeSearchTerms(searchTerms)
        }
    }
}