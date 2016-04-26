//
//  newgame.swift
//  NanChat
//
//  Created by George Fitzgibbons on 2/24/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

//import Foundation
//import CoreData
//extension NSManagedObjectContext {
//    
//    convenience init(parentContext parent: NSManagedObjectContext, concurrencyType: NSManagedObjectContextConcurrencyType) {
//        self.init(concurrencyType: concurrencyType)
//        parentContext = parent
//    }
//    
//    func deleteAllObjects(error: NSErrorPointer) {
//        
//        if let entitesByName = persistentStoreCoordinator?.managedObjectModel.entitiesByName as? [String: NSEntityDescription] {
//            
//            for (name, entityDescription) in entitesByName {
//                deleteAllObjectsForEntity(entityDescription, error: error)
//                
//                // If there's a problem, bail on the whole operation.
//                if error.memory != nil {
//                    return
//                }
//            }
//        }
//    }
//    
//    func deleteAllObjectsForEntity(entity: NSEntityDescription, error: NSErrorPointer) {
//        let fetchRequest = NSFetchRequest()
//        fetchRequest.entity = entity
//        fetchRequest.fetchBatchSize = 50
//        
//        let fetchResults = executeFetchRequest(fetchRequest, error: error)
//        
//        if error.memory != nil {
//            return
//        }
//        
//        if let managedObjects = fetchResults as? [NSManagedObject] {
//            for object in managedObjects {
//                deleteObject(object)
//            }
//        }
//    }
//    
//}