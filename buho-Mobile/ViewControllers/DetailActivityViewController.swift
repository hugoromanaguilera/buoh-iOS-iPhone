//
//  DetailActivityViewController.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/10/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit
import NextGrowingTextView

class DetailActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var inputContaiverView: UIView!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    @IBOutlet weak var addCommentButton: UIButton!
    
    private let placeholder = "Ingrese un nuevo comentario..."
    
    private var temporalComments: [String] = []
    private var newComments: [CommentsApproval] = []

    var tmpData: TemporalData = TemporalData.sharedInstance
    var pConnection: ParseConnection = ParseConnection.sharedInstance
    
    private var activity: MeetingItem?
    var isDataAvailable = false

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //para que las celdas se ajusten al tamaño del texto.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        addCommentButton.enabled = false
        
        temporalComments.removeAll()
        newComments.removeAll()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        loadActivity()
        
        //Para el textView inferior...
        setTextView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotifications()

    }
    
    
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            // Back btn Event handler
            pConnection.saveAllInBackground(newComments, completion: { (succeded, error) -> () in
                //TODO: hacer algo si no se guarda el comentario.
            })
        }
    }
    

    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if activity != nil {
            return 6
        }else{
            return 1
        }
    }
    

    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 5 {
            return true
        }else {
            return false
        }
    }

    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let commentForDelete = temporalComments.removeAtIndex(indexPath.row)
            if let index = newComments.getIndexForComment(commentForDelete) {
                newComments.removeAtIndex(index)
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "cellDetailActivity"
        let cellDueDate = "cellDueDateActivity"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)!
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = activity?.Detail
        case 1:
            cell.textLabel?.text = (activity?.DateItem.dateToString() as! String)
        case 2:
            let cellDate = tableView.dequeueReusableCellWithIdentifier(cellDueDate) as! DueDateViewCell
            cellDate.labelDueDate.text = (activity?.DueDate.dateToString() as! String)
            if activity!.DueDate.isLessThanDate(NSDate() ) {
                cellDate.imageViewTime.image  = UIImage(named: "timeRed")
            }else{
                cellDate.imageViewTime.image  = UIImage(named: "timeGreen")
            }
            return cellDate
        case 3:
            cell.textLabel?.text = activity?.State.Name
        case 4:
            let responsibilities = activity?.Responsibilities
            let responsibility = responsibilities![indexPath.row]
            if (responsibility.ContactId != nil) && (responsibility.RolTarea != nil) {
                cell.textLabel!.text = "\(responsibility.ContactId!.Name)  \(responsibility.ContactId!.LastName) (\(responsibility.RolTarea!.Name))"
            }
            
        case 5:
            let comments = temporalComments
            cell.textLabel?.text = comments[indexPath.row]
        default:
            cell.textLabel!.text = "No se obtuvo información."
        }
        
        return cell
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 4:
            return (activity?.Responsibilities.count)!
        case 5:
            return temporalComments.count
        default:
            return 1
        }
        
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Eliminar"
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // Gets the header view as a UITableViewHeaderFooterView and changes the text colour
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1)
    }

    //MARK: - Funciones
    func loadActivity(){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            if let actividad = self.tmpData.actividad {
                var available: Bool = false
                for responsibility in actividad.Responsibilities {
                    if let contact = responsibility.ContactId,
                        let rol = responsibility.RolTarea {
                        if contact.dataAvailable && rol.dataAvailable {
                            available = true
                        }else{
                            available = false
                            break
                        }
                    }
                }
                
                if !available {
                    actividad.fetchContacts()
                    self.setActivity()
                }else{
                    self.setActivity()
                }
            }
        }
    }
    
    func setActivity(){
        self.activity = self.tmpData.actividad
        self.temporalComments = self.activity!.Comments
        self.isDataAvailable = true
        dispatch_async(dispatch_get_main_queue() ) {
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Selector for Notification Keyboard and delegates
    func addNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    dynamic func keyboardWillShow(notification: NSNotification) {
        if let newHeight = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
            
            UIView.animateWithDuration(0.5, delay: 1.0, options: UIViewAnimationOptions.TransitionCurlUp, animations: { () -> Void in
                self.inputContainerViewBottom.constant = newHeight
            }, completion: nil)
        }
    }
    
    dynamic func keyboardWillHide(notification: NSNotification) {
        self.inputContainerViewBottom.constant = 0.0
    }
    
    func setTextView(){

        self.growingTextView.layer.cornerRadius = 4
        self.growingTextView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: placeholder)
        
        //Delegates:
        growingTextView.delegates.textViewDidEndEditing = {
            (growingTextView: NextGrowingTextView) in
            // Do something
            self.addCommentButton.enabled = false
            self.growingTextView.text = ""
            self.growingTextView.placeholderAttributedText = NSAttributedString(string: self.placeholder)
        }
        
        growingTextView.delegates.shouldChangeTextInRange = { (range: NSRange, replacementText: String) -> Bool in
            // Figure out what the new text will be, if we return true
            var newText: NSString = self.growingTextView.text!
            newText = newText.stringByReplacingCharactersInRange(range, withString: replacementText)
            
            // the button enabled to false if the newText will be an empty string
            self.addCommentButton.enabled = (newText.length != 0)
            
            return true
        }
        
    }
    
    @IBAction func handleSendButton(sender: AnyObject) {
        let comentario = checkTimeStamp(growingTextView.text )
        temporalComments.append(comentario)
        if let actividad = activity{
            newComments.append(CommentsApproval(Comment: comentario, ContactId: tmpData.contacto!, contract: tmpData.contrato!, mItem: actividad) )
        }
        
        tableView.reloadSections(NSIndexSet(index: 5), withRowAnimation: .Automatic)

        self.growingTextView.resignFirstResponder()
    }
    
    ///comprobar si ya existe una fecha en el comentario para no agregar otra fecha:
    func checkTimeStamp(comment: String) -> String{
        var newComment = ""
        //1) se prepara la comprobación
        //si la cant. de caracteres es menor a: "yyyy-MM-dd HH:mm:ss"
        if comment.characters.count <= 18 {
            newComment = convertDateToTimestamp(NSDate() ) + comment
        }
        else{
            let indexRange = comment.startIndex.advancedBy(19)
            let subcomment = comment.substringToIndex(indexRange)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            //2) se realiza la comprobación de fecha en el comentario:
            if dateFormatter.dateFromString(subcomment) == nil {
                newComment = convertDateToTimestamp(NSDate() ) + comment
            }
            else{
                newComment = comment
            }
        }
        
        return newComment
    }
    
    //mark Date function
    func convertDateToTimestamp(fecha: NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss - "
        let timeStamp = dateFormatter.stringFromDate(fecha)
        return timeStamp
    }

}
