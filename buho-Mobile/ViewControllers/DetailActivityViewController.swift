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
    
    private var refresher: UIRefreshControl!
    
    private let placeholder = "Ingrese un nuevo comentario..."
    

    private var temporalCommentsApproval: [CommentsApproval] = []
    private var commentsFromParse: [CommentsApproval] = []

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
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        
        tableView.addSubview(refresher)
        
        
        activityIndicator.hidesWhenStopped = true
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
            temporalCommentsApproval.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "cellDetailActivity"
        let cellDueDate = "cellDueDateActivity"
        let cellComment = "cellComment"
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
            let cellComment = tableView.dequeueReusableCellWithIdentifier(cellComment) as! CommentViewCell
            let comments = temporalCommentsApproval
            cellComment.dateLabel.text = comments[indexPath.row].Comment.getDateFromString()
            cellComment.commentLabel.text = comments[indexPath.row].Comment.getStringWithoutDate()!
            
            if comments[indexPath.row].Approved == 0 {
                cellComment.labelApproved.hidden = false
            }else {
                cellComment.labelApproved.hidden = true
            }
            
            
            return cellComment
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
            return temporalCommentsApproval.count
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
        if !self.refresher.refreshing {
            activityIndicator.startAnimating()
        }
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
                    self.setActivity(actividad)
                }else{
                    self.setActivity(actividad)
                }
                
            }else{
                dispatch_async(dispatch_get_main_queue() ) {
                    let alertView = UIAlertController(title: "Hubo un error al cargar la actividad.", message: "Intente de nuevo por favor.", preferredStyle: .Alert)
                    alertView.view.tintColor = UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1)
                    
                    let aceptar = UIAlertAction(title: "Acpetar", style: .Default, handler: { (action: UIAlertAction) -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                    alertView.addAction(aceptar)
                    
                    self.presentViewController(alertView, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setActivity(actividad: MeetingItem){
        
        activity = actividad
        temporalCommentsApproval.removeAll(keepCapacity: false)
        commentsFromParse.removeAll(keepCapacity: false)
        
        pConnection.getCommentsApproval(actividad, completion: { (succeded, error, comments) -> () in
            
            if succeded {
                if comments!.count > 0 {
                    self.commentsFromParse = comments!
                }
            }
            
            for com in actividad.Comments {
                let commentApproval = CommentsApproval(Comment: com, ContactId: self.tmpData.contacto!, contract: self.tmpData.contrato!, mItem: actividad, Approved: 1)
                self.temporalCommentsApproval.append(commentApproval)
            }
            
            dispatch_async(dispatch_get_main_queue() ) {
            
                self.temporalCommentsApproval += self.commentsFromParse
                
                self.temporalCommentsApproval.sortInPlace({ (c1: CommentsApproval, c2: CommentsApproval) -> Bool in
                    timeStampOfString(c1.Comment).isGreaterThanDate(timeStampOfString(c2.Comment))
                })
            
            
                self.reloadTable()
            }
            
            
        })
        
    }
    
    func reloadTable(){
        isDataAvailable = true
        dispatch_async(dispatch_get_main_queue() ) {
            self.activityIndicator.stopAnimating()
            
            if self.refresher.refreshing {
                self.refresher.endRefreshing()
            }
            
            self.tableView.reloadData()
        }
    }
    
    func refresh(){
        if activity  != nil {
            loadActivity()
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
        let attributes = [
            NSStrokeColorAttributeName : UIColor.grayColor(),
            NSForegroundColorAttributeName: UIColor.grayColor(),
            NSStrokeWidthAttributeName : -3.0
        ]
        
        growingTextView.placeholderAttributedText = NSAttributedString(string: self.placeholder, attributes: attributes)
        
        //Delegates:
        growingTextView.delegates.textViewDidEndEditing = {
            (growingTextView: NextGrowingTextView) in
            // Do something
            self.addCommentButton.enabled = false
            self.growingTextView.text = ""
            growingTextView.placeholderAttributedText = NSAttributedString(string: self.placeholder, attributes: attributes)
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
         // append(comentario)
        if let actividad = activity{
            let comentario = checkTimeStamp(growingTextView.text )
            
            let commentApproval = CommentsApproval(Comment: comentario, ContactId: tmpData.contacto!, contract: tmpData.contrato!, mItem: actividad)
            
            temporalCommentsApproval.insert(commentApproval,atIndex:  0)
            commentApproval.saveInBackground()

            
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            
            tableView.reloadSections(NSIndexSet(index: 5), withRowAnimation: .Automatic)
            
        }
        
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
