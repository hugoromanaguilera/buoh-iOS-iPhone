//
//  Responsibility.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/9/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import Foundation
import Parse

class Responsibility : PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Responsibility"
    }
    
    //atributos:
    @NSManaged var ContactId : Contact?
    @NSManaged var RolTarea : Code?
    
    func getResponsibilityName() -> String {
        var nombre :  String = ""
        
        if let contact = self.ContactId,
            let rol = self.RolTarea {
                nombre += "\(contact.Name) \(contact.LastName)."
                nombre += " (\(rol.Name))"
        }
        
        return nombre
    }
}