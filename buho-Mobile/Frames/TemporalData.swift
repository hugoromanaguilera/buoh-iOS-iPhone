//
//  TemporalData.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/14/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import Foundation

class TemporalData {
    
    private var _compromisos: [MeetingItem]?
    private var _actividad: MeetingItem? = nil
    
    // singleton
    class var sharedInstance : TemporalData {
        struct Static {
            static let instance : TemporalData = TemporalData()
        }
        
        return Static.instance
    }
    
    init(){
        _compromisos = []
    }
    
    var compromisos: [MeetingItem]? {
        get{
            return _compromisos
        }
        set(newCompromisos){
            _compromisos = newCompromisos
        }
    }
    
    var actividad: MeetingItem? {
        get{
            return _actividad
        }
        set{
            _actividad = newValue
//            if let _act = _actividad {
//                _act.fetchContacts()
//            }
        }
    }
    
}