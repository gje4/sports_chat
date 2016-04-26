//
//  ContactImporter.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/5/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import Foundation
import CoreData
import Contacts





//class to be used in other files
class ContactImporter: NSObject {
    //context to save contacts to core data
    private var  context: NSManagedObjectContext
    
    //fix the bug of repedeted checks for contact changes
    private var lastCNNotificationTime:NSDate?

    
    //initilize the contex
    init(context:NSManagedObjectContext){
        
        self.context = context
    }
    //opt in and opt out
    func listenForChanges() {
        CNContactStore.authorizationStatusForEntityType(.Contacts)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addressBookDidChange:", name: CNContactStoreDidChangeNotification, object: nil)
    }
    
    func addressBookDidChange(notification: NSNotification){
        let now = NSDate()
        guard lastCNNotificationTime == nil || now.timeIntervalSinceDate(lastCNNotificationTime!) > 1 else {return}
        lastCNNotificationTime = now
//        print(notification)
        fetch()

    }
    
    //helper function to transform CNPhoneNumber instance into a string
    func formatPhoneNumber(number:CNPhoneNumber) -> String {
        //clean up spaces
        return number.stringValue.stringByReplacingOccurrencesOfString(" ", withString: " ")
            //clean up
            .stringByReplacingOccurrencesOfString("-", withString: "")
            .stringByReplacingOccurrencesOfString("(", withString: "")
            .stringByReplacingOccurrencesOfString(")", withString: "")
    }
    //grab numbers already used
    private func fetchExisting() -> (contacts: [String: Contact], PhoneNumbers: [String: PhoneNumber])
    {
        var contacts = [String: Contact]()
        var phoneNumbers = [String: PhoneNumber]()
        do {
            let request = NSFetchRequest(entityName: "Contact")
            //getting relatead data from 2 different entity in core data
            request.relationshipKeyPathsForPrefetching = ["phoneNumbers"]
            if let contactResult = try self.context.executeFetchRequest(request) as?
                [Contact] {
                    for contact in contactResult {
                        contacts[contact.contactId!] = contact
                        for phoneNumber in contact.phoneNumbers!
                        {
                            phoneNumbers[phoneNumber.value] = phoneNumber as? PhoneNumber
                        }
                    }
            }
        }catch {
            print("error")
        }
        return(contacts, phoneNumbers)
        
        
    }
    
//this is a helper function to get contact from phone
func fetch() {
    //creat an instance
    let store = CNContactStore()
    //what we want to get back
    store.requestAccessForEntityType(.Contacts, completionHandler: {
        //granted is a check to see if the usr gives us acess.  gotten from app delagte
        granted, error in
        self.context.performBlock {
            if granted{
                do{
                    //see if we have contacts already
                    //deconstruting a touple using a constant
                    let (contacts, phoneNumbers) = self.fetchExisting()
                    
                    
                    //information we are asking for
                    let req = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey])
                    //print out the contact
                    try store.enumerateContactsWithFetchRequest(req, usingBlock: {
                        cnContact, stop in
                        //store in contact instance based on cnContaxt we got make
                        guard let contact = contacts[cnContact.identifier] ??  NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: self.context) as? Contact else
                            //if can not do return out
                        {return}
                        //store information
                        contact.firstName = cnContact.givenName
                        contact.lastName = cnContact.familyName
                        contact.contactId = cnContact.identifier
                        
                        //get phone numbers and format using format function return to core data contact.phoneNumbers  to be used anywhere
                        for cnVal in cnContact.phoneNumbers{
                            guard let cnPhoneNumber = cnVal.value as? CNPhoneNumber else {continue}
                            guard let phoneNumber =  phoneNumbers[cnPhoneNumber.stringValue] ?? NSEntityDescription.insertNewObjectForEntityForName("PhoneNumber", inManagedObjectContext: self.context) as? PhoneNumber else {continue}
                           
                            //change to string
                            phoneNumber.kind = CNLabeledValue.localizedStringForLabel(cnVal.label)
                            //format return
                            phoneNumber.value = self.formatPhoneNumber(cnPhoneNumber)
                            //add
                            phoneNumber.contact = contact
                            
                            //add contact to favorite by defualt
                            if contact.inserted{
                                contact.favorite = true
                            }
                        }
                    })
                    try self.context.save()
                }catch let error as NSError {
                    print(error)
                }catch {
                    print("error with do catch")
                }
            }

            
        }
            })
}
    

        
    }
