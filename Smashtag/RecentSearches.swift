//
//  UserDefaults.swift
//  Smashtag
//
//  Created by WangQi on 16/7/11.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import Foundation

class RecentSearches {
    
    private struct Constants {
        static let RecentSearchesKey = "RecentSearches.Values"
        static let NumberOfSearches = 100
    }
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()

    // MARK: -Recent Searches
    
    var recentSearches: [String] {
        get {
            return userDefaults.objectForKey(Constants.RecentSearchesKey) as? [String] ?? []
        }
        set {
            userDefaults.setObject(newValue, forKey: Constants.RecentSearchesKey)
        }
    }
    
    
    func insertRecentSearch(searchQuery: String) {
        
        var currentSearches = recentSearches
        let matches = currentSearches.filter { $0 == searchQuery }
        
        if matches.first != nil {
            if let indexToRemove = currentSearches.indexOf(matches.first!) {
                currentSearches.removeAtIndex(indexToRemove)
            }
        }
        currentSearches.insert((searchQuery), atIndex: 0)
        
        while currentSearches.count > Constants.NumberOfSearches {
            currentSearches.removeLast()
        }
        
        recentSearches = currentSearches
    }
    
    func removeRecentSearchAtIndex(index: Int) {
        var currentSearches = recentSearches
        currentSearches.removeAtIndex(index)
        recentSearches = currentSearches
    }
        
    /*
    func insertRecentSearch(searchQuery: String) {
        // keep recent searches unique
        let matches = recentSearches.filter { $0 == searchQuery }
        if matches.first != nil {
            // it's enough to remove the first match, since we ensure only unique
            // searches are saved (matches will never contain more than 1 item)
            if let indexToRemove = recentSearches.indexOf(matches.first!) {
                recentSearches.removeAtIndex(indexToRemove)
            }
        }
        
        // limit recent search save count
        if recentSearches.count >= Constants.NumberOfSearches {
            recentSearches.removeLast()
        }
        recentSearches.insert((searchQuery), atIndex: 0)
    }*/
    
    
//    func storeSearchTerms(recentSearchTerms: [String]) {
//        
//        var searchTerms = recentSearchTerms
//        let exceedMax = searchTerms.count - 100
//        if exceedMax > 0 {
//            for _ in 1...exceedMax {
//                searchTerms.removeLast()
//            }
//        }
//        
//        userDefaults.setObject(searchTerms, forKey: Key.RecentSearchTerms)
//    }
//    
//    func fetchSearchTerms() -> [String] {
//        return userDefaults.objectForKey(Key.RecentSearchTerms) as? [String] ?? []
//    }
//    
//    func deleteSearchTerm(removeAtIndexPath indexPath: NSIndexPath) {
//        if var searchTerms = userDefaults.objectForKey(Key.RecentSearchTerms) as? [String] {
//            searchTerms.removeAtIndex(indexPath.row)
//            storeSearchTerms(searchTerms)
//        }
//    }
}