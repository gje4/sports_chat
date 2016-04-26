//
//  FirebaseModels.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/21/16.
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

//contacts uploader
extension Contact:FirebaseModel{
    //create a new contact to save to firebase
    static func new(forPhoneNumber phoneNumberVal:String, rootRef:Firebase, inContext context:NSManagedObjectContext) -> Contact {
        //set up attruboites
        let contact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: context) as! Contact
        let phoneNumber = NSEntityDescription.insertNewObjectForEntityForName("PhoneNumber", inManagedObjectContext: context) as! PhoneNumber
        //populate value
        phoneNumber.contact = contact
        phoneNumber.registered = true
        phoneNumber.value = phoneNumberVal
        //populate
        contact.getContactId(context, phoneNumber: phoneNumberVal, rootRef: rootRef)
        return contact
        
        
    }
    
    
    //check for contact
    static func existing(withPhoneNumber phoneNumber:String, rootRef:Firebase, inContext context:NSManagedObjectContext)->Contact?{
       //search for number
        let request = NSFetchRequest(entityName: "PhoneNumber")
        //search for phonenumer
        request.predicate = NSPredicate(format: "value=%@", phoneNumber)
        do{
            //if found
            if let results = try context.executeFetchRequest(request) as? [PhoneNumber] where results.count > 0{
              //return the first contact
                let contact = results.first!.contact!
               
                if contact.storageId == nil{
                //set up and store if a new contact
                    contact.getContactId(context,phoneNumber: phoneNumber, rootRef: rootRef)
                }
                //if found return the contact
                return contact
            }
        } catch{print("Error Fetching")}
        return nil
    }
    
    
    
    //firebase
    func getContactId(context:NSManagedObjectContext,phoneNumber:String, rootRef:Firebase) {
       //get data
        rootRef.childByAppendingPath("users")
            .queryOrderedByChild("phoneNumber")
            //only want users that have the same phone number as the parameter when func is called
            .queryEqualToValue(phoneNumber)
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                //implement the data returned
                guard let user = snapshot.value as? NSDictionary else {return}
                
                let uid = user.allKeys.first as? String
                context.performBlock{
                    self.storageId = uid
                    do {
                        //save
                        try context.save()
                    }catch{}
                }
            })
    }

    
    
    func upload(rootRef: Firebase, context: NSManagedObjectContext) {
        guard let phoneNumbers = phoneNumbers?.allObjects as? [PhoneNumber] else {return}
        
        for number in phoneNumbers {
            //get number form the dictionary array and querying (where)
            rootRef.childByAppendingPath("users")
                .queryOrderedByChild("phoneNumber")
                .queryEqualToValue(number.value)
                .observeSingleEventOfType(.Value, withBlock: { snapshot in
                    //get dictionary
                    guard let user = snapshot.value as? NSDictionary else {return}
                    let uid = user.allKeys.first as? String
                    
                    context.performBlock{
                        self.storageId = uid
                        number.registered = true
                        do {
                            try context.save()
                        } catch {
                            print("error saving")
                        }
                    }
                }) }
    }
    
    //observer to look for new users
    func observeStatus(rootRef:Firebase, context:NSManagedObjectContext) {
        rootRef.childByAppendingPath("users/"+storageId!+"/status")
            .observeEventType(.Value, withBlock:{
                snapshot in
                guard let status = snapshot.value as? String else {return}
                context.performBlock{
                    self.status = status
                    do {
                        try context.save()
                    }catch{print("Error saving")}
                    }
                })
                }
    
}

//message uploader
extension Chat:FirebaseModel{
    
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

extension Message: FirebaseModel {
    func upload(rootRef: Firebase, context: NSManagedObjectContext) {
        if chat?.storageId == nil {
            //then store
            chat?.upload(rootRef, context: context)
        }
        //data dictionary
        let data = [
            "message" : text!,
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

