//
//  Contact.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/7/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import Foundation
import Parse

class Contact : PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Contact"
    }
    
    //atributos:
    @NSManaged var Name : String
    @NSManaged var LastName : String
    @NSManaged var Email : String
    @NSManaged var Organization : String
    @NSManaged var Address : String
    @NSManaged var Phone : String
    @NSManaged var Position : String
    
}