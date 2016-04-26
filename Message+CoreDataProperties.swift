//
//  Message+CoreDataProperties.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/6/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var celebrityName: String?
    @NSManaged var gameId: String?
    @NSManaged var sender: NSNumber?
    @NSManaged var text: String?
    @NSManaged var timestamp: NSDate?
    @NSManaged var chat: Chat?
    @NSManaged var senderId: Contact?

}
