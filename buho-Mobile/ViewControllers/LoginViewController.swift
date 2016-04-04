//
//  LoginViewController.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/6/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController{

//    @IBOutlet private weak var myScroll: UIScrollView!
    @IBOutlet private weak var userTextField: UITextField!
    @IBOutlet private weak var passTextField: UITextField!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var activeField: UITextField?
    
    private var networkConnection : NetworkConnection = NetworkConnection.sharedInstance
    private var parseConnection : ParseConnection = ParseConnection.sharedInstance
    private var persistedSettings : PersistedSettings = PersistedSettings.sharedInstance
    private var tmpData: TemporalData = TemporalData.sharedInstance
    
    var contact : Contact? {
        return tmpData.contacto
    }
    
    
    //MARK: - Life cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let usr = self.persistedSettings.usuario where usr != "", let pwd = self.persistedSettings.password where pwd != ""{
            userTextField.text = usr
            passTextField.text = pwd
            loginAction(self)
            
        }
        
        activityIndicator.hidesWhenStopped = true
    }

    //MARK: - funciones
    @IBAction func loginAction(sender: AnyObject) {
        let userEmailAddress = userTextField.text?.lowercaseString
        let userPassword = passTextField.text
        
        guard let user = userEmailAddress where !user.isEmpty,
            let pass = userPassword where !pass.isEmpty else{
                CommonHelpers.presentOneAlertController(self, alertTitle: "Campos Vacíos", alertMessage: "Favor complete los datos solicitados", myActionTitle: "OK", myActionStyle: .Default)
                return
        }
        
        persistedSettings.usuario = user
        persistedSettings.password = pass
        let userAndPass : [String: String] = ["username": user, "password": pass]
        
        activityIndicator.startAnimating()
        
        networkConnection.postForContact(userAndPass, postCompleted: {
            (succeded, msg, error, contactDictionary) -> () in
            
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Show the alert
                    CommonHelpers.presentOneAlertController(self, alertTitle: "Error en login. 😕", alertMessage: msg, myActionTitle: "OK", myActionStyle: .Default)
                    self.activityIndicator.stopAnimating()
                })
                return
            }
            
            //1)valida si está en el AD.
            if succeded {
                
                //2)Si está en AD, busca el contacto en Parse con email: contactDictionary["Email"]!
                self.parseConnection.getContactByEmail( contactDictionary["Email"]!, completionHandler: { (succeded, error, msg, contact) -> () in
                    
                    guard error == false || succeded == true else{
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // Show the alert
                            CommonHelpers.presentOneAlertController(self, alertTitle: "Error en login. 😕", alertMessage: msg, myActionTitle: "Aceptar", myActionStyle: .Default)
                            self.activityIndicator.stopAnimating()
                        })
                        return
                    }
                    
                    self.tmpData.contacto = contact
                    
                    //3) Si se encuentra el contact, entonces entrará a la aplicación.
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.stopAnimating()
                        self.performSegueWithIdentifier("signInToSplitView", sender: self)
                    }
                })
            }else{
                //1.1) Si no esta en AD, entonces loguea por Parse.
                self.parseConnection.loginInParse(userAndPass, completion: { (succeded, error, user) -> () in
                    guard error == nil || succeded == true else{
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // Show the alert
                            let msg = "No se encontró usuario."
                            CommonHelpers.presentOneAlertController(self, alertTitle: "Error en login. 😕", alertMessage: msg, myActionTitle: "Aceptar", myActionStyle: .Default)
                            self.activityIndicator.stopAnimating()
                        })
                        return
                    }
                    if let cont = user?.objectForKey("ContactId") as? Contact {
                        if !cont.dataAvailable {
                            cont.fetchIfNeededInBackground()
                        }
                        self.tmpData.contacto = cont
                    }
                    
                    //3) Si se encuentra el contact, entonces entrará a la aplicación.
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.stopAnimating()
                        self.performSegueWithIdentifier("signInToSplitView", sender: self)
                    }

                })
            }

        })
    }
//    
//    //MARK: - Navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let destino = segue.destinationViewController as? UISplitViewController{
//            let nav = destino.viewControllers.first as? UINavigationController
//            if let master = nav?.viewControllers.first as? ContractViewController{
//                master.contact = contact
//            }
//        }
//    }

}

extension LoginViewController: UITextFieldDelegate {
    //MARK: - UITextFieldDelegate
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.subviews.first?.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(userTextField){
            passTextField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            loginAction(self)
        }
        
        return true
    }
    
}
