//
//  Extensiones.swift
//  MinutasExternas
//
//  Created by Rodrigo Astorga on 11/1/15.
//  Copyright © 2015 solu4b. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Array
extension Array{
    func getContactsById(contactId: String) -> Contact?
    {
        for obj in self{
            if let contacto = obj as? Contact{
                if contactId == contacto.objectId! {
                    return contacto
                }
            }
        }
        return nil
    }
    
    ///obtiene el codigo asociado al id consultado
    func getCodeById(codeId: String) -> Code?
    {
        for obj in self{
            if let codigo = obj as? Code{
                if codeId == codigo.objectId! {
                    return codigo
                }
            }
        }
        return nil
    }
    
    func getCodeByName(codeName : String) -> Code?
    {
        for obj in self{
            if let codigo = obj as? Code{
                if codeName == codigo.Name {
                    return codigo
                }
            }
        }
        return nil
    }

    
//    /****
//     busca en el arreglo de participantes si se encuentra dicho contacto.
//     - Observación: UTILIZAR SOLO PARA EL ARRAY DE TIPO `Participant` y `Contact`
//     - parameter object: el contacto que se desea buscar
//     - returns: true si se encuentra el contacto en el array de participantes.
//     */
//    func containsContacto(contact: Contact) -> Bool
//    {
//        for object in self
//        {
//            if let part: Participant = object as? Participant
//            {
//                if part.ContactId == contact { return true }
//            }
//            
//            if let cont: Contact = object as? Contact
//            {
//                if cont == contact { return true }
//            }
//        }
//        return false
//    }
    
    /**
     Verifica si existe el contacto con "Email" en el array de Contactos
     - warning: UTILIZAR SÓLO CON EL ARRAY DE CONTACTOS.
     - parameter contact: el contacto el cual se desea buscar
     - returns: `true` si el contacto existe en el array
     */
    func containsContactByEmail(contact : Contact) -> Bool {
        for object in self
        {
            
            if let cont: Contact = object as? Contact
            {
                if cont.Email == contact.Email { return true }
            }
        }
        return false
    }
    
    /**
     Verifica si existe el contacto con "Name" y "LastName" en el array de Contactos.
     Ejemplo: Rodrigo Astorga
     - warning: UTILIZAR SÓLO CON EL ARRAY DE CONTACTOS.
     - parameter contact: el contacto el cual se desea buscar
     - returns: `true` si el contacto existe en el array
     */
    func containsContactByName(contact : Contact) -> Bool {
        for object in self
        {
            if let cont: Contact = object as? Contact
            {
                if cont.Name == contact.Name && cont.LastName == contact.LastName{ return true }
            }
        }
        return false
    }
    
    func getIndexForComment(comment: String) -> Int?{
        var i: Int
        for i = 0; i < self.count; i += 1 {
            let object = self[i]
            if let commentApproval = object as? CommentsApproval {
                if commentApproval.Comment == comment { return i }
            }
        }
        return nil
    }

//    /****
//    Obtiene el participante de un arreglo de participantes a partir de un contacto
//    Ejemplo: Rodrigo Astorga
//    - warning: UTILIZAR SÓLO CON EL ARRAY DE participantes.
//    - parameter contact: el contacto el cual se desea buscar
//    - returns: `Participant` si el contacto existe en el array
//    */
//    func getParticipante(object: Contact) -> Participant?
//    {
//        for participante in self
//        {
//            if let part: Participant = participante as? Participant
//            {
//                if part.ContactId == object { return part }
//            }
//        }
//        return nil
//    }
    
//    func getIndexOfParticipante(object: Contact) -> Int
//    {
//        var i : Int
//        for i = 0; i < self.count; i++
//        {
//            if let part: Participant = self[i] as? Participant
//            {
//                if part.ContactId == object { return i }
//            }
//        }
//        return -1
//    }
//    
//    mutating func removeParticipantByContact(contacto: Contact) -> Int
//    {
//        var i : Int
//        for(i = 0; i<self.count; i++ ){
//            let res = self[i] as! Participant
//            if res.ContactId == contacto {
//                self.removeAtIndex(i)
//                return i
//            }
//        }
//        return -1
//    }
    
}

//MARK: - NSDate
extension NSDate {
    
    // -> Date System Formatted Medium
    func ToDateMediumString() -> NSString? {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle;
        formatter.timeStyle = .NoStyle;
        return formatter.stringFromDate(self)
    }
    
    ///Pasa un tipo NSDate a tipo NSString con formato dd/MM/yyyy
    func dateToString() -> NSString?{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.stringFromDate(self)
    }
    
    func dateToHourString() -> NSString?{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.stringFromDate(self)
    }
    
    func getDateAndHourString() -> NSString?{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.stringFromDate(self)
    }
    
    func getHourAndMin() -> NSString?{
        var minutes: String = ""
        var hours : String = ""
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Hour, .Minute], fromDate: self)
        let hour = comp.hour
        if hour < 10 {
            hours = "0\(String(hour))"
        }else{
            hours = "\(String(hour))"
        }
        let minute = comp.minute
        if minute < 10 {
            minutes = "0\(String(minute))"
        }else{
            minutes = "\(String(minute))"
        }
        
        return "\(hours):\(minutes)"
    }
    
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    static func yesterDay() -> NSDate {
        
        let today: NSDate = NSDate()
        
        let daysToAdd:Int = -1
        
        // Set up date components
        let dateComponents: NSDateComponents = NSDateComponents()
        dateComponents.day = daysToAdd
        
        // Create a calendar
//        let gregorianCalendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
//        let yesterDayDate: NSDate = gregorianCalendar.dateByAddingComponents(dateComponents, toDate: today, options:NSCalendarOptions(rawValue: 0))!
        
        let calendar = NSCalendar.currentCalendar()
        let yesterDayDate = calendar.dateByAddingUnit(.Day, value: daysToAdd, toDate: today, options: NSCalendarOptions(rawValue: 0) )!
        
        return yesterDayDate
    }
    ///implementacion propia.
    func isEqualDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame
        {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

//MARK: - String
extension String {
    func convertDateToTimestamp() -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let timeStamp = dateFormatter.stringFromDate(NSDate())
        return timeStamp

    }
    ///pasa un String con formato dd/MM/yyyy a tipo NSDate
    func stringToDate() ->NSDate?{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyy"
        let date: NSDate = formatter.dateFromString(self)!
        return date
    }
    ///pasa un String con formato medium a tipo NSDate
    func toDate() -> NSDate? {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle;
        formatter.timeStyle = .NoStyle;
        if let date = formatter.dateFromString(self){
            return date
        }else{
            return nil
        }
    }
    
    ///pasa un String con formato HH:mm:ss a tipo NSDate
    func stringHourToDate() -> NSDate?{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        let date : NSDate = formatter.dateFromString(self)!
        return date
    }
    
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
    
    //validate PhoneNumber
    var isPhoneNumber: Bool {
        
        let charcter  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
        var filtered:NSString!
        let inputString:NSArray = self.componentsSeparatedByCharactersInSet(charcter)
        filtered = inputString.componentsJoinedByString("")
        return  self == filtered
        
    }
    ///primer carácter en máyuscula
    func firstCharacterUpperCase() -> String {
        if !self.isEmpty {
            let lowercaseString = self.lowercaseString
            
            return lowercaseString.stringByReplacingCharactersInRange(lowercaseString.startIndex...lowercaseString.startIndex, withString: String(lowercaseString[lowercaseString.startIndex]).uppercaseString)
        }else{
            return ""
        }
        
    }
}

//MARK: - UIColor
extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int, claro: Bool)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        if claro {
            self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 0.3)
        }
        else{
            self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
        }
    }
}

//MARK: - UIView
extension UIView {

     ///Computed property que se utiliza para cambiar el color en InterfaceBuilder de bordes.
//    @IBInspectable var borderColor : UIColor? {
//        get {
//            if let cgcolor = layer.borderColor {
//                return UIColor(CGColor: cgcolor)
//            } else {
//                return nil
//            }
//        }
//        set {
//            layer.borderColor = newValue?.CGColor
//            
//            // width must be at least 1.0
//            if layer.borderWidth < 1.0 {
//                layer.borderWidth = 1.0
//            }
//        }
//    }
    //Colores para los textField (in LoginViewController ....viewDidLoad..):
//            ingresarButton.backgroundColor = UIColor(red: 0x8E, green: 0x44, blue: 0xAD, claro: false)
//            userTextField.layer.borderWidth = 1
//            userTextField.layer.borderColor = UIColor(red: 0x8E, green: 0x44, blue: 0xAD, claro: false).CGColor
//            passwordTextField.layer.borderWidth = 1
//            passwordTextField.layer.borderColor = UIColor(red: 142/*0x8E*/, green: 68 /*0x44*/, blue: 173/*0xAD*/, claro: false).CGColor
    
    ///Computed property que se utiliza para poner una imagen de fondo en una UIView desde InterfaceBuilder.
    @IBInspectable var backgroundColorFromImage : UIImage? {
        get{
            if let _ = self.backgroundColor {
                return UIImage()
            }
            else {
                return nil
            }
        }
        set{
            self.backgroundColor = UIColor(patternImage: newValue!)
        }
    }
    //para el background (En LoginViewController : viewDidLoad()...:
    //        view.backgroundColor = UIColor(patternImage: UIImage(named: "buohBackyard.png")!)

    
    /**
     Set x Position
     
     :param: x CGFloat
     by DaRk-_-D0G
     */
    func setX(x x:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.x = x
        self.frame = frame
    }
    /**
     Set y Position
     
     :param: y CGFloat
     by DaRk-_-D0G
     */
    func setY(y y:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.y = y
        self.frame = frame
    }
    /**
     Set Width
     
     :param: width CGFloat
     by DaRk-_-D0G
     */
    func setWidth(width width:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.width = width
        self.frame = frame
    }
    /**
     Set Height
     
     :param: height CGFloat
     by DaRk-_-D0G
     */
    func setHeight(height height:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.height = height
        self.frame = frame
    }
    /**
     Aumentar Height
     - parameter height:  CGFloat
     */
    func aumentarHeight(height height:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.height += height
        self.frame = frame
    }
}

//MARK: - UIViewController
extension UIViewController {
    
    func mensajeAlerta(title: String, message: String, titleButton: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: titleButton, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //    func alert(title: String, message: String) {
    //        if let getModernAlert: AnyClass = NSClassFromString("UIAlertController") { // iOS 8
    //            let myAlert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    //            myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    //            self.presentViewController(myAlert, animated: true, completion: nil)
    //        } else { // iOS 7
    //            let alert: UIAlertView = UIAlertView()
    //            alert.delegate = self
    //
    //            alert.title = title
    //            alert.message = message
    //            alert.addButtonWithTitle("OK")
    //
    //            alert.show()
    //        }
    //    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
}