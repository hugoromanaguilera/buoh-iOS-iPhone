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
    
    init(ForeignObjectId: String, Comment: String) {
        super.init()
        self.ForeignObjectId = ForeignObjectId
        self.Comment = Comment
        Approved = false
    }
    
    //atributos:
    @NSManaged var ForeignObjectId: String
    @NSManaged var Comment: String
    @NSManaged var Approved: Bool
    
}