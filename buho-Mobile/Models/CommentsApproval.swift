//
//  CommentsApproval.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/15/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import Foundation
import Parse

class CommentsApproval: PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "CommentsApproval"
    }
    
    init(Comment: String, ContactId: Contact, contract: Contract, mItem: MeetingItem) {
        super.init()
        self.Comment = Comment
        self.ContactId = ContactId
        self.ContractId = contract
        self.MeetingItemId = mItem
        Approved = 0
    }
    
    //atributos:
    @NSManaged var Comment: String
    @NSManaged var Approved: Int
    @NSManaged var ContactId: Contact
    @NSManaged var ContractId: Contract
    @NSManaged var MeetingItemId: MeetingItem
    
}

enum ApprovedCommentType: Int {
    case Rechazado = -1
    case PorAprobar = 0
    case Aprobado = 1
}