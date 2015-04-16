//
//  ViewController.swift
//  TasksToday
//
//  Created by Shachar Udi on 4/7/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import UIKit
import CoreData
import StoreKit
import GoogleMobileAds


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, SKStoreProductViewControllerDelegate {
    
    // MARK - Constant Definitions
    let TASK_ROW_HEIGHT  : CGFloat = 45.0
    let MAIN_MENU_HEIGHT : CGFloat = 200.0
    let TOP_BAR_HEIGHT : CGFloat = 65.0

    //----------------------------------

    
    // MARK: - Storyboard IBOutlets
    //IBOutlets ------------------------
    
    @IBOutlet weak var topMenuButton: UIButton!
    @IBOutlet weak var toolbarDateLabel: UILabel!
    @IBOutlet weak var todayTasksTableView: UITableView!
    
    
    
    
    
    
    //----------------------------------
    
    
    // MARK: - Storyboard IBActions
    //IBActions ------------------------
    
    @IBAction func tappedMenuBtn(sender: AnyObject) {
        if (!self.menuIsOpen) {
            toggleMenu(true)
        }
        else {
            toggleMenu(false)
        }
    }
    
    @IBAction func tappedNewTaskBtn(sender: AnyObject) {
        if (self.menuIsOpen == true) {
            self.toggleMenu(false)
        }
    }
    
    //----------------------------------
    
    
    // MARK: - App Data Models
    //Data Models ------------------------
    let tasksModel = TasksModel()
    let appColors = AppColors()
    //----------------------------------

    
    
    // MARK: - Class Variables
    var tasksDB = NSMutableDictionary()
    var FRController: NSFetchedResultsController!
    var mainMenuView, menuBGView: UIView!
    var menuIsOpen = false
    var allowCheckmark = true
    var selectedIndexPath = NSIndexPath()
    var editIcon = UIImage(named: "EditCell")
    var trashIcon = UIImage(named: "TrashCell")

    //----------------------------------
    
    
    // MARK: - Tableview Methods
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "", handler:{action, indexpath in
        })
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "", handler:{action, indexpath in
            self.promtToDelete(indexPath)
        })
        moreRowAction.backgroundColor = UIColor(patternImage: editIcon!)
        deleteRowAction.backgroundColor = UIColor(patternImage: trashIcon!)
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
        var sectionTitle = "Completed"
        if (sectionInfo.indexTitle == "1") {
            sectionTitle =  "Completed"
        }
        else {
            sectionTitle =  "In Progress"
        }
        
        var headerView = UIView(frame: CGRectMake(0, 0, self.todayTasksTableView.frame.size.width, 35))
        headerView.backgroundColor = self.appColors.colorForObjectName("tableview_header")
        
        let titleLabel = UILabel(frame: CGRectMake(8, 8, 150, 20))
        titleLabel.text = sectionTitle
        titleLabel.font = UIFont.systemFontOfSize(18)
        titleLabel.textColor = self.appColors.colorForObjectName("section_header_text")
        headerView.addSubview(titleLabel)
        
        
        var tasksCount = sectionInfo.numberOfObjects
        var taskStyle = "Task"
        if (tasksCount > 1) {
            taskStyle = "Tasks"
        }
        var amountText = String(format: "%d %@", tasksCount, taskStyle)
        
        let amountLabel = UILabel(frame: CGRectMake(self.todayTasksTableView.frame.size.width-160, 8, 150, 20))
        amountLabel.text = amountText
        amountLabel.textAlignment = .Right
        amountLabel.textColor = self.appColors.colorForObjectName("tasks_amount_text")
        amountLabel.font = UIFont.systemFontOfSize(18)

        headerView.addSubview(amountLabel)
        
        return headerView
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var taskCell:TasksTodayCell = tableView.dequeueReusableCellWithIdentifier("task_cell", forIndexPath: indexPath) as! TasksTodayCell
        
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
    
    func reloadTodaysTasks() {
        self.FRController = self.tasksModel.getTasksOfDate(NSDate())
        self.todayTasksTableView.reloadData()
    }
    
    func displayTaskWithItem(item: TaskItem) {
        let itemView = self.storyboard?.instantiateViewControllerWithIdentifier("task_view") as! TaskViewController
        itemView.taskDB = item
        itemView.transitioningDelegate = self.transitionManager
        self.presentViewController(itemView, animated: true, completion: nil)
    }
    
    func releaseCheckmark() {
        self.allowCheckmark = true
    }
    
    func toggleCheckmarkForIndexPath(indexPath: NSIndexPath) {
        if var task = self.FRController.objectAtIndexPath(indexPath) as? TaskItem {
            let checkOff = UIImage(named: "CheckOff")
            if let taskCell = self.todayTasksTableView.cellForRowAtIndexPath(indexPath) as? TasksTodayCell {
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
                self.reloadTodaysTasks()
                var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("releaseCheckmark"), userInfo: nil, repeats: false)
            }
        }
    }
    
    func checkButtonPressed(sender: AnyObject) {
        if (self.allowCheckmark == true) {
            let point = sender.convertPoint(CGPointZero, toView: self.todayTasksTableView)
            if let indexPath = self.todayTasksTableView.indexPathForRowAtPoint(point) {
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
        NSNotificationCenter.defaultCenter().postNotificationName("reloadTodaysTasks", object: nil)
    }
    
    
    func initViewController() {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.todayTasksTableView.contentInset = inset //setting padding for table top
        self.toolbarDateLabel.text = tasksModel.getFormattedDayDate(NSDate())
    }
    
    
    
    
    
    // MARK: - Stats Menu
    
    func toggleStatsMenu(shouldOpen: Bool) {
        
    }

    func closeStatsMenu() {
        toggleStatsMenu(false)
    }
    
    
    
    // MARK: - Main Menu
    
    func menuSeperatorInRect(sepRect: CGRect) -> UIView {
        var v = UIView(frame: sepRect)
        v.backgroundColor = appColors.colorForObjectName("menu_seperator")
        return v
    }
    
    func menuIconWithImageNameAndRect(imageName: String, rect: CGRect) -> UIImageView {
        var img = UIImageView(frame: rect)
        img.image = UIImage(named: imageName)
        return img
    }
    
    func menuButtonWithSettings(title: String, rect: CGRect) -> UIButton {
        var btn = UIButton(frame: rect)
        btn.backgroundColor = UIColor.clearColor()
        btn.setTitle(title, forState: .Normal)
        btn.contentHorizontalAlignment = .Left;
        btn.titleLabel!.font = UIFont.systemFontOfSize(20)
        btn.setTitleColor(appColors.colorForObjectName("menu_btn_font_color"), forState: .Normal)
        btn.setTitleColor(appColors.colorForObjectName("menu_btn_font_color"), forState: .Highlighted)
        return btn
    }
    
    func createMainMenu() {
        var bgViewRect = CGRectMake(0, TOP_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)
        
        self.menuBGView = UIView(frame: bgViewRect)
        self.menuBGView.backgroundColor = appColors.getTransparentShade("menu_h_bg")
        self.menuBGView.clipsToBounds = true
        
        let tapRec = UITapGestureRecognizer()
        tapRec.numberOfTapsRequired = 1
        tapRec.addTarget(self, action: "tapCloseMenu")
        self.menuBGView.addGestureRecognizer(tapRec)
        
        self.mainMenuView = UIView(frame: CGRectMake(0, -MAIN_MENU_HEIGHT, self.view.frame.size.width, MAIN_MENU_HEIGHT))
        self.mainMenuView.backgroundColor = UIColor.whiteColor()
        self.menuBGView.addSubview(self.mainMenuView)
        
        var menuWidth = self.menuBGView.frame.size.width
        
        //self.menuBGView.addSubview(menuSeperatorInRect(CGRectMake(0, 0, menuWidth, 1)))
        
        var hisBtn = menuButtonWithSettings("Past List", rect: CGRectMake(40, 0, menuWidth-40, 50))
        hisBtn.addTarget(self, action: "showHistory", forControlEvents: .TouchUpInside)
        self.mainMenuView.addSubview(hisBtn)
        
        self.mainMenuView.addSubview(menuSeperatorInRect(CGRectMake(40, 50, menuWidth, 1)))
        
        var futBtn = menuButtonWithSettings("Future List", rect: CGRectMake(40, 50, menuWidth-40, 50))
        futBtn.addTarget(self, action: "showFuture", forControlEvents: .TouchUpInside)
        self.mainMenuView.addSubview(futBtn)
        
        self.mainMenuView.addSubview(menuSeperatorInRect(CGRectMake(40, 100, menuWidth, 1)))
        
        var statsBtn = menuButtonWithSettings("Stats", rect: CGRectMake(40, 100, menuWidth-40, 50))
        statsBtn.addTarget(self, action: "showStats", forControlEvents: .TouchUpInside)
        self.mainMenuView.addSubview(statsBtn)
        
        self.mainMenuView.addSubview(menuSeperatorInRect(CGRectMake(40, 150, menuWidth, 1)))
        
        
        var morBtn = menuButtonWithSettings("More Apps", rect: CGRectMake(40, 150, menuWidth-40, 50))
        morBtn.addTarget(self, action: "showMore", forControlEvents: .TouchUpInside)
        self.mainMenuView.addSubview(morBtn)

        self.mainMenuView.addSubview(menuIconWithImageNameAndRect("HistoryBtn", rect: CGRectMake(8, 13, 25, 25)))
        self.mainMenuView.addSubview(menuIconWithImageNameAndRect("FutureBtn", rect: CGRectMake(8, 63, 25, 25)))
        self.mainMenuView.addSubview(menuIconWithImageNameAndRect("StoreBtn", rect: CGRectMake(8, 113, 25, 25)))
        self.mainMenuView.addSubview(menuIconWithImageNameAndRect("StoreBtn", rect: CGRectMake(8, 163, 25, 25)))

    }
    
    func tapCloseMenu() {
        self.toggleMenu(false)
    }
    
    func toggleMenu(shouldOpen: Bool) {
        if (shouldOpen) {
            //Open the menu
            self.menuIsOpen = true
            if (self.menuBGView == nil) {
                createMainMenu()
            }
            var currentMenuRect = CGRectMake(0, -MAIN_MENU_HEIGHT, self.view.frame.size.width, MAIN_MENU_HEIGHT)
            
            self.menuBGView.layer.opacity = 0.0
            self.mainMenuView.frame = currentMenuRect
            self.view.addSubview(menuBGView)
            let onImage = UIImage(named: "MenuOn")
            
            UIView.animateWithDuration(0.2, animations: {
                self.menuBGView.alpha = 1.0
                }, completion: {
                    (value: Bool) in
                    
                    currentMenuRect.origin.y = 0
                    UIView.animateWithDuration(0.3, animations: {
                        self.mainMenuView.frame = currentMenuRect
                        }, completion: {
                            (value: Bool) in
                            
                            self.topMenuButton.setImage(onImage, forState: .Normal)
                            self.topMenuButton.setImage(onImage, forState: .Selected)
                    })
            })
        }
        else {
            //Close the menu
            var closedMenu = CGRectMake(0, -MAIN_MENU_HEIGHT, self.view.frame.size.width, MAIN_MENU_HEIGHT)
            let offImage = UIImage(named: "Menu")

            UIView.animateWithDuration(0.3, animations: {
                self.mainMenuView.frame = closedMenu
                }, completion: {
                    (value: Bool) in
                    UIView.animateWithDuration(0.2, animations: {
                        self.menuBGView.alpha = 0.0
                        }, completion: {
                            (value: Bool) in
                            self.menuIsOpen = false
                            self.menuBGView.removeFromSuperview()
                            self.topMenuButton.setImage(offImage, forState: .Normal)
                            self.topMenuButton.setImage(offImage, forState: .Selected)
                    })
            })
        }
    }
    
    func showStats() {
        self.toggleMenu(false)
        let statsView = self.storyboard?.instantiateViewControllerWithIdentifier("stats_view") as! StatsView
        
        statsView.providesPresentationContextTransitionStyle = true
        statsView.definesPresentationContext = true
        statsView.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.presentViewController(statsView, animated: false, completion: nil)

    }
    
    func showHistory() {
        self.toggleMenu(false)
        let hfView = self.storyboard?.instantiateViewControllerWithIdentifier("hf_view") as! HFViewController
        hfView.displayingMode = "history"
        hfView.transitioningDelegate = self.transitionManager
        self.presentViewController(hfView, animated: true, completion: nil)
    }
    
    func showFuture() {
        self.toggleMenu(false)
        let hfView = self.storyboard?.instantiateViewControllerWithIdentifier("hf_view") as! HFViewController
        hfView.displayingMode = "future"
        hfView.transitioningDelegate = self.transitionManager
        self.presentViewController(hfView, animated: true, completion: nil)
    }
    
    func showMore() {
        if ((NSClassFromString("SKStoreProductViewController")) != nil) {
            self.toggleMenu(false)
            var vc: SKStoreProductViewController = SKStoreProductViewController()
            var params = [
                SKStoreProductParameterITunesItemIdentifier:430231491,
            ]
            vc.delegate = self
            vc.loadProductWithParameters(params, completionBlock: nil)
            self.presentViewController(vc, animated: true) { () -> Void in }
        }
    }
    
    
    //||---------------------------------- END CLASS FUNCTIONS SECTION ---------------------------------------||

    
    // MARK: - Product view controller delegate

    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController!) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Event Listeners
    
    func setupEventListeners() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTodaysTasks", name: "reloadTodaysTasks", object: nil)

    }
    
    
    //----------------------------------
    
    //----------------------------------
    
    // MARK: - Alert view delegate
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if (alertView.tag == 1 && buttonIndex == 1) {
            deleteCurrentObject()
        }
    }
    
    
    // MARK: - Tutorial

    
    func initTutorial() {
        let tutorialViewController: TutorialController = self.storyboard?.instantiateViewControllerWithIdentifier("tutorial_controller") as! TutorialController
        self.presentViewController(tutorialViewController, animated: true, completion: nil)
    }
    
    func checkTutorial() {
        var userDef = NSUserDefaults.standardUserDefaults()
        let showTutorial = userDef.boolForKey("show_tutorial")
        if (!showTutorial) {
            initTutorial()
            userDef.setBool(true, forKey: "show_tutorial")
            userDef.synchronize()
        }
    }
    
    //----------------------------------
    
    // MARK: - Transitions
    //Transitions ----------
    
    //Transition Manager
    let transitionManager = TransitionManager()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as! UIViewController
        toViewController.transitioningDelegate = self.transitionManager
    }

    //MARK: Ads
    
    
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
    
    
    
    //----------------------------------

    override func viewDidAppear(animated: Bool) {
        checkTutorial()
    }
    
    // MARK: - ViewController Methods
    //ViewController Methods ----------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEventListeners()
        initViewController()
        setupAds()
        reloadTodaysTasks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //----------------------------------

}












