//
//  Message.swift
//  NanChat
//
//  Created by George Fitzgibbons on 2/10/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import Foundation
import CoreData


class Message: NSManagedObject {

    var isIncoming: Bool {
       return sender != nil    }
}


