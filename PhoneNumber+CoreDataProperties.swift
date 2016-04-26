//
//  PhoneNumber+CoreDataProperties.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/22/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PhoneNumber {

    @NSManaged var kind: String?
    @NSManaged var registered: Bool
    @NSManaged var value: String?
    @NSManaged var contact: Contact?

}
