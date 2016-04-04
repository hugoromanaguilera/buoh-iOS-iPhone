//
//  ActivityController.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 31-03-16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit

protocol DateMeetingVCDelegate {
    func saveDate(data: [String: NSDate])
}

private let kCellActivity = "cellActivity"
private let segueToDetail = "detailActivity"

class ActivityController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: - Variables
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var filterButton: UIBarButtonItem!
    var refresher: UIRefreshControl!
    
    private var pConnection: ParseConnection = ParseConnection.sharedInstance
    private var tmpData: TemporalData = TemporalData.sharedInstance
    
    internal var detailContact: Contact? {
        return tmpData.contacto
    }
    internal var detailContract: Contract? {
        return tmpData.contrato
    }
    
    var delegate : DateMeetingVCDelegate?
    
    private var sectionTitleArray : [String] = []
    private var arrayExpandSections : [Bool]!
    
    var arrayMeetingItems: [MeetingItem] {
        return tmpData.compromisos
    }
    var arraySelfActivities: [MeetingItem] = []
    var dictionaryActivities: [String: [MeetingItem] ] = [:]
    var dictionarySelfActivities: [String: [MeetingItem] ] = [:]
    var arrayDateActivities: [String] = []
    var arrayDateSelfActivities: [String] = []
    var isSelf: Bool = false
    
    var buttonFilter: UIBarButtonItem!
    var buttonLogout: UIBarButtonItem!
    
    //MARK: - Lyfe cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageFilter = UIImage(named: "filterOutline-24")
        let imageLogout = UIImage(named: "logout-24")
        
        buttonFilter = UIBarButtonItem(image: imageFilter, style: .Plain, target: self, action: #selector(ActivityController.filterAction(_:)))
        buttonLogout = UIBarButtonItem(image: imageLogout, style: .Plain, target: self, action: #selector(ActivityController.logoutAction(_:)) )
        
        navigationItem.rightBarButtonItems = [buttonFilter, buttonLogout]
        
        
        //botón para mostrar los contratos.
//        let tabBar = parentViewController?.parentViewController
//        navigationItem.leftBarButtonItem = tabBar?.navigationItem.leftBarButtonItem
////        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
//        navigationItem.leftItemsSupplementBackButton = true
        
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ActivityController.refresh), forControlEvents: .ValueChanged)
        
        tableView.addSubview(refresher)
        
        activityIndicator.hidesWhenStopped = true
        
        if let contract = detailContract {
            self.parentViewController?.navigationItem.title = "contract.Name"
            self.parentViewController?.navigationItem.rightBarButtonItems = [buttonFilter, buttonLogout]
//            navigationItem.title = contract.Name
            loadActivities(contract)
        }
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isSelf{
            //            return isNoData(arrayDateSelfActivities)
            return arrayDateSelfActivities.count
        }else{
            //            return isNoData(arrayDateActivities)
            return arrayDateActivities.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(kCellActivity) as! ActivityViewCell
        
        if isSelf {
            let title = arrayDateSelfActivities[indexPath.section]
            let activities = dictionarySelfActivities[title]!
            
            if activities[indexPath.row].DueDate.isLessThanDate(NSDate() ) {
                cell.viewColor.backgroundColor = UIColor.redColor()
            }else{
                cell.viewColor.backgroundColor = UIColor.whiteColor()
            }
            
            cell.activityLabel!.text = activities[indexPath.row].Detail
            return cell
        }else{
            let title = arrayDateActivities[indexPath.section]
            let activities = dictionaryActivities[title]!
            
            if activities[indexPath.row].DueDate.isLessThanDate(NSDate() ) {
                cell.viewColor.backgroundColor = UIColor.redColor()
            }else{
                cell.viewColor.backgroundColor = UIColor.whiteColor()
            }
            
            
            cell.activityLabel!.text = activities[indexPath.row].Detail
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isSelf {
            let sectionTitle = arrayDateSelfActivities[indexPath.section]
            let activities = dictionarySelfActivities[ sectionTitle ]!
            tmpData.actividad = activities[indexPath.row]
            performSegueWithIdentifier(segueToDetail, sender: nil)
        }else{
            let sectionTitle = arrayDateActivities[indexPath.section]
            let activities = dictionaryActivities[ sectionTitle ]!
            tmpData.actividad = activities[indexPath.row]
            performSegueWithIdentifier(segueToDetail, sender: nil)
        }
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayExpandSections[section].boolValue {
            if isSelf {
                let title = arrayDateSelfActivities[section]
                let count = dictionarySelfActivities[title]!.count
                return count
            }else{
                let title = arrayDateActivities[section]
                let count = dictionaryActivities[title]!.count
                return count
            }
        }else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSelf {
            let title = arrayDateSelfActivities[section]
            if let day = getDayOfWeek(title) {
                return day
            }else{
                return title
            }
        }else{
            let title = arrayDateActivities[section]
            if let day = getDayOfWeek(title) {
                return day
            }else{
                return title
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor(red: 142/255, green: 68/255, blue: 142/255, alpha: 1)
    }
    
    //MARK: - Funciones
    @IBAction func filterAction(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: "Seleccione el tipo de filtro:", preferredStyle: .ActionSheet)
        actionSheet.view.tintColor = UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1)
        
        let contratoAction = UIAlertAction(title: "Contrato", style: .Default) { _ in
            let image = UIImage(named: "filterOutline-24")
            self.buttonFilter.image = image
//            self.filterButton.image = image
            
            self.arrayExpandSections = [Bool](count: self.dictionaryActivities.count, repeatedValue: true)
            self.isSelf = false
            self.tableView.reloadData()
        }
        
        let propiosAction = UIAlertAction(title: "Propios", style: .Default) { _ in
            let image = UIImage(named: "filter-24")
            self.buttonFilter.image = image
//            self.filterButton.image = image
            
            self.arrayExpandSections = [Bool](count: self.dictionarySelfActivities.count, repeatedValue: true)
            self.isSelf = true
            self.tableView.reloadData()
        }
        actionSheet.addAction(contratoAction)
        actionSheet.addAction(propiosAction)
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: nil))
        presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func logoutAction(sender: UIBarButtonItem) {
        CommonHelpers.logout(self)
    }
    
    func loadActivities(contract: Contract){
        if !self.refresher.refreshing {
            activityIndicator.startAnimating()
        }
        pConnection.getActivitiesForContract(contract, completionHandler: { (succeded, error, data) -> () in
            guard (error == nil) && (succeded == true) else {
                self.activityIndicator.stopAnimating()
                if !succeded {
                    print("no se encontraron actividades")
                }else {
                    print("error al obtener las actividades")
                }
                return
            }
            
            self.tmpData.compromisos = data!
            self.loadSelfActivities()
            //            if !self.tmpData.compromisos.isEmpty {
            //                self.arrayMeetingItems = self.tmpData.compromisos
            //                self.loadSelfActivities()
            //            }else{
            //                self.tmpData.compromisos = data!
            //                self.arrayMeetingItems = self.tmpData.compromisos
            //                self.loadSelfActivities()
            //            }
        })
    }
    
    func loadSelfActivities(){
        
        var dicActivities: [String: [MeetingItem] ] = [:]
        var dicSelfActivities: [String: [MeetingItem] ] = [:]
        
//        var i: Int
//        var j: Int
//        for i = 0; i < arrayMeetingItems.count; i += 1 {
        for i in 0..<arrayMeetingItems.count {
            let meetingItem = arrayMeetingItems[i]
//            for j = 0; j < meetingItem.Responsibilities.count; j += 1{
            for j in 0..<meetingItem.Responsibilities.count {
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
        
        tmpData.compromisos.sortInPlace({   $0.DueDate.isLessThanDate($1.DueDate) })
        
        arraySelfActivities.sortInPlace({   $0.DueDate.isLessThanDate($1.DueDate) })
        
        for activity in arrayMeetingItems {
            if dicActivities[activity.DueDate.dateToString() as! String] == nil {
                dicActivities[activity.DueDate.dateToString() as! String] = []
            }
            dicActivities[activity.DueDate.dateToString() as! String]!.append(activity)
        }
        
        for activity in arraySelfActivities {
            if dicSelfActivities[activity.DueDate.dateToString() as! String] == nil {
                dicSelfActivities[activity.DueDate.dateToString() as! String] = []
            }
            dicSelfActivities[activity.DueDate.dateToString() as! String]!.append(activity)
        }
        
        arrayDateActivities = [String](dicActivities.keys)
        arrayDateSelfActivities = [String](dicSelfActivities.keys)
        
        arrayDateActivities.sortInPlace {
            $0.stringToDate()!.isLessThanDate($1.stringToDate()!)
        }
        
        arrayDateSelfActivities.sortInPlace {
            $0.stringToDate()!.isLessThanDate($1.stringToDate()!)
        }
        
        
        dictionaryActivities = dicActivities
        dictionarySelfActivities = dicSelfActivities
        
        arrayExpandSections = [Bool](count: dictionaryActivities.count, repeatedValue: true)
        
        activityIndicator.stopAnimating()
        
        if self.refresher.refreshing {
            self.refresher.endRefreshing()
        }
        tableView.reloadData()
    }
    
    func refresh(){
        if let contract = detailContract {
            loadActivities(contract)
        }
    }



}

