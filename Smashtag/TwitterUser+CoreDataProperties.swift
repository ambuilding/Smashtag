//
//  TwitterUser+CoreDataProperties.swift
//  Smashtag
//
//  Created by WangQi on 16/6/4.
//  Copyright © 2016年 WangQi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TwitterUser {

    @NSManaged var screenName: String?
    @NSManaged var name: String?
    @NSManaged var tweets: NSSet?

}
