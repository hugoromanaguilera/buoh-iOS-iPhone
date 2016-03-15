//
//  CommonHelpers.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/7/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import Foundation
import UIKit

class CommonHelpers: NSObject {
    
    override init() {
        super.init()
    }
    
    // MARK: Helpers
    class func presentOneAlertController(view: UIViewController, alertTitle: String, alertMessage: String, myActionTitle: String, myActionStyle: UIAlertActionStyle)-> Void{
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: myActionTitle, style: myActionStyle, handler: nil));
        //        alertController.view.backgroundColor = UIColor.whiteColor()
//        alertController.view.tintColor = UIColor(red: 0x8E, green: 0x44, blue: 0xAD, claro: false)
        view.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    class func partOfTheDay(part: String, forThisDate: NSDate)-> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        //        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        if (part == "dd") {
            dateFormatter.dateFormat = "dd"
            return dateFormatter.stringFromDate(forThisDate)
        }
        if (part == "month") {
            dateFormatter.dateFormat = "MMMM"
            return dateFormatter.stringFromDate(forThisDate)
        }
        if (part == "yyyy") {
            dateFormatter.dateFormat = "yyyy"
            return dateFormatter.stringFromDate(forThisDate)
        }
        return "s/d"
    }
    
    //MARK: set layouts
    ///se utiliza para configurar el color de fondo de los tableView
    class func setTableViewColor(myTableView: UITableView) -> Void {
//        myTableView.backgroundColor = UIColor(red: 0xEF, green: 0xEF, blue: 0xF6, claro: false)
    }
    
    ///se utiliza para configurar el color de fondo de un label
    class func labelMeeting (myLabel : UILabel ) -> Void {
        myLabel.backgroundColor = UIColor.whiteColor()
        //        myLabel.layer.cornerRadius = 10.0
        //        myLabel.clipsToBounds = true
    }
    
    ///se utiliza para configurar los bordes de un textView (redondear)
    class func setTextViewBound(myTextView : UITextView ) -> Void {
        let borderColor : UIColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        myTextView.layer.borderWidth = 0.7
        myTextView.layer.borderColor = borderColor.CGColor
        myTextView.layer.cornerRadius = 5.0
    }
    
    ///se utiliza para configurar el encabezado de la seccion de edicion de meetingItem
    class func setLabelMeetingItem(myLabel : UILabel, nombreSeccion : String) -> Void {
        myLabel.text = nombreSeccion
        myLabel.textColor = UIColor.whiteColor()
//        myLabel.backgroundColor = UIColor(red: 0xBE, green: 0x91, blue: 0xD4, claro: false)
    }
    
    ///se utiliza para asignar un título al headerView de un tableView
    class func setHeaderTableViewTitle(tableView : UITableView, section : Int, titulo : String) -> UIView {
        let headerFrame:CGRect = tableView.rectForHeaderInSection(section)
        let headerView: UIView = UIView(frame: CGRectMake(headerFrame.minX, headerFrame.minY, headerFrame.size.width, headerFrame.size.height))
//        headerView.backgroundColor = UIColor(red: 0xBE, green: 0x91, blue: 0xD4, claro: false)
        let title = UILabel(frame: CGRectMake( 20, 15, 300, 20))
        title.font = UIFont.systemFontOfSize(20)
        title.textColor = UIColor.whiteColor()
        title.shadowOffset = CGSize(width: 0, height: 1)
        title.text = titulo
        headerView.addSubview(title)
        return headerView
    }
    
    class func logout(fromView: UIViewController){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = sb.instantiateViewControllerWithIdentifier("LoginViewController")
        PersistedSettings.sharedInstance.usuario = ""
        PersistedSettings.sharedInstance.password = ""
        fromView.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    
}

func getDayOfWeek(today:String)->String? {
    
    let formatter  = NSDateFormatter()
    formatter.dateFormat = "dd-MM-yyyy"
    if let todayDate = formatter.dateFromString(today) {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
        let day = myCalendar.component(.Day, fromDate: todayDate)
        let month = myCalendar.component(.Month, fromDate: todayDate)
        let year = myCalendar.component(.Year, fromDate: todayDate)
        let weekDay = myComponents.weekday
        var dayString = String(day)
        if day < 10 {
            dayString = "0"+dayString
        }
        
        switch weekDay {
        case 1:
            return "Domingo, \(dayString) \(formatter.standaloneMonthSymbols[month-1]) \(year)"
        case 2:
            return "Lunes, \(dayString) \(formatter.standaloneMonthSymbols[month-1]) \(year)"
        case 3:
            return "Martes, \(dayString) \(formatter.standaloneMonthSymbols[month-1]) \(year)"
        case 4:
            return "Miércoles, \(dayString) \(formatter.standaloneMonthSymbols[month-1]) \(year)"
        case 5:
            return "Jueves, \(dayString) \(formatter.standaloneMonthSymbols[month-1]) \(year)"
        case 6:
            return "Viernes, \(dayString) \(formatter.standaloneMonthSymbols[month-1]) \(year)"
        case 7:
            return "Sábado, \(dayString) \(formatter.standaloneMonthSymbols[month-1]) \(year)"
        default:
            print("Error fetching days")
            return "Day"
        }
    }
    else{
        return nil
    }
    

}

//let weekday = getDayOfWeek("2014-08-27")
//print(weekday) // 4 = Wednesday