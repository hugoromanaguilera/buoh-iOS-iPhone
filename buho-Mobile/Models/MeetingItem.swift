//
//  MeetingItem.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/9/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import Foundation
import Parse

class MeetingItem : PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "MeetingItem"
    }
    
    //atributos:
    @NSManaged var ContractId : Contract
    @NSManaged var Type : Code
    @NSManaged var State : Code
    @NSManaged var Detail : String
    @NSManaged var DateItem : NSDate
    @NSManaged var DueDate : NSDate
    @NSManaged var ResponsibilityDescription : String
    @NSManaged var Responsibilities : [Responsibility]
    @NSManaged var Comments : [String]
    
    
    ///retorna un String con los nombres de los responsables del respectivo meetingItem.
    func getResponsibilitiesNames() -> String {
        var nombres :  String = ""
        
        if !self.Responsibilities.isEmpty {
            
            for responsibility in Responsibilities {
                do {
                    try responsibility.ContactId!.fetchIfNeeded()
                } catch _ {
                    print("in MeetingItem fetchResponsibilitiesFromParse > Hubo un error al realizar el fetch de los responsables.")
                }
                let contact = responsibility.ContactId
                nombres += " \(contact!.Name) \(contact!.LastName)."
            }
        }
        
        return nombres
    }
    
    ///chequea si alguno de los "Responsibility" creados ya existe en la tabla "Responsibility". Si existe, lo actualiza; si no, lo crea.
    func checkResponsibility(){
        //1)para cada responsibility dentro del meetingItem, chequear si ya existe en la tabla "Responsibility". Para no generar duplicados.
        for responsibility in Responsibilities {
            let query = PFQuery(className: "Responsibility")//Responsibility.query()!
            query.whereKey("ContactId", equalTo: responsibility.ContactId!)
            query.whereKey("RolTarea", equalTo: responsibility.RolTarea!)
            
            query.getFirstObjectInBackgroundWithBlock({
                ( object : PFObject?, error : NSError?) -> Void in
                if object != nil {
                    responsibility.objectId = object!.objectId!
                }else{
                    print("In MeetingItem: error al realizar la query en preparar. \(error)")
                }
            })
            
            
        }
    }
    
    ///completa la información que falta desde parse.
    func fetchResponsibilitiesFromParse() {
        for responsibility in self.Responsibilities {
            responsibility.fetchInBackground()
        }
    }
}