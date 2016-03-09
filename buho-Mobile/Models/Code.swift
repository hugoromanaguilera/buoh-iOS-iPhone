//
//  Code.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/7/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import Foundation
import Parse

class Code : PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Code"
    }
    
    //atributos:
    @NSManaged var Name: String
    @NSManaged var CodeType: TypeCode
    @NSManaged var Orden: Int
    @NSManaged var Index: Int
    
}