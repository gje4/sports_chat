//
//  Chat+Firebase.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/26/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import Foundation
import Firebase
import CoreData

//message uploader
extension Chat:FirebaseModel{
    
    //observe changes
    func observeMessages(rootRef:Firebase, context: NSManagedObjectContext) {
        guard let storageId = storageId else {return}
        let lastFetch = lastMessage?.timestamp?.timeIntervalSince1970 ?? 0
        
        rootRef.childByAppendingPath("chats/"+storageId+"/messages")
            .queryOrderedByKey().queryStartingAtValue(String(lastFetch * 100000))
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                context.performBlock{
                    //
                    guard let phoneNumber = snapshot.value["sender"] as? String where phoneNumber != FirebaseStore.currentPhoneNumber else {return}
                    guard let text = snapshot.value["message"] as? String else {return}
                    guard let timeInterval = Double(snapshot.key) else {return}
                    let date = NSDate(timeIntervalSince1970: timeInterval/100000)
                    
                    //
                    guard let message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as? Message else {return}
                    
                    message.text = text
                    message.timestamp = date
                    message.sender = Contact.existing(withPhoneNumber: phoneNumber, rootRef: rootRef, inContext: context) ?? Contact.new(forPhoneNumber: phoneNumber, rootRef: rootRef, inContext: context)

                    message.chat = self
                    
                    self.lastMessageTime = message.timestamp
                    do{
                        try context.save()
                    }catch{}
                }
            })
    }

    
    
    //method to create a new Chat instances in Firebase from core data
    static func new(forStorageId storageId:String, rootRef:Firebase, inContext context: NSManagedObjectContext)->Chat {
        let chat = NSEntityDescription.insertNewObjectForEntityForName("Chat", inManagedObjectContext: context) as! Chat
        //apend a storageID from method paramters
        chat.storageId = storageId
        //firebase saving path
        rootRef.childByAppendingPath("chats/"+storageId+"/meta")
            //assign value to snapshot
            .observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                //data dictionary from snapshot
                guard let data = snapshot.value as? NSDictionary else {return}
                //people in the chat dictionary from the data dictionary above
                guard let participantsDict = data["participants"] as? NSMutableDictionary else {return}
                // we have to deal with the fact that the currentUser is automatically included in the particpants. In order to remove the current user we call removeObjectForKey and pass in the currentPhoneNumber from the FirebaseStore
                participantsDict.removeObjectForKey(FirebaseStore.currentPhoneNumber!)
                //get all of the people
                let participants = participantsDict.allKeys.map {
                    (PhoneNumber:AnyObject) -> Contact in
                    let phoneNumber = PhoneNumber as! String
                    return Contact.existing(withPhoneNumber: phoneNumber, rootRef: rootRef, inContext: context) ?? Contact.new(forPhoneNumber: phoneNumber, rootRef: rootRef, inContext: context)
                }
                //save using the above participants
                let name = data["name"] as? String
                context.performBlock{
                    chat.participants = NSSet(array: participants)
                    chat.name = name
                    do {
                        try context.save()
                    }catch {}
                    chat.observeMessages(rootRef, context: context)
                }
            })
        return chat
    }
    
    
    
    
    
    
    
    // a method to retrieve existing Chat instances, pass in storage id as parameter to find chats
    static func existing(storageId storageId: String, inContext context:NSManagedObjectContext) ->Chat? {
        let request = NSFetchRequest(entityName: "Chat")
        //get chats based on storage id
        request.predicate = NSPredicate(format: "storageId=%@", storageId)
        do {
            //if there is then shet to the results array
            if let results = try context.executeFetchRequest(request) as? [Chat] where results.count > 0 {
                //get the first one (based on storage id)
                if let chat = results.first {
                    return chat
                }
            }
        } catch  {print("error")}
        return nil
    }
    
    //upload data from core data
    func upload(rootRef: Firebase, context: NSManagedObjectContext) {
        guard storageId == nil else {return}
        //store under chats
        let ref = rootRef.childByAppendingPath("chats").childByAutoId()
        //use storage id as key
        storageId = ref.key
        //dictionary id key to message (ref)
        var data: [String:AnyObject] = [
            "id" : ref.key,]
        guard let participants = participants?.allObjects as? [Contact] else {return}
        var numbers = [FirebaseStore.currentPhoneNumber!:true]

        var userIds = [rootRef.authData.uid]
        
        for participant in participants{
            guard let phoneNumbers = participant.phoneNumbers?.allObjects as? [PhoneNumber] else {continue}
            
            guard let number = phoneNumbers.filter({$0.registered}).first else {continue}
            numbers[number.value!] = true
            userIds.append(participant.storageId)
        }
        data["participants"] = numbers
        if let name = name {
            data["name"] = name
        }
        //write to firebaste
        ref.setValue(["meta": data])
        for id in userIds {
            rootRef.childByAppendingPath("users/"+id+"/chats/"+ref.key).setValue(true)
        }
        
        
    }
}