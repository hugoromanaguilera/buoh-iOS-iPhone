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
    
    var tmpData: TemporalData = TemporalData.sharedInstance
    
    //singleton:
    class var sharedInstance : ParseConnection {
        struct Static {
            static let instance : ParseConnection = ParseConnection()
        }
        return Static.instance
    }
    
    ///Es para el login a partir de la tabla "_User" de Parse.
    func loginInParse(userAndPass: [String: String], completion: (succeded: Bool, error: NSError?, user: PFUser?) -> ()){
        
        PFUser.logInWithUsernameInBackground(userAndPass["username"]!, password:userAndPass["password"]!) {
            (user: PFUser?, error: NSError?) -> Void in
            guard error == nil else{
                completion(succeded: false, error: error, user: nil)
                return
            }
            if let _ = user {
                completion(succeded: true, error: nil, user: user)
            }else{
                completion(succeded: false, error: nil, user: nil)
            }
        }
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
    
    ///obtiene todos los compromisos del contrato.
    func getActivitiesForContract(contract: Contract, completionHandler: (succeded: Bool, error: NSError?, data: [MeetingItem]?) -> ()){
        
        var data: [MeetingItem] = []
        
        let estado = arrayCodes.getCodeByName("En Ejecución")
        let tipo = arrayCodes.getCodeByName("Compromisos")
        
        let query = MeetingItem.query()!
        query.includeKey("Responsibilities")
        query.whereKey("ContractId", equalTo: contract)
        query.whereKey("State", equalTo: estado!)
        query.whereKey("Type", equalTo: tipo!)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            guard error == nil else {
                completionHandler(succeded: false, error: error, data: nil)
                return
            }
            if var activities = objects as? [MeetingItem]{
                if activities.count != 0 {
                    activities.sortInPlace({
                        $0.DueDate.isLessThanDate($1.DueDate)
                    })
//                    self.tmpData.compromisos = activities
                    
                    data = activities
                    
                    completionHandler(succeded: true, error: nil, data: data)
                }else{
                    completionHandler(succeded: false, error: nil, data: nil)
                }
                
            }else{
                completionHandler(succeded: false, error: nil, data: nil)
            }
        }
        
        
    }
    
    ///Obtiene los códigos generales, tales como
    func loadCodes(){
        
        let query = PFQuery(className: "Code")
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
    
    func saveAllInBackground(objects: [PFObject], completion: (succeded: Bool, error: NSError?) -> () ) {
        
        PFObject.saveAllInBackground(objects) { (succeded: Bool, error: NSError?) -> Void in
            guard error == nil else {
                completion(succeded: false, error: error)
                return
            }
            guard succeded else {
                completion(succeded: false, error: nil)
                return
            }
            completion(succeded: true, error: nil)
        }

    }
    
    
    func getResponsibilitiesByActivity(activity: MeetingItem) {
        
        
        let query1 = Responsibility.query()!
        query1.includeKey("ContactId")
        query1.includeKey("RolTarea")
        
        let query2 = MeetingItem.query()!
        query2.includeKey("ContractId")
        query2.includeKey("State")
        query2.includeKey("Type")
        query2.includeKey("ResponsibilityDescription")
        query2.includeKey("Responsibilities")
        query2.whereKey("objectId", equalTo: "")

        
        query2.whereKey("Responsibilities", matchesQuery: query1)
        query2.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            guard error == nil else {
                return
            }
            if let objects = objects as? [MeetingItem] {
                dump(objects)
            }
        }
        
    }
    
    func getCommentsApproval(meetingItem: MeetingItem, completion: (succeded: Bool, error: NSError?, comments: [CommentsApproval]?) -> () ) {
        
        let query = CommentsApproval.query()!
        query.whereKey("MeetingItemId", equalTo: meetingItem)
        query.whereKey("Approved", equalTo: 0)
        query.includeKey("ContactId")
        query.limit = 500
        query.findObjectsInBackgroundWithBlock { (object: [PFObject]?, error: NSError?) -> Void in
            guard error == nil else {
                completion(succeded: false, error: error, comments: nil)
                return
            }
            guard object != nil else {
                completion(succeded: false, error: nil, comments: nil)
                return
            }
            if let comments = object as? [CommentsApproval] {
                completion(succeded: true, error: nil, comments: comments)
            }
        }
        
        
    }

    
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
    case Compromisos = "Compromisos"
    case Acuerdos = "Acuerdos"
    case Info = "Info"
    
    static let allValues = [Compromisos, Acuerdos, Info]
}

enum MeetingItemState : String {
    case Ejecucion = "En Ejecución"
    case Cancelado = "Cancelado"
    case Terminado = "Terminado"
    
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