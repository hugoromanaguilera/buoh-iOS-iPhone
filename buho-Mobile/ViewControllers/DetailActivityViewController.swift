//
//  DetailActivityViewController.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/10/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit



class DetailActivityViewController: UITableViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pConnection: ParseConnection = ParseConnection.sharedInstance
    var tmpData: TemporalData = TemporalData.sharedInstance
    
    internal var activity: MeetingItem?
    var isDataAvailable = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //para que las celdas se ajusten al tamaño del texto.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            if let responsibilities = self.tmpData.actividad?.Responsibilities {
                var i: Int
                for i = 0; i < responsibilities.count; i += 1 {
                    if let contact = responsibilities[i].ContactId {
                        if contact.dataAvailable {
                            self.isDataAvailable = true
                        }else{
                            self.isDataAvailable = false
                            break
                        }
                    }
                }
                if !self.isDataAvailable {
                    self.tmpData.actividad?.fetchContacts()
                    self.activity = self.tmpData.actividad
                    self.isDataAvailable = true
                    dispatch_async(dispatch_get_main_queue() ) {
                        self.activityIndicator.stopAnimating()
                        self.tableView.reloadData()
                    }
                }else{
                    self.activity = self.tmpData.actividad
                    self.isDataAvailable = true
                    dispatch_async(dispatch_get_main_queue() ) {
                        self.activityIndicator.stopAnimating()
                        self.tableView.reloadData()
                    }
                    
                }
                
            }

        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        while !isDataAvailable {
            activityIndicator.startAnimating()
        }
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if activity != nil {
            return 6
        }else{
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 4:
            return (activity?.Responsibilities.count)!
        case 5:
            return (activity?.Comments.count)!
        default:
            return 1
        }
        
    }
    

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Descripción"
        case 1:
            return "Creada el"
        case 2:
            return "Fecha Plazo"
        case 3:
            return "Estado"
        case 4:
            return "Responsables"
        case 5:
            return "Comentarios"
        default:
            return "Sección extra."
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // Gets the header view as a UITableViewHeaderFooterView and changes the text colour
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1)
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "cellDetailActivity"
        let cellDueDate = "cellDueDateActivity"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)! //, forIndexPath: indexPath)

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = activity?.Detail
        case 1:
            cell.textLabel?.text = (activity?.DateItem.dateToString() as! String)
        case 2:
            let cellDate = tableView.dequeueReusableCellWithIdentifier(cellDueDate) as! DueDateViewCell//, forIndexPath: indexPath) as! DueDateViewCell
            
            cellDate.labelDueDate.text = (activity?.DueDate.dateToString() as! String)
            if activity!.DueDate.isLessThanDate(NSDate() ) {
                cellDate.imageViewTime.image  = UIImage(named: "timeRed")
            }else{
                cellDate.imageViewTime.image  = UIImage(named: "timeGreen")
            }
            
            return cellDate
            
//            cell.textLabel?.text = (activity?.DueDate.dateToString() as! String)
        case 3:
            cell.textLabel?.text = activity?.State.Name
        case 4:
            let responsibilities = activity?.Responsibilities
            let responsibility = responsibilities![indexPath.row]
            if (responsibility.ContactId != nil) && (responsibility.RolTarea != nil) {
                cell.textLabel!.text = "\(responsibility.ContactId!.Name)  \(responsibility.ContactId!.LastName) (\(responsibility.RolTarea!.Name))"
            }
            
        case 5:
            let comments = activity?.Comments
            cell.textLabel?.text = comments![indexPath.row]
        default:
            cell.textLabel!.text = "No se obtuvo información."
        }
        
        return cell
    }
    
}
