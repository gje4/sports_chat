//
//  Contact.swift
//  
//
//  Created by George Fitzgibbons on 3/21/16.
//
//

import Foundation
import CoreData


class Contact: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
//sort
    var sortLetter: String {
        let letter = lastName?.chatacters.first ?? firstName?.chatacters.first
        let s = String(letter!)
        return s 
    }
    
    
}
