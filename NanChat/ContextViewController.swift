//
//  ContextViewController.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/7/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import Foundation
import CoreData

protocol ContextViewController {
    //can be get and set anywher
    var context: NSManagedObjectContext?{get set}
}
