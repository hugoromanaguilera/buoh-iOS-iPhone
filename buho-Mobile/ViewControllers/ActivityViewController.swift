//
//  ActivityViewController.swift
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
private let segueToDetail = "detailActivity"

class ActivityViewController: UITableViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    internal var detailContact: Contact?
    internal var detailContract: Contract?
    
    private var pConnection: ParseConnection = ParseConnection.sharedInstance
    
    var delegate : DateMeetingVCDelegate?
    
    private var sectionTitleArray : [String] = []
    private var arrayExpandSections : [Bool]!
    
    var arrayMeetingItems: [MeetingItem] = []
    var arraySelfActivities: [MeetingItem] = []
    var dictionaryActivities: [String: [MeetingItem] ] = [:]
    var dictionarySelfActivities: [String: [MeetingItem] ] = [:]
    var isSelf: Bool = false
    
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
        activityIndicator.hidesWhenStopped = true
//        let filterImage = UIImage(named: "filter-outline")!
//        let filterButton = UIBarButtonItem(image: filterImage, style: .Plain, target: self, action: "actionFilter")
//        navigationController?.navigationItem.rightBarButtonItem = filterButton
//        self.preferredContentSize = CGSizeMake(400,380)
        
        if let contract = detailContract {
            navigationItem.title = contract.Name
//            navigationController?.navigationBar
            loadActivities(contract)
        }
        
        
//        arrayForBool = ["0", "0"]
//        sectionTitleArray = [
//            "Hora Inicio:       \(start.getDateAndHourString()!) Hrs.",
//            "Hora Término:    \(end.getDateAndHourString()!) Hrs."]
    }
    
    func actionFilter(){
        
    }
    
    @IBAction func filterAction(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: "Seleccione el tipo de filtro:", preferredStyle: .ActionSheet)
        
//        let view = UIView(frame: CGRect(x: 8.0, y: 8.0, width: actionSheet.view.bounds.size.width - 8.0 * 4.5, height: 120.0))
//        view.backgroundColor = UIColor.greenColor()
//        actionSheet.view.addSubview(view)
        let contratoAction = UIAlertAction(title: "Contrato", style: .Default) { _ in
            let image = UIImage(named: "filterOutline-24")
            self.filterButton.image = image
            
            self.arrayExpandSections = [Bool](count: self.dictionaryActivities.count, repeatedValue: true)
            self.isSelf = false
            self.tableView.reloadData()
        }
        
        let propiosAction = UIAlertAction(title: "Propios", style: .Default) { _ in
            let image = UIImage(named: "filter-24")
            self.filterButton.image = image
            
            self.arrayExpandSections = [Bool](count: self.dictionarySelfActivities.count, repeatedValue: true)
            self.isSelf = true
            self.tableView.reloadData()
        }
        actionSheet.addAction(contratoAction)
        actionSheet.addAction(propiosAction)
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: nil))
        presentViewController(actionSheet, animated: true, completion: nil)
        
        
//        let string = "Hola mundo"
//        let activityVC = UIActivityViewController(activityItems: [string], applicationActivities: nil)
//        navigationController?.presentViewController(activityVC, animated: true, completion: nil)
        
//        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .Alert)
//        ac.addTextFieldWithConfigurationHandler(nil)
//        
//        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self, ac] (action: UIAlertAction!) in
//            let answer = ac.textFields![0] as! UITextField
//            // do something interesting with "answer" here
//        }
//        
//        ac.addAction(submitAction)
//        
//        presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBAction func logoutAction(sender: UIBarButtonItem) {
        CommonHelpers.logout(self)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isSelf{
            return dictionarySelfActivities.count
        }else{
            return dictionaryActivities.count
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayExpandSections[section].boolValue {
            if isSelf {
                let sectionTitles = [String](dictionarySelfActivities.keys)
                let title = sectionTitles[section]
                let count = dictionarySelfActivities[title]!.count
                return count
            }else{
                let sectionTitles = [String](dictionaryActivities.keys)
                let title = sectionTitles[section]
                let count = dictionaryActivities[title]!.count
                return count
            }
        }else{
            return 0
        }
//        if arrayForBool[section].boolValue == true {
//            return 1
//        }
//        return 0;
        
//        return arraySelfActivities.count//arrayMeetingItems.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isSelf {
            let sectionTitles = [String](dictionarySelfActivities.keys)
            let activities = dictionarySelfActivities[ sectionTitles[indexPath.section] ]!
            performSegueWithIdentifier(segueToDetail, sender: activities[indexPath.row])
        }else{
            let sectionTitles = [String](dictionaryActivities.keys)
            let activities = dictionaryActivities[ sectionTitles[indexPath.section] ]!
            performSegueWithIdentifier(segueToDetail, sender: activities[indexPath.row])
        }
        
    }
//    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
//    
//    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 1
//    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if(arrayForBool .objectAtIndex(indexPath.section).boolValue == true){
//            return 216
//        }
//        return 2;
//    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
//        headerView.tag = section
//        
//        let headerString = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-10, height: 30)) as UILabel
//        
//        if self.isEarlyEnd {
//            if section == 1 {
//                let text = sectionTitleArray[section]
//                let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: text)
//                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
//                headerString.attributedText = attributeString
//                headerView.addSubview(headerString)
//            }else{
//                headerString.text = sectionTitleArray[section]
//                headerView.addSubview(headerString)
//            }
//        }else {
//            headerString.text = sectionTitleArray[section]
//            headerView.addSubview(headerString)
//        }
//
//        let headerTapped = UITapGestureRecognizer (target: self, action:"sectionHeaderTapped:")
//        headerView.addGestureRecognizer(headerTapped)
//        
//        return headerView
//    }
    
//    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
//        //revisa si otra sección está expandida para cerrarla.
//        var index: Int
//        for index = 0; index < 2; index++ {
//            if (arrayForBool[index].boolValue == true) && (recognizer.view!.tag != index) {
//                var collapsed = arrayForBool[index].boolValue
//                collapsed       = !collapsed;
//                arrayForBool.replaceObjectAtIndex(index, withObject: collapsed)
//                let range = NSMakeRange(index, 1)
//                let sectionToReload = NSIndexSet(indexesInRange: range)
//                self.tableView.reloadSections(sectionToReload, withRowAnimation: UITableViewRowAnimation.Automatic)
//                break
//            }
//        }
//        
//        //ahora contrae/expande la sección seleccionada.
//        let indexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
//        if (indexPath.row == 0) {
//            
//            var collapsed = arrayForBool[indexPath.section].boolValue
//            collapsed       = !collapsed;
//            
//            arrayForBool .replaceObjectAtIndex(indexPath.section, withObject: collapsed)
//            
//            //reload specific section animated
//            let range = NSMakeRange(indexPath.section, 1)
//            let sectionToReload = NSIndexSet(indexesInRange: range)
//            self.tableView .reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Automatic)
//            
//        }
//        
//    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSelf {
            let titles = [String](dictionarySelfActivities.keys)
            return titles[section]
        }else{
            let titles = [String](dictionaryActivities.keys)
            return titles[section]
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(kCellActivity)!// as! ActivityViewCell
        
//        let array = arraySections[isSelf]!
//        let sectionTitle = array[indexPath.section]
//        let activities = dictionaryActivities[sectionTitle]!
        
        if isSelf {
            let sectionTitles = [String](dictionarySelfActivities.keys)
            let title = sectionTitles[indexPath.section]
            let activities = dictionarySelfActivities[title]!
            
            cell.textLabel!.text = activities[indexPath.row].Detail
            return cell
        }else{
            let sectionTitles = [String](dictionaryActivities.keys)
            let title = sectionTitles[indexPath.section]
            let activities = dictionaryActivities[title]!
            
            cell.textLabel!.text = activities[indexPath.row].Detail
            return cell
        }
        
//        cell.textLabel!.text = activities[indexPath.row].Detail //arraySelfActivities[indexPath.row].Detail//arrayMeetingItems[indexPath.row].Detail
        
        
//        if indexPath.section == 0 {
//            cell.datePicker.date = start
//        }else{
//            cell.datePicker.date = end
//        }
//        
//        cell.datePicker.datePickerMode = UIDatePickerMode.DateAndTime
//        cell.datePicker.tag = indexPath.section
//        cell.datePicker.addTarget(self, action: "changeDate:", forControlEvents: UIControlEvents.ValueChanged)
        
//        return cell
        
    }
    
//    func changeDate(sender: UIDatePicker){
//        
//        switch sender.tag {
//            
//        case 0:
//            start = sender.date
//            //            self.isEarlyEnd = false
//            switch start.compare(end){
//            case .OrderedDescending:
//                self.isEarlyEnd = true
//            default:
//                self.isEarlyEnd = false
//            }
////            sectionTitleArray[sender.tag] = "Hora Inicio:       \(start.getDateAndHourString()!) Hrs."
//            //            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
//        case 1:
//            end = sender.date
//            
//            // Compare them
//            switch end.compare(start) {
//            case .OrderedAscending:
//                isEarlyEnd = true
//            default:
//                self.isEarlyEnd = false
//            }
////            sectionTitleArray[sender.tag] = "Hora Término:    \(end.getDateAndHourString()!) Hrs."
//            //            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.None)
//        default:
//            print("")
//        }
//    }
    
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


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destino = segue.destinationViewController as? DetailActivityViewController {
            if let send = sender as? MeetingItem{
                destino.activity = send
            }
        }
    }
    
    func loadActivities(contract: Contract){
        activityIndicator.startAnimating()
        pConnection.getActivitiesForContract(contract, completionHandler: { (succeded, error, data) -> () in
            guard error == nil else {
                self.activityIndicator.stopAnimating()
                return
            }
            if succeded {
                self.arrayMeetingItems = data!["activities"] as! [MeetingItem]
                
//                self.dictionaryActivities = data! as! [String : [MeetingItem]]
                self.loadSelfActivities()
//                self.tableView.reloadData()
            }
        })
    }

    func loadSelfActivities(){
        
        var dicActivities: [String: [MeetingItem] ] = [:]
        var dicSelfActivities: [String: [MeetingItem] ] = [:]
        
        var i: Int
        var j: Int
        for i = 0; i < arrayMeetingItems.count; i += 1 {
            let meetingItem = arrayMeetingItems[i]
            for j = 0; j < meetingItem.Responsibilities.count; j += 1{
                let responsibility = meetingItem.Responsibilities[j]
                if let contact = detailContact {
                    if responsibility.ContactId == contact{
                        if !arraySelfActivities.contains(meetingItem) {
                            arraySelfActivities.append(meetingItem)
                        }
                    }
                }
            }
        }
        
        
        arrayMeetingItems.sortInPlace({
            $0.DueDate.compare($1.DueDate) == NSComparisonResult.OrderedDescending
        })
        
        arraySelfActivities.sortInPlace({
            $0.DueDate.compare($1.DueDate) == NSComparisonResult.OrderedDescending
        })
        
        for activity in arrayMeetingItems {
            if dicActivities[activity.DueDate.ToDateMediumString() as! String] == nil {
                dicActivities[activity.DueDate.ToDateMediumString() as! String] = []
            }
            dicActivities[activity.DueDate.ToDateMediumString() as! String]!.append(activity)
            
        }
        
        for activity in arraySelfActivities {
            if dicSelfActivities[activity.DueDate.ToDateMediumString() as! String] == nil {
                dicSelfActivities[activity.DueDate.ToDateMediumString() as! String] = []
            }
            dicSelfActivities[activity.DueDate.ToDateMediumString() as! String]!.append(activity)
            
        }
        
        for dateTitle in dicActivities.keys {
            var compromisos = dicActivities[dateTitle]!
            
            
            //ordena los contratos por nombre.
            compromisos.sortInPlace({
                (m1: MeetingItem, m2: MeetingItem) -> Bool in
                m1.DueDate.compare(m2.DueDate) == NSComparisonResult.OrderedDescending
            })
            
            dicActivities[dateTitle] = compromisos
        }
        
        for dateTitle in dicSelfActivities.keys {
            var compromisos = dicSelfActivities[dateTitle]!
            
            
            //ordena los contratos por nombre.
            compromisos.sortInPlace({
                (m1: MeetingItem, m2: MeetingItem) -> Bool in
                m1.DueDate.compare(m2.DueDate) == NSComparisonResult.OrderedDescending
            })
            
            dicSelfActivities[dateTitle] = compromisos
        }
        
        dictionaryActivities = dicActivities
        dictionarySelfActivities = dicSelfActivities
        
        
        arrayExpandSections = [Bool](count: dictionaryActivities.count, repeatedValue: true)
        
//        arraySelfActivities.sortInPlace { (m1: MeetingItem, m2: MeetingItem) -> Bool in
//            m1.DueDate.compare(m2.DueDate) == NSComparisonResult.OrderedDescending
//        }
        
//        dump(arraySelfActivities)
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
}
