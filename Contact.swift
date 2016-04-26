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
        let letter = lastName?.characters.first ?? firstName?.characters.first
        let s = String(letter!)
        return s 
    }
    
    //return fullname
    var fullName: String {
        var fullName = ""
        if let firstName = firstName {
            fullName += firstName
        }
        if let lastName = lastName {
            if fullName.characters.count > 0 {
                fullName += lastName
            }
            fullName += lastName
        }
        return fullName
    }
}
