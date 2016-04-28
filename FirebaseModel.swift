//
//  FirebaseModel.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/26/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import Foundation
import CoreData
import Firebase

//sync core data and firbase
protocol FirebaseModel {
    //upload core data and core data at the same time
    func upload(rootRef: Firebase, context:NSManagedObjectContext)
}

