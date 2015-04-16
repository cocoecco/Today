//
//  TaskViewController.swift
//  TasksToday
//
//  Created by Shachar Udi on 4/8/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController, UIAlertViewDelegate {

    
    // MARK - Constant Definitions
    
    // MARK: - Storyboard IBOutlets

    @IBOutlet weak var toolbarLabel: UILabel!
    @IBOutlet weak var taskPriorityView: UIView!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskTextView: UITextView!
    @IBOutlet weak var markDoneBtn: UIButton!
    
    //----------------------------------
    
    
    
    // MARK: - Storyboard IBActions
    
    
    @IBAction func closeTaskView(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("reloadTodaysTasks", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tappedDone(sender: AnyObject) {
        var alreadyDone = false
        if (self.taskDB.comp == true) {
            alreadyDone = true
        }
        setTaskDoneState(alreadyDone)
    }

    @IBAction func tappedDelete(sender: AnyObject) {
        promtToDelete()
    }
    
    @IBAction func tappedEdit(sender: AnyObject) {
        showEditItem()
    }
    
    //----------------------------------

    
    // MARK: - Class Variables
    var taskDB: TaskItem!
    
    //----------------------------------
    
    
    
    // MARK: - App Data Models
    //Data Models ------------------------
    let tasksModel = TasksModel()
    let appColors = AppColors()
    //----------------------------------
    
    
    // MARK: - Class Functions

    
    
    func setTaskDetails() {
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEE MM/dd"
        var dateStr = dateFormat.stringFromDate(NSDate()) as String
        self.toolbarLabel.text = dateStr
        
        self.taskTitleLabel.text = self.taskDB.task
        self.taskTextView.text = self.taskDB.taskText
        self.taskPriorityView.backgroundColor = appColors.colorForPriority(self.taskDB.priority)
        self.taskPriorityView.layer.cornerRadius = self.taskPriorityView.frame.size.width/2
    
        if (taskDB.comp == true) {
            self.markDoneBtn.setImage(UIImage(named: "CheckmarkBigOn"), forState: .Normal)
        }
        else {
            self.markDoneBtn.setImage(UIImage(named: "CheckmarkBigOff"), forState: .Normal)
        }
    }
    
    func initTaskView() {
        setTaskDetails()
        
        let tapRec = UITapGestureRecognizer()
        tapRec.numberOfTapsRequired = 1
        tapRec.addTarget(self, action: "showEditItem")
        self.taskPriorityView.addGestureRecognizer(tapRec)
    }
    
    func showEditItem() {
        let editView = self.storyboard?.instantiateViewControllerWithIdentifier("new_task_view") as! NewTaskViewController
        editView.editTaskDB = self.taskDB
        editView.isEditingTask = true
        editView.transitioningDelegate = self.transitionManager
        self.presentViewController(editView, animated: true, completion: nil)
    }
    
    func setTaskDoneState(state: Bool) {
        if (state == false) {
            self.taskDB.comp = true
            self.tasksModel.saveEditedTask(self.taskDB)
            self.markDoneBtn.setImage(UIImage(named: "CheckmarkBigOn"), forState: .Normal)
        }
        else if (state == true) {
            self.taskDB.comp = false
            self.tasksModel.saveEditedTask(self.taskDB)
            self.markDoneBtn.setImage(UIImage(named: "CheckmarkBigOff"), forState: .Normal)
        }
    }
    
    
    func promtToDelete() {
        var alertText = "Are you sure you want to delete this task?"
        var alertView = UIAlertView(title: "Delete Task?", message: alertText, delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "Delete")
        alertView.delegate = self
        alertView.show()
    }
    
    func deleteCurrentObject() {
        self.tasksModel.deleteTask(self.taskDB)
        NSNotificationCenter.defaultCenter().postNotificationName("reloadTodaysTasks", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Event Listeners
    
    func setupEventListeners() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setTaskDetails", name: "setTaskDetails", object: nil)
        
    }
    
    
    //----------------------------------
    
    // MARK: - Alert view delegate
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if (buttonIndex == 1) {
            deleteCurrentObject()
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
    
    
    // MARK: - ViewController Methods
    //ViewController Methods ----------

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEventListeners()
        initTaskView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    //----------------------------------

}
