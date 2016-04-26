//
//  RemoteStore.swift
//  NanChat
//
//  Created by George Fitzgibbons on 4/19/16.
//  Copyright © 2016 Nanigans. All rights reserved.
//

import Foundation
import CoreData


//protocal to save info for users
protocol RemoteStore{
    func signUp(phoneNumber phoneNumber:String, email:String, password:String,
        //no parameters and does not return anything
        success:() ->(),
        //parameter and erro meessage but does not return anything
        error:(errorMessage:String)->())
    
    
    //sycningc
    func startSyncing()
    
    //store in core data if can not connect to firebase
    func store(inserted inserted: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject])
    

}