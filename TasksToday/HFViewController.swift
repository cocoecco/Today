//
//  HFViewController.swift
//  TasksToday
//
//  Created by Shachar Udi on 4/10/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class HFViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {

    
    // MARK - Constant Definitions
    //----------------------------------
    let TASK_ROW_HEIGHT  : CGFloat = 45.0

    
    // MARK: - Storyboard IBOutlets
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var tasksTableView: UITableView!

    //----------------------------------
    
    
    // MARK: - Storyboard IBActions
    @IBAction func tappedCloseView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    //----------------------------------
    
    
    // MARK: - App Data Models
    //Data Models ------------------------
    let tasksModel = TasksModel()
    let appColors = AppColors()
    //----------------------------------
    
    
    // MARK: - Class Variables
    var displayingMode = "history"
    var FRController: NSFetchedResultsController!
    var allowCheckmark = true
    var selectedIndexPath = NSIndexPath()
    //----------------------------------

    
    
    // MARK: - Tableview Methods
    //Tableview Methods ----------
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Redo", handler:{action, indexpath in
            self.promtToRedo(indexPath)
        })
        moreRowAction.backgroundColor = UIColor.orangeColor()
        
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            self.promtToDelete(indexPath)
        })
        deleteRowAction.backgroundColor = UIColor.redColor()
        return [deleteRowAction, moreRowAction]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.FRController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.FRController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TASK_ROW_HEIGHT
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if var task = self.FRController.objectAtIndexPath(indexPath) as? TaskItem {
            displayTaskWithItem(task)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionInfo = self.FRController.sections![section] as! NSFetchedResultsSectionInfo
        var indexPath = NSIndexPath(forRow: 0, inSection: section)
        var dateString = "Tasks"
        
        if var task = self.FRController.objectAtIndexPath(indexPath) as? TaskItem {
            var dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "MM/dd/yy"
            dateString = dateFormat.stringFromDate(task.date) as String
        }

        
        var headerView = UIView(frame: CGRectMake(0, 0, self.tasksTableView.frame.size.width, 40))
        headerView.backgroundColor = self.appColors.colorForObjectName("tableview_header")
        
        let titleLabel = UILabel(frame: CGRectMake(8, 10, 150, 20))
        titleLabel.text = dateString
        titleLabel.font = UIFont.systemFontOfSize(18)
        titleLabel.textColor = self.appColors.colorForObjectName("section_header_text")
        headerView.addSubview(titleLabel)
        
        
        var tasksCount = sectionInfo.numberOfObjects
        var taskStyle = "Task"
        if (tasksCount > 1) {
            taskStyle = "Tasks"
        }
        var amountText = String(format: "%d %@", tasksCount, taskStyle)
        
        let amountLabel = UILabel(frame: CGRectMake(self.tasksTableView.frame.size.width-160, 10, 150, 20))
        amountLabel.text = amountText
        amountLabel.textAlignment = .Right
        amountLabel.textColor = self.appColors.colorForObjectName("tasks_amount_text")
        amountLabel.font = UIFont.systemFontOfSize(18)
        
        headerView.addSubview(amountLabel)
        
        return headerView
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var taskCell:HFCell = tableView.dequeueReusableCellWithIdentifier("hfCell", forIndexPath: indexPath) as! HFCell
        
        if var task = self.FRController.objectAtIndexPath(indexPath) as? TaskItem {
            taskCell.taskLabel.text = task.task
            taskCell.priorityView.layer.cornerRadius = taskCell.priorityView.frame.size.width/2
            taskCell.priorityView.backgroundColor = self.appColors.colorForPriority(task.priority)
            taskCell.checkmarkButton.addTarget(self, action: "checkButtonPressed:", forControlEvents: .TouchUpInside)
            
            let checkOff = UIImage(named: "CheckOff")
            let checkOn = UIImage(named: "CheckOn")
            
            taskCell.checkmarkButton.setImage(checkOff, forState: .Normal)
            taskCell.checkmarkButton.setImage(checkOff, forState: .Highlighted)
            
            if (task.comp == true) {
                taskCell.checkmarkButton.setImage(checkOn, forState: .Normal)
                taskCell.checkmarkButton.setImage(checkOn, forState: .Highlighted)
            }
        }
        
        return taskCell
    }
    
    
    //----------------------------------
    
    
    // MARK: - Class Functions
    //||---------------------------------- START CLASS FUNCTIONS SECTION ---------------------------------------||
    
    
    func reloadHistoryTasks() {
        self.FRController = self.tasksModel.getHistoryTasks(NSDate())
        self.tasksTableView.reloadData()
    }

    func reloadFutureTasks() {
        self.FRController = self.tasksModel.getFutureTasks(NSDate())
        self.tasksTableView.reloadData()
    }
    
    func closeHFView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func initHFView() {
        if (self.displayingMode == "history") {
            self.topTitleLabel.text = "Past Tasks"
            reloadHistoryTasks()
        }
        else {
            self.topTitleLabel.text = "Future Tasks"
            reloadFutureTasks()
        }
        
        var swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.addTarget(self, action: "closeHFView")
        swipeGesture.direction = .Right
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    func releaseCheckmark() {
        self.allowCheckmark = true
    }
    
    func toggleCheckmarkForIndexPath(indexPath: NSIndexPath) {
        if var task = self.FRController.objectAtIndexPath(indexPath) as? TaskItem {
            if let taskCell = self.tasksTableView.cellForRowAtIndexPath(indexPath) as? HFCell {
                if (task.comp == false) {
                    //Mark this task as done now
                    task.comp = true
                    let checkOn = UIImage(named: "CheckOn")
                    taskCell.checkmarkButton.setImage(checkOn, forState: .Normal)
                    taskCell.checkmarkButton.setImage(checkOn, forState: .Highlighted)
                }
                else {
                    //Mark this task and NOT done now
                    task.comp = false
                    let checkOff = UIImage(named: "CheckOff")
                    taskCell.checkmarkButton.setImage(checkOff, forState: .Normal)
                    taskCell.checkmarkButton.setImage(checkOff, forState: .Highlighted)
                }
                self.tasksModel.saveEditedTask(task)
                var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("releaseCheckmark"), userInfo: nil, repeats: false)
            }
        }
    }
    
    func checkButtonPressed(sender: AnyObject) {
        if (self.allowCheckmark == true) {
            let point = sender.convertPoint(CGPointZero, toView: self.tasksTableView)
            if let indexPath = self.tasksTableView.indexPathForRowAtPoint(point) {
                self.allowCheckmark = false
                toggleCheckmarkForIndexPath(indexPath)
            }
        }
    }
    
    func promtToDelete(indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
        var alertText = "Are you sure you want to delete this task?"
        var alertView = UIAlertView(title: "Delete Task?", message: alertText, delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "Delete")
        alertView.delegate = self
        alertView.tag = 1
        alertView.show()
    }
    
    func deleteCurrentObject() {
        let task = self.FRController.objectAtIndexPath(self.selectedIndexPath) as! TaskItem
        self.tasksModel.deleteTask(task)
        
        if (self.displayingMode == "history") {
            reloadHistoryTasks()
        }
        else {
            reloadFutureTasks()
        }
    }
    
    func promtToRedo(indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
        var alertText = "Move this task back to Today's list?"
        var alertView = UIAlertView(title: "Redo Task?", message: alertText, delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "Redo")
        alertView.delegate = self
        alertView.tag = 2
        alertView.show()
    }
    
    func redoTask() {
        let task = self.FRController.objectAtIndexPath(self.selectedIndexPath) as! TaskItem
        task.date = NSDate()
        self.tasksModel.saveEditedTask(task)
        NSNotificationCenter.defaultCenter().postNotificationName("reloadTodaysTasks", object: nil)

        
        if (self.displayingMode == "history") {
            reloadHistoryTasks()
        }
        else {
            reloadFutureTasks()
        }
    }
    
    
    func displayTaskWithItem(item: TaskItem) {
        let itemView = self.storyboard?.instantiateViewControllerWithIdentifier("task_view") as! TaskViewController
        itemView.taskDB = item
        itemView.transitioningDelegate = self.transitionManager
        self.presentViewController(itemView, animated: true, completion: nil)
    }
    
    //||---------------------------------- END CLASS FUNCTIONS SECTION ---------------------------------------||

    
    //----------------------------------
    
    // MARK: - Alert view delegate
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if (alertView.tag == 1 && buttonIndex == 1) {
            deleteCurrentObject()
        }
        else if (alertView.tag == 2 && buttonIndex == 1) {
            redoTask()
        }
    }
    
    
    //----------------------------------
    
    //Transition Manager
    let transitionManager = TransitionManager()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as! UIViewController
        toViewController.transitioningDelegate = self.transitionManager
    }
    
    //----------------------------------
    // MARK: - Ads Methods

    
    func setupAds() {
        var adView = GADBannerView()
        adView.adUnitID = "ca-app-pub-3825073358484269/1892706239"
        adView.rootViewController = self
        
        adView.frame = CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)
        
        var req:GADRequest = GADRequest()
        //req.testDevices = ["52438423b0f4fcfa1866a25760450896"]
        adView.loadRequest(req)
        self.view.addSubview(adView)
    }
    
    // MARK: - ViewController Methods
    //ViewController Methods ----------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initHFView()
        setupAds()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //----------------------------------


}
