//
//  ContractViewController.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/7/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit
import Parse

class ContractViewController: UITableViewController, UISearchResultsUpdating {
    
    //MARK: - Variables
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var refresher: UIRefreshControl!
    
    private var parseConnection : ParseConnection = ParseConnection.sharedInstance
    private var tmpData: TemporalData = TemporalData.sharedInstance

    var arrayCompanies : [String] = [] //para titulos de sección
    var arrayContracts: [Contract] {
        return tmpData.contratos
    }
    var dictionaryContracts : [ String : [Contract] ] {
        return tmpData.dicContratos
    }
    
    var arrayFilteredContracts = [Contract]()
    var resultSearchController : UISearchController!// = UISearchController()
    
    var contract: Contract?
    var contact : Contact?
    
    var indexContact : Int?
    var indexFilteredContact : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.addSubview(refresher)
        
        CommonHelpers.setTableViewColor(tableView)
        definesPresentationContext = true
        
        /*Config del searchBar */
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
//        resultSearchController.view.tintColor = UIColor(red: 0x8E, green: 0x44, blue: 0xAD, claro: false)
        
        
        tableView.tableHeaderView = resultSearchController.searchBar
        
        /*Fin de Config searchBar */
        
        //        tableView.reloadData()
        if let contact = contact {
            loadContracts(contact)
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        clearsSelectionOnViewWillAppear = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    //solo para separar las secciones de contratos:
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if resultSearchController.active{
            return 1
        }else{
            return self.arrayCompanies.count
        }
        
    }
    //para saber cuantas secciones son:
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if resultSearchController.active{
            return nil
        }else{
            return self.arrayCompanies[section]
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.active{
            return arrayFilteredContracts.count
        }else{
            let titleSection = self.arrayCompanies[section]
            let arrayParaSection = self.dictionaryContracts[titleSection]
            
            return arrayParaSection!.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellContract", forIndexPath: indexPath)
        if resultSearchController.active {
            cell.textLabel?.text = arrayFilteredContracts[indexPath.row].Name
        }else{
            let titleSection = self.arrayCompanies[indexPath.section]
            let sectionContracts = self.dictionaryContracts[titleSection]
            let contr = sectionContracts![indexPath.row].Name
            cell.textLabel?.text = contr
            
            return cell;
        }
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        contract = Contract()
        if resultSearchController.active {
            tmpData.contrato = arrayFilteredContracts[indexPath.row]
            performSegueWithIdentifier("showDetail", sender: arrayFilteredContracts[indexPath.row])
            resultSearchController.searchBar.clearsContextBeforeDrawing = true
        }else{
            
            let titleSection = self.arrayCompanies[indexPath.section]
            let sectionContracts = self.dictionaryContracts[titleSection]!
            tmpData.contrato = sectionContracts[indexPath.row]
            performSegueWithIdentifier("showDetail", sender: sectionContracts[indexPath.row])
        }
        
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1)
    }

    //MARK: - Funciones
    @IBAction func logoutButtonAction(sender: UIBarButtonItem) {
        CommonHelpers.logout(self)
    }
    
    func loadContracts(contact : Contact){
        if !refresher.refreshing {
            activityIndicator.startAnimating()
        }
        
        
        parseConnection.getContractsForContact(contact) { (succeded, error, data) -> () in
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    CommonHelpers.presentOneAlertController(self, alertTitle: "Sin contratos.", alertMessage: "No se encontraron contratos o usted no posee contratos.", myActionTitle: "OK", myActionStyle: UIAlertActionStyle.Default)
                }
                return
            }
            guard succeded == true else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    CommonHelpers.presentOneAlertController(self, alertTitle: "Sin contratos.", alertMessage: "No se encontraron contratos o usted no posee contratos.", myActionTitle: "OK", myActionStyle: UIAlertActionStyle.Default)
                }
                return
            }
            
            self.tmpData.contratos = data!["contracts"] as! [Contract]
            self.tmpData.dicContratos = data!["dictionary"] as! NSDictionary as! [String: [Contract] ]
            self.arrayCompanies.removeAll()
            self.arrayCompanies = [String](self.tmpData.dicContratos.keys)
            self.arrayCompanies.sortInPlace({ $0 < $1 })
            
//            self.arrayCompanies = data!["companies"] as! [String]
//            self.arrayContracts = data!["contracts"] as! [Contract]
//            self.dictionaryContracts = data!["dictionary"] as! NSDictionary as! [String : [Contract]]
            
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()

                if self.refresher.refreshing {
                    self.refresher.endRefreshing()
                }
                self.tableView.reloadData()
//                
//                //para seleccionar la primera fila por default
//                if !self.arrayContracts.isEmpty {
//                    let rowToSelect:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0);  //selecting 0th row with 0th section
//                    self.tableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.None);
//                    self.tableView(self.tableView, didSelectRowAtIndexPath: rowToSelect);
//                }
            }
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        arrayFilteredContracts = self.arrayContracts.filter({ (contract : Contract) -> Bool in
            let stringMatch = "\(contract.Name)".rangeOfString(searchText)
            return (stringMatch != nil)
            
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        arrayFilteredContracts.removeAll(keepCapacity: false)
        
        //  PROPIA FORMA DE FILTRAR
        for cont in arrayContracts{
            if "\(cont.Name)".lowercaseString.containsString(searchController.searchBar.text!.lowercaseString){
                arrayFilteredContracts.append(cont)
                arrayFilteredContracts.sortInPlace({$0.Name.lowercaseString > $1.Name.lowercaseString})
            }
        }
        self.tableView.reloadData()
    }
    
    func refresh(){
        if let contact = contact {
            loadContracts(contact)
        }
    }
    
//    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            let navVC = segue.destinationViewController as! UINavigationController
            let detailVC = navVC.viewControllers.first as! ActivityViewController
            detailVC.detailContract = sender as? Contract
            detailVC.detailContact = self.contact!
        }
    }
    
}