//
//  LoginViewController.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/6/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController{

    @IBOutlet private weak var myScroll: UIScrollView!
    @IBOutlet private weak var userTextField: UITextField!
    @IBOutlet private weak var passTextField: UITextField!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let url = "http://minutas.solu4b.com/contactos-svc/directory.svc/authInfo"
    
    var activeField: UITextField?
    
    var contact : Contact?
    var networkConnection : NetworkConnection = NetworkConnection.sharedInstance
    var parseConnection : ParseConnection = ParseConnection.sharedInstance
    var persistedSettings : PersistedSettings = PersistedSettings.sharedInstance
    
    //MARK: - Life cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let usr = self.persistedSettings.usuario where usr != "", let pwd = self.persistedSettings.password where pwd != ""{
            userTextField.text = usr
            passTextField.text = pwd
        }
        
        activityIndicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(animated: Bool) {
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    //MARK: - funciones
    @IBAction func LoginAction(sender: UIButton) {
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
        
        networkConnection.postForContact(userAndPass, url: self.url, postCompleted: {
            (succeeded, msg, userAndPass, contactDictionary) -> () in
            
            //1)valida si está en el AD.
            guard succeeded else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Show the alert
                    CommonHelpers.presentOneAlertController(self, alertTitle: "Error en login. 😕", alertMessage: msg, myActionTitle: "OK", myActionStyle: .Default)
                    self.activityIndicator.stopAnimating()
                })
                return
            }
            
            //2)Si está en AD, busca el contacto en Parse con email: contactDictionary["Email"]!
            self.parseConnection.getContactByEmail( contactDictionary["Email"]!, completionHandler: { (succeded, error, msg, contact) -> () in
                
                guard error == false || succeded == true else{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // Show the alert
                        CommonHelpers.presentOneAlertController(self, alertTitle: "Error en login. 😕", alertMessage: msg, myActionTitle: "OK", myActionStyle: .Default)
                        self.activityIndicator.stopAnimating()
                    })
                    return
                }
                
                self.contact = contact
                
                //4) si posee el rol de PMO, entonces entrará a la aplicación.
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.performSegueWithIdentifier("signInToSplitView", sender: self)
                }
            })
            
        })
    }
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destino = segue.destinationViewController as? UISplitViewController{
            let nav = destino.viewControllers.first as? UINavigationController
            if let master = nav?.viewControllers.first as? ContractViewController{
                master.contact = self.contact
            }
        }
    }

}

extension LoginViewController: UITextFieldDelegate {
    //MARK: - UITextFieldDelegate
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.subviews.first?.endEditing(true)
    }
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(userTextField){
            passTextField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            performSegueWithIdentifier("signInToSplitView", sender: self)
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        activeField = nil
    }
    
    func keyboardWasShown(aNotification:NSNotification) {
        let info = aNotification.userInfo
        let infoNSValue = info![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let kbSize = infoNSValue.CGRectValue().size
        
        let textf = activeField?.frame.origin
        let textheight = activeField?.frame.size.height
        var visibleRect = view.frame
        
        visibleRect.size.height -= kbSize.height
        
        if !CGRectContainsPoint(visibleRect, textf!){ //
            let scrollPoint = CGPointMake(0.0, textf!.y - visibleRect.size.height + textheight!)
            myScroll.setContentOffset(scrollPoint, animated: true)
        }
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        myScroll.setContentOffset(CGPointZero, animated: true)
    }
}

