//
//  Syncer.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/13/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import UIKit
import CoreData

//keeps main and background in sync :)


class Syncer: NSObject {
   //atributes
    private var mainContext:NSManagedObjectContext
    private var backgroundContext:NSManagedObjectContext
    
    //remote store
    var remoteStore:RemoteStore?
    
    init(mainContext:NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.mainContext = mainContext
        self.backgroundContext = backgroundContext
        super.init()
        
        
        //notifactions for when saves
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("mainContextSaved:"), name: NSManagedObjectContextDidSaveNotification, object: mainContext)
        //background notifaction
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("backgroundContextSaved:"), name: NSManagedObjectContextDidSaveNotification, object: backgroundContext)
    }
    //corresponding method for contact saved.   If changes merge!!
    func mainContextSaved(notification: NSNotification) {
        backgroundContext.performBlock({
            let inserted = self.objectsForKey(NSInsertedObjectsKey, dictionary: notification.userInfo!, context: self.backgroundContext)
            let updated = self.objectsForKey(NSUpdatedObjectsKey, dictionary: notification.userInfo!, context: self.backgroundContext)
            let deleted = self.objectsForKey(NSDeletedObjectsKey, dictionary: notification.userInfo!, context: self.backgroundContext)
            
            self.backgroundContext.mergeChangesFromContextDidSaveNotification(notification)
            
            //sotre method that usesd the above checks, all may be nil but 1 may have value
            self.remoteStore?.store(inserted: inserted, updated:updated, deleted:deleted)

        })
    }
    func backgroundContextSaved(notification: NSNotification) {
        mainContext.performBlock({
           //get full object not just the ponter
            self.objectsForKey(NSUpdatedObjectsKey, dictionary: notification.userInfo!, context: self.mainContext).forEach{$0.willAccessValueForKey(nil)}
            self.mainContext.mergeChangesFromContextDidSaveNotification(notification)
            
        })
    }
    
    //we will add a method to return the objects for the notification dictionary
    private func objectsForKey(key:String,dictionary:NSDictionary, context:NSManagedObjectContext)->[NSManagedObject]
    
    {
        guard let set = (dictionary[key] as? NSSet) else {return []}
        guard let objects = set.allObjects as? [NSManagedObject] else {return []}
        //%0 is placeholder
        return objects.map{context.objectWithID($0.objectID)}
    }
    
    
}
