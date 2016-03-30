//
//  TemporalData.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/14/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import Foundation

class TemporalData {
    
    private var _comentariosAprobados: [CommentsApproval]
    private var _compromisos: [MeetingItem]
    private var _actividad: MeetingItem? = nil
    private var _contacto: Contact? = nil
    private var _contrato: Contract? = nil
    private var _contratos: [Contract]
    private var _dicContratos: [String: [Contract] ]
    
    // singleton
    class var sharedInstance : TemporalData {
        struct Static {
            static let instance : TemporalData = TemporalData()
        }
        
        return Static.instance
    }
    
    init(){
        _compromisos = []
        _comentariosAprobados = []
        _contratos = []
        _dicContratos = [:]
    }
    
    var comentariosAprobados: [CommentsApproval] {
        get {
            return _comentariosAprobados
        }
        set {
            _comentariosAprobados = newValue
        }
    }
    var compromisos: [MeetingItem] {
        get{
            return _compromisos
        }
        set(newCompromisos){
            _compromisos.removeAll(keepCapacity: false)
            _compromisos = newCompromisos
        }
    }
    
    var actividad: MeetingItem? {
        get{
            return _actividad
        }
        set{
            _actividad = newValue
        }
    }
    
    var contacto: Contact? {
        get {
            return _contacto
        }
        set {
            _contacto = newValue
        }
    }
    
    var contrato: Contract? {
        get{
            return _contrato
        }
        set{
           _contrato = newValue
        }
    }
    
    var contratos: [Contract] {
        get {
            return _contratos
        }
        set {
            _contratos.removeAll(keepCapacity: false)
            _contratos = newValue
        }
    }
    
    var dicContratos: [String: [Contract] ] {
        get {
            return _dicContratos
        }
        set {
            _dicContratos.removeAll(keepCapacity: false)
            _dicContratos = newValue
        }
    }
    
}