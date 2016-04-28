//
//  Message+Firebase.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/26/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import Foundation
import Firebase
import CoreData



extension Message: FirebaseModel {
    func upload(rootRef: Firebase, context: NSManagedObjectContext) {
        if chat?.storageId == nil {
            //then store
            chat?.upload(rootRef, context: context)
        }
        //data dictionary
        let data = [
            "message" : text!,
            "score" : score!,
            "sender" : FirebaseStore.currentPhoneNumber! ]
        //
        guard let chat = chat, timestamp = timestamp,
            storageId = chat.storageId else {return}
        //create timestamp need string o .
        let timeInterval = String(Int64(timestamp.timeIntervalSince1970 * 100000))
        //set path for storing
        rootRef.childByAppendingPath("chats/"+storageId+"/messages/"+timeInterval).setValue(data)
    }
}

