//
//  NetworkConnection.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/7/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import Foundation
class NetworkConnection : NSObject {
    
    // singleton
    class var sharedInstance : NetworkConnection {
        struct Static {
            static let instance : NetworkConnection = NetworkConnection()
        }
        
        return Static.instance
    }
    
    /**
     Envía, mediante metodo POST, el nombre de usuario y la pass para consultar si pertenece al Active Directory (AD).
     
     - Parameters:
     - params: el nombre de usuario y pass, con formato de diccionario ["username": user, "password":pass]
     - url: la url a la cual se enviará la consulta.
     - postCompleted: es el callback.
     - returns: en el callback, se returna true si es que pertenece al AD, además de los datos del contacto. En caso contrario, retorna false, sin los datos del contacto.
     */
    func postForContact(params : Dictionary<String, String>, url : String,
        postCompleted : (succeeded: Bool, msg: String, userAndPass : [String: String], contactDictionary : [String : String]) -> ()){
            
            var contact : [String : String] = [:]
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            
            let session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
            
            let task = session.dataTaskWithRequest(request) {
                (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
                
                guard data != nil else {
                    let mensaje = "No hubo respuesta del servidor"
                    postCompleted(succeeded: false, msg: mensaje, userAndPass: params, contactDictionary: contact)
                    //                dispatch_async(dispatch_get_main_queue()) {
                    //                    self.activityIndicator.stopAnimating()
                    //                    CommonHelpers.presentOneAlertController(self, alertTitle: "Error", alertMessage: "No hubo respuesta del servidor", myActionTitle: "OK", myActionStyle: .Default)
                    //                }
                    return
                }
                guard error == nil else{
                    let mensaje = "El servicio de autenticación no está operativo"
                    postCompleted(succeeded: false, msg: mensaje, userAndPass: params, contactDictionary: contact)
                    //                dispatch_async(dispatch_get_main_queue()) {
                    //                    self.activityIndicator.stopAnimating()
                    //                    CommonHelpers.presentOneAlertController(self, alertTitle: "Error", alertMessage: "El servicio de autenticación no está operativo", myActionTitle: "OK", myActionStyle: .Default)
                    //                }
                    return
                }
                
                var mensaje = "Login Inválido"
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                        
                        let success = json["ok"] as! Bool
                        if success {
                            let jsonContacto = json["contacto"] as! NSDictionary
                            contact = [
                                "Name": jsonContacto["nombre"] as! String,
                                "LastName": jsonContacto["apellidos"] as! String,
                                "Email": jsonContacto["correo"] as! String,
                                "Address": jsonContacto["direccion"] as! String,
                                "Position": jsonContacto["cargo"] as! String,
                                "Organization": jsonContacto["organizacion"] as! String
                            ]
                            mensaje = "Login con éxito"
                        }
                        print("success: \(success)")
                        postCompleted(succeeded: success, msg: mensaje, userAndPass: params, contactDictionary : contact)
                        return
                    } else {
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                        let mensaje = "Error could not parse JSON."
                        print("\(mensaje): \(jsonStr)" )
                        postCompleted(succeeded: false, msg: mensaje, userAndPass: params, contactDictionary: contact )
                        return
                    }
                } catch let parseError {
                    print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    let mensaje = "Error could not parse JSON."
                    print(jsonStr)
                    postCompleted(succeeded: false, msg: mensaje, userAndPass: params, contactDictionary: contact )
                }
            }
            
            
            task.resume()
    }
    
    
    //Utilizado en LoginViewController.
    ///Actualmente no se usa. Es para el login a partir de la tabla "_User" de Parse.
    //    func loginInParse(){
    //        PFUser.logInWithUsernameInBackground("pmo", password:"pmo") {
    //            (user: PFUser?, error: NSError?) -> Void in
    //            guard error == nil else {
    //                if let message: AnyObject = error!.userInfo["error"] {
    //                    self.mensaje = "\(message)"
    //                    print(self.mensaje)
    //                    dispatch_async(dispatch_get_main_queue()) {
    //                        self.activityIndicator.stopAnimating()
    //                        print("In LoginViewController > loginInParse: error de login in parse. \(self.mensaje)")
    //                    }
    //                }
    //                return
    //            }
    //        }
    //    }
    
    //Utilizado en LoginViewController.
    ///se utiliza para agregar el rol de PMO de manera manual a un contacto a partir de su objectId (NO USAR)
    //        func addPMO(){
    //            //1) traemos el contacto al que queremos agregar el rol de PMO.
    //            //Por ahora el objectId está Hard-Code.
    //            let contact = PFObject(withoutDataWithClassName: "Contact", objectId: "hJWt9FaN39")
    //            //try! contact.fetchIfNeeded()
    //
    //            //2) obtenemos el RolContact que contiene a los PMO.
    //            let query1 = PFQuery(className: "RolesContact")
    //            query1.whereKey("Name", equalTo: "PMO")
    //
    //            let rolesContactObj = try! query1.getFirstObject()
    //
    //            //3) Una vez obtenido, se añade a la relation
    //            let rel = rolesContactObj.relationForKey("Contactos")
    //            rel.addObject(contact)
    //
    //            //4) por ultimo, se guarda.
    //            try! rolesContactObj.save()
    //        }
    
    
    //    //Utilizado en LoginViewController.
    //    ///se utiliza para agregar el rol de PMO de manera manual a un contacto a partir de su objectId (NO USAR)
    //    func addPMO(){
    //        //1) traemos el contacto al que queremos agregar el rol de PMO.
    //        //Por ahora el objectId está Hard-Code.
    //        let contact = PFObject(withoutDataWithClassName: "Contact", objectId: "hJWt9FaN39")
    //        try! contact.fetchIfNeeded()
    //
    //        //2) obtenemos el RolContact que contiene a los PMO.
    //        let query1 = PFQuery(className: "RolesContact")
    //        query1.whereKey("Name", equalTo: "PMO")
    //
    //        let rolesContactObj = try! query1.getFirstObject()
    //
    //        //3) Una vez obtenido, se añade a la relation
    //        let rel = rolesContactObj.relationForKey("Contactos")
    //        rel.addObject(contact)
    //        
    //        //4) por ultimo, se guarda.
    //        try! rolesContactObj.save()
    //    }
}