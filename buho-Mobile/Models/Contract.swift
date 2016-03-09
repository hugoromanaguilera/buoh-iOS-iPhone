//
//  Contract.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/7/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import Foundation
import Parse

class Contract : PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Contract"
    }
    
    //atributos:
    @NSManaged var Name: String
    @NSManaged var CompanyId: Company
    @NSManaged var ManagerContactId: Contact
    @NSManaged var CompanyName: String
    
    //    @NSManaged var fireProof: Boolean
    //    @NSManaged var rupees: Int
    //    @NSManaged var iconFile: PFFile
    //
    //    func iconView() -> UIImageView {
    //        let view = PFImageView(imageView: PlaceholderImage)
    //        view.file = iconFile
    //        view.loadInBackground()
    //        return view
    //    }
    
}