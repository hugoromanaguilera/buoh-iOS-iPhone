//
//  ParseConnection.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/7/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import Foundation
import Parse

class ParseConnection {
    
    //singleton:
    class var sharedInstance : ParseConnection {
        struct Static {
            static let instance : ParseConnection = ParseConnection()
        }
        return Static.instance
    }
    
    //MARK: - Utilizada en LoginViewController:
    //2)In LoginViewController: Si está en AD, busca el contacto en Parse con email: contactDictionary["Email"]!
    /**
    Luego de verificar si el usuario pertenece al AD, obtiene el user desde Parse a partir de su email.
    - Parameters:
    - email: el email mediante el cual se buscara el usuario.
    - postCompleted: es el callback.
    - returns: en el callback, se returna true si es que se encuentra en Parse, además de los datos del contacto. En caso contrario, retorna false.
    */
    func getContactByEmail(email: String,
        completionHandler : (succeded: Bool, error: Bool, msg: String, contact : Contact?) -> () ){
            
            let query = PFQuery(className: "Contact")
            query.whereKey("Email", equalTo: email)
            query.getFirstObjectInBackgroundWithBlock({
                (contactObj : PFObject?, error : NSError?) -> Void in
                guard error == nil else {
                    completionHandler(succeded: false, error: true, msg: "No se encontró usuario en Parse", contact: nil)
                    return
                }
                guard let cont = contactObj else {
                    completionHandler(succeded: false, error: true, msg: "No se encontró usuario en Parse", contact: nil)
                    return
                }
                let contactParse = cont as! Contact
                completionHandler(succeded: true, error: false, msg: "Login exitoso.", contact: contactParse)
                return
            })
    }
    
    //3) verifica si tiene permisos de PMO
    /**
    Verifica si el usuario posee permisos de supervisor para acceder a la aplicación (PMO).
    
    - parameter contact: el contacto del que se desea saber sus roles.
    - returns: si posee los permisos de PMO, accede a la aplicación. Un mensaje de error
    saldrá si no posee los permisos suficientes.
    */
    func contactsWithPmoRole(contact : Contact, completionHandler : (succeded: Bool, error : Bool, msg : String) -> ()){
        
        let query1 = PFQuery(className: "RolesContact")
        query1.whereKey("Contactos", equalTo: contact)
        query1.whereKey("Name", equalTo: "PMO")
        query1.findObjectsInBackgroundWithBlock {
            ( rolesContactObjs : [PFObject]?, error : NSError?) -> Void in
            guard error == nil else {
                completionHandler(succeded: false, error: true, msg: "\(error!.code): Error al obtener los roles. \(error!)")
                return
            }
            if (rolesContactObjs != nil){
                if rolesContactObjs!.isEmpty {
                    completionHandler(succeded: false, error: false, msg: "No posee los permisos suficientes para hacer uso de la aplicación")
                }else{
                    completionHandler(succeded: true, error: false, msg: "")
                }
            }
        }
    }
    
    
    //MARK: Utilizada en ContractViewController:
    /**
    Obtiene los contratos de parse a partir de un contacto.
    
    - parameter contact: el contacto del que se desea saber sus contratos asociados.
    - returns: un `callback` con un diccionario que posee los contratos asociados (en caso de que existan).
    */
    func getContractsForContact(contact: Contact, completionHandler : (succeded: Bool, error: NSError?, data : NSDictionary?) -> () ){
        var arrayCompanies : [String] = []
        var arrayContracts : [Contract] = []
        var dictionaryContracts : [String:[Contract]] = [:]
        var data : [String: AnyObject] = [:]
        
        let query1 = Resource.query()!
        query1.whereKey("ContactId", equalTo: contact)
        query1.includeKey("ContractId")
        
        query1.findObjectsInBackgroundWithBlock {
            (resourceObjs:[PFObject]?, error: NSError?) -> Void in
            guard error == nil else {
                completionHandler(succeded: false, error: error, data: nil)
                return
            }
            
            guard resourceObjs != nil &&
                resourceObjs!.count != 0 else{
                    completionHandler(succeded: false, error: nil, data: nil)
                    return
            }
            if let resources = resourceObjs as? [Resource]{
                for resource in resources{
                    arrayContracts.append(resource.ContractId)
                }
                
                //bloque para crear las secciones...
                for contract in arrayContracts{
                    if dictionaryContracts[contract.CompanyName] == nil {
                        dictionaryContracts[contract.CompanyName] = []
                    }
                    dictionaryContracts[contract.CompanyName]!.append(contract)
                }
                
                for companyName in dictionaryContracts.keys {
                    var contratos = dictionaryContracts[companyName]!
                    
                    //ordena los contratos por nombre.
                    contratos.sortInPlace({
                        (contrato1: Contract, contrato2: Contract) -> Bool in
                        return contrato1.Name < contrato2.Name
                    })
                    
                    dictionaryContracts[companyName] = contratos
                }
                arrayCompanies = [String] (dictionaryContracts.keys)
                //ordena compañias por nombre.
                arrayCompanies.sortInPlace({
                    (com1: String, com2: String) -> Bool in
                    return com1 < com2
                })
                
                data["companies"] = arrayCompanies
                data["contracts"] = arrayContracts
                data["dictionary"] = dictionaryContracts
                completionHandler(succeded: true, error: nil, data: data)
            }
            else{
                completionHandler(succeded: false, error: nil, data: nil)
            }
            
        }
    }
    
    
    
    
    ///Obtiene los códigos generales, tales como
    func loadCodes(){
        
        let query = Code.query()!
        query.includeKey("CodeType")
        query.findObjectsInBackgroundWithBlock {
            (codeObjects:[PFObject]?, error: NSError?) -> Void in
            guard error == nil else {
                print("En ParseConnection: error al obtener los códigos.")
                print(error)
                return
            }
            if let codes = codeObjects as? [Code] {
                
                for code in codes {
                    let nombreCodigo = code.CodeType.Name
                    let index = code.Index
                    switch nombreCodigo{
                    case kTypeCodeAnimo:
                        arrayAnimos[code.objectId!] = code.Name
                        arrayAnimos["\(index)"] = code.objectId!
                    case kTypeCodeItemType:
                        arrayTypes[code.objectId!] = code.Name
                        arrayTypes["\(index)"] = code.objectId!
                    case kTypeCodeItemState:
                        arrayStates[code.objectId!] = code.Name
                    case kTypeCodeRol:
                        arrayRaci[code.objectId!] = code.Name
                    default:
                        print("")
                    }
                    arrayCodes.append(code)
                    
                }
                arrayAnimosKey = [String](arrayAnimos.keys)
                arrayAnimosValues = [String](arrayAnimos.values)
                
                arrayStatesKey = [String](arrayStates.keys)
                arrayStatesValues = [String](arrayStates.values)
                
                arrayRaciKey = [String](arrayRaci.keys)
                arrayRaciValues = [String](arrayRaci.values)
            }
            
        }
    }
    
    /*
     Obtiene las reuniones asociadas a un contrato.
     - parameter contract: el contrato del que se desea saber sus reuniones.
     - returns: un `callback` con un array de reuniones (en caso de que existan).
     */
//    func getMeetingsByContract(contract : Contract, completionHandler : (succeded: Bool, error : NSError?, data : [Meeting]) -> ()){
//        var arrayMeetings : [Meeting] = []
//        
//        let query = Meeting.query()!
//        query.includeKey("Mood")
//        query.whereKey("ContractId", equalTo: contract)
//        query.findObjectsInBackgroundWithBlock {
//            (meetingObjects:[PFObject]?, error: NSError?) -> Void in
//            guard error == nil else {
//                completionHandler(succeded: false, error: error, data: arrayMeetings)
//                print("en ParseConnection -> loadMeetings: \(error)")
//                return
//            }
//            if let meetings = meetingObjects as? [Meeting] {
//                arrayMeetings += meetings
//                arrayMeetings.sortInPlace({ $0.Date.compare($1.Date) == NSComparisonResult.OrderedDescending  })
//                completionHandler(succeded: true, error: nil, data: arrayMeetings)
//            }
//        }
//    }//end loadMeetings.
    
    /**
    Obtiene los contactos asociadas a un contrato.
    - parameter contract: el contrato del que se desea saber sus reuniones.
    - returns: un `callback` con un array de reuniones (en caso de que existan).
    */
    func getContactsByContract(contract : Contract, completionHandler : (succeded : Bool, error : NSError?, data : [Contact]) -> ()){
        var arrayContacts : [Contact] = []
        let query = Resource.query()!
        
        query.includeKey("ContactId")
        query.whereKey("ContractId", equalTo: contract)
        query.findObjectsInBackgroundWithBlock {
            (resourceObjects: [PFObject]?, error: NSError?) -> Void in
            guard error == nil else {
                print("In ParseConnection -> getContactsByContract: \(error)")
                return
            }
            if let resources = resourceObjects as? [Resource]{
                
                for resource in resources {
                    arrayContacts.append(resource.ContactId)
                }
                
                //ordena los contactos por nombre.
                arrayContacts.sortInPlace({ (contact1: Contact, contact2: Contact) -> Bool in
                    return "\(contact1.Name) \(contact1.LastName)" < "\(contact2.Name) \(contact2.LastName)"
                })
                
                completionHandler(succeded: true, error: nil, data: arrayContacts)
                
                
            }
            
            
        }
    }
    
    
//    func getContractsByContact(contact: Contact, completionHandler : (succeded: Bool, error: NSError?, data : NSDictionary?) -> () ){
//        var arrayCompanies : [Company] = []
//        var arrayContracts : [Contract] = []
//        var dictionaryContracts : [String:[Contract]] = [:]
//        var data : [String: AnyObject] = [:]
//        
//        let query = Contract.query()!
//        query.includeKey("CompanyId")
//        query.whereKey("ManagerContactId", equalTo: contact)
//        query.findObjectsInBackgroundWithBlock {
//            (contractsObjects:[PFObject]?, error: NSError?) -> Void in
//            guard error == nil else {
//                completionHandler(succeded: false, error: error, data: nil)
//                return
//            }
//            if let contracts = contractsObjects as? [Contract] {
//                arrayContracts += contracts
//                
//                //bloque para crear las secciones...
//                for contract in arrayContracts{
//                    if !arrayCompanies.contains(contract.CompanyId) {
//                        arrayCompanies.append(contract.CompanyId)
//                        dictionaryContracts[contract.CompanyId.Name] = []
//                    }
//                    dictionaryContracts[contract.CompanyId.Name]!.append(contract)
//                }
//                
//                //ordena compañias por nombre.
//                arrayCompanies.sortInPlace({
//                    (com1 : Company, com2 : Company) -> Bool in
//                    return com1.Name < com2.Name
//                })
//                
//                //ordena los contratos por nombre.
//                arrayContracts.sortInPlace({
//                    (contrato1: Contract, contrato2: Contract) -> Bool in
//                    return contrato1.Name < contrato2.Name
//                })
//                
//                for companyName in dictionaryContracts.keys {
//                    var contratos = dictionaryContracts[companyName]!
//                    
//                    //ordena los contratos por nombre.
//                    contratos.sortInPlace({
//                        (contrato1: Contract, contrato2: Contract) -> Bool in
//                        return contrato1.Name < contrato2.Name
//                    })
//                    
//                    dictionaryContracts[companyName] = contratos
//                }
//                
//                data["companies"] = arrayCompanies
//                data["contracts"] = arrayContracts
//                data["dictionary"] = dictionaryContracts
//                completionHandler(succeded: true, error: nil, data: data)
//            }
//            else{
//                completionHandler(succeded: false, error: nil, data: nil)
//            }
//        }
//    }
    
    /**
     Obtiene los participantes de una reunión.
     - parameter meeting: la reunión de la que se desea saber sus participantes.
     - returns: un `callback` con un array de participantes (en caso de que existan).
     */
//    func getParticipantsBy(meeting : Meeting, completionHandler : (succeded : Bool, error : NSError?, data : [Participant]) -> ()){
//        var arrayParticipantes : [Participant] = []
//        let query = PFQuery(className: "Participant")
//        query.includeKey("ContactId")
//        query.whereKey("MeetingId", equalTo: meeting)
//        query.findObjectsInBackgroundWithBlock({
//            (participantObjects : [PFObject]?, error : NSError?) -> Void in
//            guard error == nil else {
//                print("in NuevaReunion > loadParticipants: Hubo un error al buscar los participantes.")
//                return
//            }
//            
//            if let participants = participantObjects as? [Participant]{
//                arrayParticipantes = participants
//                arrayParticipantes.sortInPlace { (participante1: Participant, participante2: Participant) -> Bool in
//                    return "\(participante1.ContactId.Name) + \(participante1.ContactId.LastName)" < "\(participante2.ContactId.Name) + \(participante2.ContactId.LastName)"
//                }
//                
//                completionHandler(succeded: true, error: nil, data: arrayParticipantes)
//                
//            }
//            
//        })
//        
//    }
    
//    func getMeetingItemLogsBy(meeting : Meeting, completionHandler : (succeded : Bool, error : NSError?, data : [String : [MeetingItemLog]]) -> () ){
//        
//        let kTypeCompromiso = arrayCodes.getCodeByName(MeetingItemType.Compromisos.rawValue)
//        let kTypeAcuerdos = arrayCodes.getCodeByName(MeetingItemType.Acuerdos.rawValue)
//        let kTypeInformacion = arrayCodes.getCodeByName(MeetingItemType.Info.rawValue)
//        
//        var arrayActivitiesLog : [MeetingItemLog] = []
//        var arrayTopicLog : [MeetingItemLog] = []
//        var arrayInfoLog : [MeetingItemLog] = []
//        var data : [ String : [MeetingItemLog] ] = [:]
//        
//        let query = MeetingItemLog.query()!
//        query.includeKey("Type")
//        query.includeKey("State")
//        query.whereKey("MeetingId", equalTo: meeting)
//        query.findObjectsInBackgroundWithBlock {
//            (meetingItemLogObjects : [PFObject]?, error: NSError?) -> Void in
//            guard error == nil else {
//                print("en ReunionesVC: \(error)")
//                return
//            }
//            if let meetingItemLogs = meetingItemLogObjects as? [MeetingItemLog] {
//                
//                for meetingItemLog in meetingItemLogs{
//                    let type = meetingItemLog.Type
//                    if type == kTypeCompromiso! {
//                        meetingItemLog.fetchResponsibilitiesFromParse()
//                        arrayActivitiesLog.append(meetingItemLog)
//                    }
//                    else if type == kTypeAcuerdos! {
//                        arrayTopicLog.append(meetingItemLog)
//                    }
//                    else if type == kTypeInformacion! {
//                        arrayInfoLog.append(meetingItemLog)
//                    }
//                }
//                
//                arrayActivitiesLog.sortInPlace({ $0.DueDate.compare($1.DueDate) == NSComparisonResult.OrderedAscending })
//                
//                data[MeetingItemType.Compromisos.rawValue] = arrayActivitiesLog
//                data[MeetingItemType.Acuerdos.rawValue] = arrayTopicLog
//                data[MeetingItemType.Info.rawValue] = arrayInfoLog
//                completionHandler(succeded: true, error: nil, data: data)
//            }
//            
//        }
//        
//    }
    
    ///Obtiene los recursos asociados al contrato (contactos)
//    func getResourcesBy(contract : Contract, completionHandler : (succeded : Bool, error : NSError?, data : [String : AnyObject] ) -> () ){
//        var arrayResources : [Resource] = []
//        var arrayParticipantes : [Participant] = []
//        var arrayContacts : [Contact] = []
//        var data : [String : AnyObject ] = [:]
//        
//        let query = Resource.query()!
//        query.whereKey("ContractId", equalTo: contract)
//        query.includeKey("ContactId")
//        query.findObjectsInBackgroundWithBlock {
//            (resourceObjects: [PFObject]?, error: NSError?) -> Void in
//            guard error == nil else {
//                print("en ParseConnection -> getResourcesBy: \(error)")
//                return
//            }
//            if let resources = resourceObjects as? [Resource]{
//                arrayResources = resources
//                
//                for resource in arrayResources {
//                    if resource.Participa {
//                        let participant = Participant()
//                        participant.ContactId = resource.ContactId
//                        participant.Mood = arrayCodes.getCodeById("jqathuiMXY")!
//                        arrayParticipantes.append(participant)
//                    }
//                    arrayContacts.append(resource.ContactId)
//                }
//                //ordena los contactos por nombre.
//                arrayContacts.sortInPlace({ (contact1: Contact, contact2: Contact) -> Bool in
//                    return "\(contact1.Name) \(contact1.LastName)" < "\(contact2.Name) \(contact2.LastName)"
//                })
//                //ordena los participantes por nombre.
//                arrayParticipantes.sortInPlace({
//                    (p1: Participant, p2: Participant) -> Bool in
//                    return "\(p1.ContactId.Name) +\(p1.ContactId.LastName)" < "\(p2.ContactId.Name) +\(p2.ContactId.LastName)"
//                })
//                
//                data[typeOfArray.Recursos.rawValue] = arrayResources
//                data[typeOfArray.Participantes.rawValue] = arrayParticipantes
//                data[typeOfArray.Contactos.rawValue] = arrayContacts
//                
//                completionHandler(succeded: true, error: nil, data: data )
//            }
//        }
//    }
    
    
    
}

//MARK: variables globales:
let kTypeCodeAnimo = "animoReunion"
let kTypeCodeRol = "RolTarea"
let kTypeCodeItemState = "MeetingItemState"
let kTypeCodeItemType = "MeetingItemType"

//tipos de meetingItems:
let kItemTypeCompromiso = "Compromiso"
let kItemTypeAcuerdo = "Acuerdo"
let kItemTypeInformacion = "Información"

//let kMeetingItemType

enum typeOfArray : String {
    case Asunto = "Asunto", Participantes = "Participants", Contactos = "Contacts", Recursos = "Resources"
    
}

enum MeetingItemType : String {
    case Compromisos = "Compromisos", Acuerdos = "Acuerdos", Info = "Info"
    
    static let allValues = [Compromisos, Acuerdos, Info]
}

enum MeetingItemState : String {
    case Ejecucion = "En Ejecución", Cancelado = "Cancelado", Terminado = "Terminado"
    
    static let allValues = [Ejecucion, Cancelado, Terminado]
}

enum AnimoReunion : String {
    case Bueno = "Bueno", Regular = "Regular", Malo = "Malo"
    
    static let allValues = [Bueno, Regular, Malo]
}


//Codigos básicos cargados al comienzo de la app
//Codigos:
var arrayCodes : [Code] = []
//animos
var arrayAnimos: [String : String] = [:]
var arrayAnimosKey:[String] = []
var arrayAnimosValues:[String] = []
//estados
var arrayStates: [String : String] = [:]
var arrayStatesKey:[String] = []
var arrayStatesValues:[String] = []
//tipos
var arrayTypes: [String : String] = [:]
// RACI = Responsable; A Aprobador; Consultado; Informado
var arrayRaci : [ String : String ] = [:]
var arrayRaciKey : [String] = []
var arrayRaciValues : [String] = []