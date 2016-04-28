//
//  Chat.swift
//  NanChat
//
//  Created by George Fitzgibbons on 3/15/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import Foundation
import CoreData


class Chat: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    var isGroupChat:Bool {
        return participants?.count > 1
    }
    var lastMessage:Message? {
        //get messages
        let request = NSFetchRequest(entityName: "Message")
        //where for current chat messages
        //chat must be equal to argument %@ is token for self
        request.predicate = NSPredicate(format: "chat =%@", self)
        //sort
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        //last message
        request.fetchLimit = 1
       //exciute request
        do {
            guard let results = try self.managedObjectContext?.executeFetchRequest(request)
                //arry of Message
                as? [Message] else {return nil}
            return results.first }
        catch {
            print("Error for Request")
        }
        return nil
    }
    
    func add(participant contact: Contact) {
        mutableSetValueForKey("participants").addObject(contact)

    }
    
    //
    static func existing(directWith contact: Contact, inContext context: NSManagedObjectContext) -> Chat? {
        let request = NSFetchRequest(entityName: "Chat")
        request.predicate = NSPredicate(format: "Any participants = %@ and participants.@count = 1", contact)
        do {
            guard let results = try context.executeFetchRequest(request) as? [Chat]
                else {return nil}
            return results.first
        }
        catch {
            print("error fetching")
        }
        return nil
    }
    
    //
    static func new(directWith contact:Contact, inContext context: NSManagedObjectContext)->Chat {
        let chat = NSEntityDescription.insertNewObjectForEntityForName("Chat", inManagedObjectContext: context) as! Chat
        chat.add(participant: contact)
        return chat
    }
    
}
