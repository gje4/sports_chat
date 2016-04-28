//
//  FirebaseStore.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/20/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import Foundation
import CoreData
import Firebase


class FirebaseStore {
    private let context:NSManagedObjectContext
    private let rootRef = Firebase(url:"https://party-time.firebaseio.com/")
    
    //
    init(context:NSManagedObjectContext){
        self.context = context
    }
    func hasAuth()->Bool {
        //get value back for user authorized
    return rootRef.authData != nil
    }
    //local storage of phonenumber
    private(set) static var currentPhoneNumber:String? {
        set(phoneNumber) {
            NSUserDefaults.standardUserDefaults().setObject(phoneNumber, forKey: "phoneNumber")
        }       get{
            return NSUserDefaults.standardUserDefaults().objectForKey("phoneNumber") as? String
        }
    }
    //upload core data to firebase
    private func upload(model:NSManagedObject){
        guard let model = model as? FirebaseModel else {return}
        model.upload(rootRef, context: context)
    }
    
    private func listenForNewMessages(chat:Chat) {
        chat.observeMessages(rootRef, context: context)
    }


//get all of the contacts from core data
private func fetchAppContacts()->[Contact] {
    do {
        let request = NSFetchRequest(entityName: "Contact")
        request.predicate = NSPredicate(format: "storageId != nil")
        if let results = try self.context.executeFetchRequest(request) as? [Contact]
        {
            return results
        }
    } catch {print("Error fetching Contacts")}
    return []
}
    
    private func observeUserStatus(contact:Contact){
        contact.observeStatus(rootRef, context: context)
    }

    private func observeStatuses(){
        let contacts = fetchAppContacts()
        contacts.forEach(observeUserStatus)
    }
    
    //monitor our Chats so we can be alerted by Firebase when new Chats are being creatd
    private func observeChats() {
        self.rootRef.childByAppendingPath("users/"+self.rootRef.authData.uid+"/chats").observeEventType(.ChildAdded, withBlock: { snapshot in
            let uid = snapshot.key
            let chat = Chat.existing(storageId: uid, inContext: self.context) ?? Chat.new(forStorageId: uid, rootRef: self.rootRef, inContext: self.context)
            if chat.inserted{
                do{
                    try self.context.save()
                }catch{}
            }
            self.listenForNewMessages(chat)

        })
    }
}
//extention that will use the remotestore file to at start
extension FirebaseStore:RemoteStore{
    func startSyncing() {
        
        context.performBlock{self.observeStatuses()
        }
        
    }
    //confirm to remote store
    func store(inserted inserted: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject]) {
        
        inserted.forEach(upload)
        do {
            try context.save()
        } catch {
            print("error Saving")
        }
    
        }
    func signUp(phoneNumber phoneNumber: String, email: String, password: String, success: () -> (), error errorCallback: (errorMessage: String) -> ()) {
        //singup code
        rootRef.createUser(email, password: password, withValueCompletionBlock: {
            error, result in if error != nil {
                errorCallback(errorMessage: error.description)
            }
            else {
                //key value pair dictionary
                let newUser = ["phoneNumber": phoneNumber]
                FirebaseStore.currentPhoneNumber = phoneNumber
                //unique id
                let uid = result["uid"] as! String
                //storing users -> unique id -> new users dictionary
                self.rootRef.childByAppendingPath("users").childByAppendingPath(uid).setValue(newUser)
              
                //authorize a user
                self.rootRef.authUser(email, password: password, withCompletionBlock: { error, authData in
                    if error != nil {
                        errorCallback(errorMessage: error.description)}
                    else {
                        success()
                    }
                    })
            } }) } }

    
    
    
    
    
    

