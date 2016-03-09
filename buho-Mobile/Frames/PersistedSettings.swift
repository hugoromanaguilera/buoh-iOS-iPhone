//
//  PersistedSettings.swift
//  BeepIn
//
//  Created by Carlos Orrego on 9/23/14.
//  Copyright (c) 2014 Carlos Orrego. All rights reserved.
//

import Foundation

class PersistedSettings{
    
    //for remember data login (NSUserDefaults):
    private let userKey = "username"
    private let passKey = "password"
    private var _user : String?
    private var _password : String?
    private var defaults : NSUserDefaults = NSUserDefaults()
    
    
    
    var usuario : String? {
        get{
            return _user
        }
        set(newUser){
            _user = newUser
            defaults.setObject(newUser, forKey: userKey)
            //            defaults.synchronize()
        }
    }
    
    var password : String?{
        get{
            return _password
        }
        set(newPass){
            _password = newPass
            defaults.setObject(newPass, forKey: passKey)
            //            defaults.synchronize()
        }
    }
    
    // singleton
    class var sharedInstance : PersistedSettings {
        struct Static {
            static let instance : PersistedSettings = PersistedSettings()
        }
        
        return Static.instance
    }
    
    
    init(){
        //remember data:
        defaults = NSUserDefaults.standardUserDefaults()
        _user = defaults.objectForKey(userKey) as? String
        _password = defaults.objectForKey(passKey) as? String
    }
}