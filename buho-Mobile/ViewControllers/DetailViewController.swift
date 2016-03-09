//
//  DetailViewController.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/9/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit

protocol DateMeetingVCDelegate {
    func saveDate(data: [String: NSDate])
}

private let kCellActivity = "cellActivity"

class DetailViewController: UITableViewController {
    
    internal var detailContact: Contact?
    internal var detailContract: Contract?
    
    var delegate : DateMeetingVCDelegate?
    var sectionTitleArray : [String] = []
    var arrayForBool : NSMutableArray = NSMutableArray()
    
    
    var start = NSDate()
    var end = NSDate()
    var isEarlyEnd : Bool = false {
        didSet {
            if isEarlyEnd {

            }else{

            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSizeMake(400,380)
        
        arrayForBool = ["0", "0"]
//        sectionTitleArray = [
//            "Hora Inicio:       \(start.getDateAndHourString()!) Hrs.",
//            "Hora Término:    \(end.getDateAndHourString()!) Hrs."]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitleArray.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayForBool[section].boolValue == true {
            return 1
        }
        return 0;
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(arrayForBool .objectAtIndex(indexPath.section).boolValue == true){
            return 216
        }
        return 2;
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        headerView.tag = section
        
        let headerString = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-10, height: 30)) as UILabel
        
        if self.isEarlyEnd {
            if section == 1 {
                let text = sectionTitleArray[section]
                let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: text)
                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                headerString.attributedText = attributeString
                headerView.addSubview(headerString)
            }else{
                headerString.text = sectionTitleArray[section]
                headerView.addSubview(headerString)
            }
        }else {
            headerString.text = sectionTitleArray[section]
            headerView.addSubview(headerString)
        }
        
        let headerTapped = UITapGestureRecognizer (target: self, action:"sectionHeaderTapped:")
        headerView.addGestureRecognizer(headerTapped)
        
        return headerView
    }
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        //revisa si otra sección está expandida para cerrarla.
        var index: Int
        for index = 0; index < 2; index++ {
            if (arrayForBool[index].boolValue == true) && (recognizer.view!.tag != index) {
                var collapsed = arrayForBool[index].boolValue
                collapsed       = !collapsed;
                arrayForBool.replaceObjectAtIndex(index, withObject: collapsed)
                let range = NSMakeRange(index, 1)
                let sectionToReload = NSIndexSet(indexesInRange: range)
                self.tableView.reloadSections(sectionToReload, withRowAnimation: UITableViewRowAnimation.Automatic)
                break
            }
        }
        
        //ahora contrae/expande la sección seleccionada.
        let indexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        if (indexPath.row == 0) {
            
            var collapsed = arrayForBool[indexPath.section].boolValue
            collapsed       = !collapsed;
            
            arrayForBool .replaceObjectAtIndex(indexPath.section, withObject: collapsed)
            
            //reload specific section animated
            let range = NSMakeRange(indexPath.section, 1)
            let sectionToReload = NSIndexSet(indexesInRange: range)
            self.tableView .reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Automatic)
            
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(kCellActivity) as! ActivityViewCell
        
//        if indexPath.section == 0 {
//            cell.datePicker.date = start
//        }else{
//            cell.datePicker.date = end
//        }
//        
//        cell.datePicker.datePickerMode = UIDatePickerMode.DateAndTime
//        cell.datePicker.tag = indexPath.section
//        cell.datePicker.addTarget(self, action: "changeDate:", forControlEvents: UIControlEvents.ValueChanged)
        
        return cell
        
    }
    
    func changeDate(sender: UIDatePicker){
        
        switch sender.tag {
            
        case 0:
            start = sender.date
            //            self.isEarlyEnd = false
            switch start.compare(end){
            case .OrderedDescending:
                self.isEarlyEnd = true
            default:
                self.isEarlyEnd = false
            }
//            sectionTitleArray[sender.tag] = "Hora Inicio:       \(start.getDateAndHourString()!) Hrs."
            //            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        case 1:
            end = sender.date
            
            // Compare them
            switch end.compare(start) {
            case .OrderedAscending:
                isEarlyEnd = true
            default:
                self.isEarlyEnd = false
            }
//            sectionTitleArray[sender.tag] = "Hora Término:    \(end.getDateAndHourString()!) Hrs."
            //            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.None)
        default:
            print("")
        }
    }
    
//    @IBAction func buttonAction(sender: UIButton) {
//        print("apreté el botón")
//        var data: [String : NSDate] = [:]
//        
//        data["start"] = start
//        data["end"] = end
//        
//        if let myDelegate = self.delegate {
//            myDelegate.saveDate(data)
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
