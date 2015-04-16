//
//  NewTaskViewController.swift
//  TasksToday
//
//  Created by Shachar Udi on 4/7/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import UIKit

class NewTaskViewController: UIViewController, UITextFieldDelegate {

    // MARK - Constant Definitions
    let PRIO_BTN_BORDER_WIDTH: CGFloat = 3.0
    
    // MARK: - Storyboard IBOutlets
    //IBOutlets ------------------------
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var taskDateTextField: UITextField!
    @IBOutlet weak var taskTextView: UITextView!
    
    @IBOutlet weak var priorityBtn0: UIButton!
    @IBOutlet weak var priorityBtn1: UIButton!
    @IBOutlet weak var priorityBtn2: UIButton!
    @IBOutlet weak var priorityBtn3: UIButton!
    
    @IBOutlet weak var keyboardView: UIView!
    
    //----------------------------------

    
    
    // MARK: - Storyboard IBActions
    //IBActions ------------------------
    
    @IBAction func tappedSetDate(sender: AnyObject) {
        self.dismissKeyboard()
        setTaskDate()
    }
    
    @IBAction func tappedDone(sender: AnyObject) {
        checkValidTask()
    }
    
    @IBAction func tappedCancel(sender: AnyObject) {
        self.dismissKeyboard()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tappedPriority(sender: AnyObject) {
        if let btn = sender as? UIButton {
            resetAllPriorityButtons()
            btn.layer.borderColor = UIColor.blackColor().CGColor
            btn.layer.borderWidth = PRIO_BTN_BORDER_WIDTH
            setCurrentItemPriority(btn.tag)
        }
    }
    
    
    
    // MARK: - Class Variables
    //Class Variables ------------------------
    var taskDate = NSDate()
    var itemPriority: Double = 0.0
    var editTaskDB: TaskItem!
    var isEditingTask = false
    //----------------------------------
    
    //----------------------------------

    
    // MARK: - App Data Models
    //Data Models ------------------------
    let tasksModel = TasksModel()
    let appColors = AppColors()
    //----------------------------------
    
    
    // MARK: - Class Functions
    //Class Functions ----------
    
    func saveNewTaskAndClose(taskItem: NSDictionary) {
        self.tasksModel.saveNewTask(taskItem)
        NSNotificationCenter.defaultCenter().postNotificationName("reloadTodaysTasks", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveEditedTaskAndClose(taskItem: TaskItem) {
        self.tasksModel.saveEditedTask(taskItem)
        NSNotificationCenter.defaultCenter().postNotificationName("reloadTodaysTasks", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("setTaskDetails", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkValidTask() {
        if (count(self.taskTextField.text) == 0) {
            var alertText = "Looks like you forgot adding your task..."
            var alertView = UIAlertView(title: "Empty Task?", message: alertText, delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return
        }
        self.dismissKeyboard()
        
        if (self.isEditingTask == false) {
            //New Task
            var taskItem = NSMutableDictionary()
            taskItem.setObject(self.taskTextField.text, forKey: "task")
            taskItem.setObject(self.taskDate, forKey: "date")
            taskItem.setObject(self.taskTextView.text, forKey: "taskText")
            taskItem.setObject(false, forKey: "comp")
            taskItem.setObject(self.itemPriority, forKey: "priority")
            saveNewTaskAndClose(NSDictionary(dictionary: taskItem))
        }
        else {
            //Edited Task
            self.editTaskDB.task = self.taskTextField.text
            self.editTaskDB.date = self.taskDate
            self.editTaskDB.taskText = self.taskTextView.text
            //comp already changed
            self.editTaskDB.priority = self.itemPriority
            saveEditedTaskAndClose(self.editTaskDB)
        }

    }
    
    func setTaskDate() {
        self.taskDateTextField.becomeFirstResponder()
    }
    
    func updateTaskDateTextField(sender: UIDatePicker) {
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEE MM/dd"
        var dateStr = dateFormat.stringFromDate(sender.date) as String
        self.taskDateTextField.text = dateStr
        self.taskDate = sender.date
    }
    
    func dismissKeyboard() {
        self.taskDateTextField.resignFirstResponder()
        self.taskTextField.resignFirstResponder()
    }
    
    func loadEditingItem() {
        var taskDate = self.editTaskDB.date as NSDate
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEE MM/dd"
        var dateStr = dateFormat.stringFromDate(taskDate) as String
        self.taskDateTextField.text = dateStr
        
        var task = self.editTaskDB.task as String
        var taskText = self.editTaskDB.taskText as String
        
        self.taskTextField.text = task
        self.taskTextView.text = taskText
        
        resetAllPriorityButtons()
        var priority = self.editTaskDB.priority as Double
        self.itemPriority = priority
        
        if (priority == 0.0) {
            self.priorityBtn0.layer.borderWidth = PRIO_BTN_BORDER_WIDTH
            self.priorityBtn0.layer.borderColor = UIColor.blackColor().CGColor
        }
        else if (priority == 1.0) {
            self.priorityBtn1.layer.borderWidth = PRIO_BTN_BORDER_WIDTH
            self.priorityBtn1.layer.borderColor = UIColor.blackColor().CGColor
        }
        else if (priority == 2.0) {
            self.priorityBtn2.layer.borderWidth = PRIO_BTN_BORDER_WIDTH
            self.priorityBtn2.layer.borderColor = UIColor.blackColor().CGColor
        }
        else if (priority == 3.0) {
            self.priorityBtn3.layer.borderWidth = PRIO_BTN_BORDER_WIDTH
            self.priorityBtn3.layer.borderColor = UIColor.blackColor().CGColor
        }
    }
    
    func initNewTaskView() {
        var datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.addTarget(self, action: "updateTaskDateTextField:", forControlEvents: .ValueChanged)
        self.taskDateTextField.inputView = datePicker
        
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEE MM/dd"
        var dateStr = dateFormat.stringFromDate(NSDate()) as String
        self.taskDateTextField.text = dateStr
        self.taskTextField.becomeFirstResponder()
        
        resetAllPriorityButtons()
        applyPriorityColors()
        
        self.priorityBtn0.layer.borderWidth = PRIO_BTN_BORDER_WIDTH
        self.priorityBtn0.layer.borderColor = UIColor.blackColor().CGColor

        if (self.isEditingTask == true) {
            loadEditingItem()
        }
        
        self.keyboardView.removeFromSuperview()
        self.taskDateTextField.inputAccessoryView = self.keyboardView
        self.taskTextView.inputAccessoryView = self.keyboardView
        self.taskTextField.inputAccessoryView = self.keyboardView
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 5, 20))
        self.taskTextField.leftView = paddingView
        self.taskTextField.leftViewMode = .Always
        let color = appColors.colorForObjectName("section_header_text")
        let attributesDictionary = [NSForegroundColorAttributeName: color]
        self.taskTextField.attributedPlaceholder = NSAttributedString(string: "Add Title", attributes: attributesDictionary)
    }
    
    func applyPriorityColors() {
        self.priorityBtn0.backgroundColor = appColors.colorForPriority(0.0)
        self.priorityBtn1.backgroundColor = appColors.colorForPriority(1.0)
        self.priorityBtn2.backgroundColor = appColors.colorForPriority(2.0)
        self.priorityBtn3.backgroundColor = appColors.colorForPriority(3.0)
    }
    
    func resetAllPriorityButtons() {
        self.priorityBtn0.layer.borderWidth = 0
        self.priorityBtn1.layer.borderWidth = 0
        self.priorityBtn2.layer.borderWidth = 0
        self.priorityBtn3.layer.borderWidth = 0
        
        self.priorityBtn0.layer.cornerRadius = self.priorityBtn0.frame.size.width/2
        self.priorityBtn1.layer.cornerRadius = self.priorityBtn1.frame.size.width/2
        self.priorityBtn2.layer.cornerRadius = self.priorityBtn2.frame.size.width/2
        self.priorityBtn3.layer.cornerRadius = self.priorityBtn3.frame.size.width/2

    }
    
    func setCurrentItemPriority(priorityTag: Int) {
        let priority = Double(priorityTag)
        self.itemPriority = priority
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
        initNewTaskView()
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //----------------------------------


}











