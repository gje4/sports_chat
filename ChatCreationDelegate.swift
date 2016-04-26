//
//  ChatCreationDelegate.swift
//  NanChat
//
//  Created by George Fitzgibbons on 3/23/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import Foundation
import CoreData


protocol ChatCreationDelegate{
    func created(chat chat: Chat, incontext context: NSManagedObjectContext)
}