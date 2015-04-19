//
//  SendView.swift
//  TasksToday
//
//  Created by Shachar Udi on 4/16/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class SendView: UIViewController, UIAlertViewDelegate {

    // MARK - Constant Definitions
    //----------------------------------
    
    // MARK: - Storyboard IBOutlets
    
    @IBOutlet weak var shareTableView: UITableView!
    
    //----------------------------------
    
    
    
    
    // MARK: - Storyboard IBActions
    
    @IBAction func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createURL(sender: AnyObject) {
        tappedGenerateURL()
    }
    
    
    //----------------------------------
    
    
    
    
    // MARK: - Class Variables
    let TASK_ROW_HEIGHT  : CGFloat = 45.0
    var FRController: NSFetchedResultsController!
    var selectedTasks = NSMutableArray()
    var allowCheckmark = true
    //----------------------------------

    // MARK: - App Data Models
    let tasksModel = TasksModel()
    let appColors = AppColors()
    //----------------------------------

 
    // MARK: - Event Listeners
    //----------------------------------

    //Transition Manager
    //----------------------------------

    // MARK: - Tableview Methods
    
    
    
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
        if (self.allowCheckmark == true) {
            toggleCheckmarkForIndexPath(indexPath)
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var taskCell:SendCell = tableView.dequeueReusableCellWithIdentifier("send_cell", forIndexPath: indexPath) as! SendCell
        
        if var task = self.FRController.objectAtIndexPath(indexPath) as? TaskItem {
            taskCell.taskLabel.text = task.task
            taskCell.checkmarkBtn.addTarget(self, action: "checkButtonPressed:", forControlEvents: .TouchUpInside)
            
            
            let checkOff = UIImage(named: "CheckOff")
            let checkOn = UIImage(named: "CheckOn")
            
            taskCell.checkmarkBtn.setImage(checkOff, forState: .Normal)
            taskCell.checkmarkBtn.setImage(checkOff, forState: .Highlighted)
            
            for (var i=0;i<self.selectedTasks.count;i++) {
                var selIndexPath = self.selectedTasks.objectAtIndex(i) as! NSIndexPath
                if (selIndexPath == indexPath) {
                    taskCell.checkmarkBtn.setImage(checkOn, forState: .Normal)
                    taskCell.checkmarkBtn.setImage(checkOn, forState: .Highlighted)
                }
            }
            
            
        }
        
        return taskCell
    }
    
    
    //----------------------------------
    
    
    // MARK: - Class Functions
    
    func reloadTodaysTasks() {
        self.FRController = self.tasksModel.getTasksOfDate(NSDate())
        self.shareTableView.reloadData()
    }
    
    func checkButtonPressed(sender: AnyObject) {
        if (self.allowCheckmark == true) {
            let point = sender.convertPoint(CGPointZero, toView: self.shareTableView)
            if let indexPath = self.shareTableView.indexPathForRowAtPoint(point) {
                toggleCheckmarkForIndexPath(indexPath)
            }
        }
    }
    
    func alreadySelected(indexPath: NSIndexPath) -> Bool {
        for (var i=0;i<self.selectedTasks.count;i++) {
            var selIndexPath = self.selectedTasks.objectAtIndex(i) as! NSIndexPath
            if (selIndexPath == indexPath) {
                return true
            }
        }
        return false
    }
    
    func releaseCheckmark() {
        self.allowCheckmark = true
    }
    
    func toggleCheckmarkForIndexPath(indexPath: NSIndexPath) {
        if var task = self.FRController.objectAtIndexPath(indexPath) as? TaskItem {
            let checkOff = UIImage(named: "CheckOff")
            if let taskCell = self.shareTableView.cellForRowAtIndexPath(indexPath) as? SendCell {
                self.allowCheckmark = false

                if (alreadySelected(indexPath) == false) {
                    let checkOn = UIImage(named: "CheckOn")
                    taskCell.checkmarkBtn.setImage(checkOn, forState: .Normal)
                    taskCell.checkmarkBtn.setImage(checkOn, forState: .Highlighted)
                    self.selectedTasks.addObject(indexPath)
                }
                else {
                    let checkOff = UIImage(named: "CheckOff")
                    taskCell.checkmarkBtn.setImage(checkOff, forState: .Normal)
                    taskCell.checkmarkBtn.setImage(checkOff, forState: .Highlighted)
                    self.selectedTasks.removeObject(indexPath)
                }
                
                self.tasksModel.saveEditedTask(task)
                self.reloadTodaysTasks()
                var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("releaseCheckmark"), userInfo: nil, repeats: false)
            }
        }
    }
    
    
    //MARK: Create URL Process
    
    
    
    func keyGenerated(key: String) {
        var alertText = "A URL Key has successfully generated and copied into your pastboard.\nThis key will be available\nfor the next 7 days."
        var alertView = UIAlertView(title: "Share Tasks", message: alertText, delegate: nil, cancelButtonTitle: "Ok")
        alertView.delegate = self
        
        UIPasteboard.generalPasteboard().string = key
        
        alertView.show()
    }
    
    func failedToGenerate() {
        var alertText = "Something went wrong..\nUnable to share tasks at the moment.\nPlease check your internet connection and try again"
        var alertView = UIAlertView(title: "Share Tasks", message: alertText, delegate: nil, cancelButtonTitle: "Ok")
        alertView.show()
    }
    
    
    func randomString() -> String {
        var rnd = "XYZ111YEKE" as String
        let alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789" as String
        var mString = NSMutableString(capacity: 12)
        for (var i: NSInteger = 0;i<12;i++) {
            let k = Int(arc4random_uniform(60))
            let index = advance(alphabet.startIndex, k)
            var c = alphabet[index] as Character
            rnd.append(c)
        }
        return rnd
    }
    
    func convertCoreDataToArray(dataArray: NSArray) -> NSArray {
        var itemsToShare = NSMutableArray()
        for (var i=0;i<self.selectedTasks.count;i++) {
            var indexPath = self.selectedTasks.objectAtIndex(i) as! NSIndexPath
            var item = self.FRController.objectAtIndexPath(indexPath) as! TaskItem
            
            var pItem = NSMutableDictionary()
            pItem.setObject(item.comp, forKey: "comp")
            pItem.setObject(item.date, forKey: "date")
            pItem.setObject(item.priority, forKey: "priority")
            pItem.setObject(item.task, forKey: "task")
            pItem.setObject(item.taskText, forKey: "taskText")

            itemsToShare.addObject(pItem)
        }
        return NSArray(array: itemsToShare)
    }
    
    func tappedGenerateURL() {
        if (self.selectedTasks.count == 0) {
            var alertText = "Looks like you forgot to\nselect tasks to share..."
            var alertView = UIAlertView(title: "Share Tasks", message: alertText, delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
        else {

            var key = randomString()
            if let installation = PFInstallation.currentInstallation() as PFInstallation? {
                var obj = PFObject(className: "SendTasks")
                var plainItems = convertCoreDataToArray(NSArray(array: self.selectedTasks))
                
                obj.addObject(plainItems, forKey: "items")
                obj.addObject(key, forKey: "secret")
                
                obj.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        self.keyGenerated(key)
                    } else {
                        println("%@", error!)
                    }
                }
                
            }
            
        }
    }
    
    
    func initSendTasks() {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.shareTableView.contentInset = inset //setting padding for table top
    }
    
    
    // MARK: - Alert view delegate
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //----------------------------------
    
    
    //MARK: Ads
    
    
    func setupAds() {
        var adView = GADBannerView()
        adView.adUnitID = "***"
        adView.rootViewController = self
        
        adView.frame = CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)
        
        var req:GADRequest = GADRequest()
        //req.testDevices = ["52438423b0f4fcfa1866a25760450896"]
        adView.loadRequest(req)
        self.view.addSubview(adView)
    }
    
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadTodaysTasks()
        initSendTasks()
        setupAds()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //----------------------------------



}
