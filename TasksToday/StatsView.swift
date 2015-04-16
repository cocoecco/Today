//
//  StatsView.swift
//  TasksToday
//
//  Created by Shachar Udi on 4/14/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import UIKit

class StatsView: UIViewController {
    
    // MARK - Constant Definitions
    let MENU_HEIGHT:CGFloat = 400.0 //Height of the menu
    let SV_ROUND_NUM:CGFloat = 10.0 //Corner radius of stats background views

    //----------------------------------
    
    // MARK: - Storyboard IBOutlets
    //----------------------------------
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuBGView: UIView!
    
    @IBOutlet weak var SVWeekdaysView: UIView!
    @IBOutlet weak var SVBGDaily: UIView!
    @IBOutlet weak var SVBGTotal: UIView!
    @IBOutlet weak var SVBGW1: UIView! //Sunday
    @IBOutlet weak var SVBGW2: UIView!
    @IBOutlet weak var SVBGW3: UIView!
    @IBOutlet weak var SVBGW4: UIView!
    @IBOutlet weak var SVBGW5: UIView!
    @IBOutlet weak var SVBGW6: UIView!
    @IBOutlet weak var SVBGW7: UIView! //Saturday
    
    @IBOutlet weak var SVDailyPerce: UILabel!
    @IBOutlet weak var SVTotalPerce: UILabel!
    
    // MARK: - Storyboard IBActions
    //----------------------------------
    
    
    
    // MARK: - Class Variables
    var taskDB: TaskItem!
    var menuIsOpen = false
    var menuOpenAnimationCompleted = false
    var statsPopulated = false
    var statsDaily = NSDictionary()
    var statsTotal = NSDictionary()
    var statsWeekly = NSDictionary()
    var statsTimer = NSTimer()
    
    //----------------------------------
    
    
    
    // MARK: - App Data Models
    let tasksModel = TasksModel()
    let appColors = AppColors()
    //----------------------------------

    
    // MARK: - Event Listeners
    //----------------------------------
    // MARK: - Alert view delegate
    
    
    
    
    
    



    // MARK: - Class Functions

    
    
    
    // MARK: - 'Menu' View Functions

    
    func fadeOutAndClose() {
        UIView.animateWithDuration(0.2, animations: {
            self.menuBGView.layer.opacity = 0.0
            }, completion: {
                (value: Bool) in
                if (value == true) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
        })
    }
    
    func closeMenuAnimation() {
        self.menuOpenAnimationCompleted = false

        var closedRect = CGRectMake(0, -MENU_HEIGHT, self.view.frame.size.width, self.MENU_HEIGHT)
        UIView.animateWithDuration(0.4, animations: {
            self.menuView.frame = closedRect
            }, completion: {
                (value: Bool) in
                if (value == true) {
                    self.fadeOutAndClose()
                }
        })
    }
    
    func openMenuAnimation() {
        self.menuIsOpen = true
        
        var openedRect = CGRectMake(0, 0, self.view.frame.size.width, self.MENU_HEIGHT)
        UIView.animateWithDuration(0.4, animations: {
            self.menuView.frame = openedRect
            }, completion: {
                (value: Bool) in
                self.menuOpenAnimationCompleted = true
                self.statsTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("checkPopulated"), userInfo: nil, repeats: true)
        })
    }

    
    func revealBGOnViewAppear() {
        self.menuView.frame = CGRectMake(0, -MENU_HEIGHT, self.view.frame.size.width, MENU_HEIGHT)
        self.menuOpenAnimationCompleted = false

        UIView.animateWithDuration(0.6, animations: {
            self.menuBGView.layer.opacity = 1.0
            }, completion: {
                (value: Bool) in
                if (value == true) {
                    self.openMenuAnimation()
                }
        })
    }
    

    
    func roundSVBGS() {
        self.SVBGDaily.layer.cornerRadius = SV_ROUND_NUM
        self.SVBGTotal.layer.cornerRadius = SV_ROUND_NUM
        self.SVBGW1.layer.cornerRadius = SV_ROUND_NUM
        self.SVBGW2.layer.cornerRadius = SV_ROUND_NUM
        self.SVBGW3.layer.cornerRadius = SV_ROUND_NUM
        self.SVBGW4.layer.cornerRadius = SV_ROUND_NUM
        self.SVBGW5.layer.cornerRadius = SV_ROUND_NUM
        self.SVBGW6.layer.cornerRadius = SV_ROUND_NUM
        self.SVBGW7.layer.cornerRadius = SV_ROUND_NUM
    }
    
    
    

    
    func statViewInLandscapeRect(rectBounds: CGRect, type: String) -> UIView {
        var statRect = rectBounds
        statRect.origin.x += 2
        statRect.origin.y += 2
        statRect.size.width = 0
        statRect.size.height -= 4
        
        var v = UIView(frame: statRect)
        v.layer.cornerRadius = SV_ROUND_NUM
        v.backgroundColor = self.appColors.colorForType(type)
        return v
    }
    
    func expendHorizontalStatViewToRect(statView: UIView, width: CGFloat) {
        var viewRect = statView.frame
        viewRect.size.width = width
        
        UIView.animateWithDuration(0.6, animations: {
            statView.frame = viewRect
            }, completion: {
                (value: Bool) in
                if (value == true) {
                }
        })
    }
    
    func expendPortraitStatViewToRect(statView: UIView, height: CGFloat) {
        var viewRect = statView.frame
        viewRect.size.height = height
        
        var orgY = viewRect.origin.y
        
        UIView.animateWithDuration(0.6, animations: {
            statView.frame = CGRectMake(statView.frame.origin.x, orgY-height, statView.bounds.size.width, height);
            
            }, completion: {
                (value: Bool) in
                if (value == true) {
                }
        })
    }
    
    
    func pxHotizonatlValue(hostView: UIView, perce: CGFloat) -> CGFloat {
        var hostWidth = hostView.frame.size.width as CGFloat
        var hostOnePerc = hostWidth/100 as CGFloat
        return hostOnePerc * perce
    }
    
    func statViewInPortraitRect(rectBounds: CGRect, type: String) -> UIView {
        var statRect = rectBounds
        statRect.origin.x += 2
        statRect.origin.y = statRect.size.height-2
        statRect.size.width = 16
        statRect.size.height = 0
        
        var v = UIView(frame: statRect)
        v.layer.cornerRadius = SV_ROUND_NUM
        v.backgroundColor = self.appColors.colorForType(type)
        return v
    }
    
    func pxPortraitValue(hostView: UIView, perce: CGFloat) -> CGFloat {
        var hostHeight = hostView.frame.size.height as CGFloat
        var hostOnePerc = hostHeight/100 as CGFloat
        return hostOnePerc * perce
    }
    
    func createDaily() {
        var dailyTotal = self.statsDaily.objectForKey("total") as! Int
        var dailyComp = self.statsDaily.objectForKey("comp") as! Int
        var t = "0%"
        if (dailyComp > 0) {
            var dailyCut = Float(dailyComp) / Float(dailyTotal)*100
            t = String(format: "%.1f%%", dailyCut)
            
            var dailyStatView = statViewInLandscapeRect(self.SVBGDaily.bounds, type: "daily")
            self.SVBGDaily.addSubview(dailyStatView)
            var pxVal = pxHotizonatlValue(self.SVBGDaily, perce: CGFloat(dailyCut))
            expendHorizontalStatViewToRect(dailyStatView, width: pxVal)
        }
        self.SVDailyPerce.text = t

    }
    
    func createTotal() {
        var dailyTotal = self.statsTotal.objectForKey("total") as! Int
        var dailyComp = self.statsTotal.objectForKey("comp") as! Int
        var t = "0%"
        if (dailyComp > 0) {
            var totalCut = Float(dailyComp) / Float(dailyTotal)*100
            t = String(format: "%.1f%%", totalCut)

            var totalStatView = statViewInLandscapeRect(self.SVBGDaily.bounds, type: "total")
            self.SVBGTotal.addSubview(totalStatView)
            var pxVal = pxHotizonatlValue(self.SVBGTotal, perce: CGFloat(totalCut))
            expendHorizontalStatViewToRect(totalStatView, width: pxVal)
        }
        self.SVTotalPerce.text = t

    }
    
    func dViewWithKey(key: String) -> UIView {
        var view:UIView = self.SVBGW1
        if (key == "1") {
            view = self.SVBGW1
        }
        else if (key == "2") {
            view = self.SVBGW2
        }
        else if (key == "3") {
            view = self.SVBGW3
        }
        else if (key == "4") {
            view = self.SVBGW4
        }
        else if (key == "5") {
            view = self.SVBGW5
        }
        else if (key == "6") {
            view = self.SVBGW6
        }
        else if (key == "7") {
            view = self.SVBGW7
        }
        return view
    }
    
    func dayName(key: String) -> String {
        var n = "Sunday"
        if (key == "1") {
            n = "Sunday"
        }
        else if (key == "2") {
            n = "Monday"
        }
        else if (key == "3") {
            n = "Tuesday"
        }
        else if (key == "4") {
            n = "Wednesday"
        }
        else if (key == "5") {
            n = "Thursday"
        }
        else if (key == "6") {
            n = "Friday"
        }
        else if (key == "7") {
            n = "Saturday"
        }
        return n
    }
    
    func dayLabelForView(statHost: UIView, title: String) -> UILabel {
        var rect = statHost.frame
        rect.origin.x -= (rect.size.height/2)-30
        rect.origin.y = (rect.size.height/2) + 25

        var rectHeight = rect.size.height
        rect.size.width = rectHeight
        rect.size.height = 20
        
        
        var lbl = UILabel(frame: rect)
        lbl.text = title
        lbl.font = UIFont.systemFontOfSize(16)
        lbl.textColor = self.appColors.colorForObjectName("section_header_text")
        lbl.backgroundColor = UIColor.clearColor()
        var p = CGFloat(-M_PI/2)
        
        lbl.transform = CGAffineTransformMakeRotation(p)
        
        
        return lbl
    }
    
    func createWeekly() {
        var totalTasks = self.statsWeekly.objectForKey("total") as! Int
        var totalKeys = self.statsWeekly.allKeys as NSArray
        
        for (var i=0;i<totalKeys.count;i++) {
            var key = totalKeys.objectAtIndex(i) as! String
            var t = String(format: "%@  %.1f%%", dayName(key), 0)

            if (key != "total") {
                var totalCut:Float = 0.0
                
                var v = dViewWithKey(key)
                var day1Stats = self.statsWeekly.objectForKey(key) as! Int
                if (day1Stats > 0) {
                    
                    totalCut = Float(day1Stats) / Float(totalTasks) * 100
                    t = String(format: "%@  %.1f%%", dayName(key), totalCut)

                    var k = String(format: "d%@", key)

                    var d1StatView = statViewInPortraitRect(v.bounds, type: "d1")
                    v.addSubview(d1StatView)
                    var pxVal = pxPortraitValue(v, perce: CGFloat(totalCut))
                    expendPortraitStatViewToRect(d1StatView, height: pxVal)
                }
                
                
                
                var lbl = dayLabelForView(v, title: t) as UILabel
                self.SVWeekdaysView.addSubview(lbl)
            }
        }
    }
    
    func calaulateStats() {
        createDaily()
        createTotal()
        createWeekly()
    }
    
    func checkPopulated() {
        if (self.statsPopulated == true) {
            self.statsTimer.invalidate()
            calaulateStats()
        }
    }
    
    func getStatsData() {
        self.statsDaily = self.tasksModel.getDailyStats()
        self.statsTotal = self.tasksModel.getTotalStats()
        self.statsWeekly = self.tasksModel.getWeeklyStats()
        self.statsPopulated = true
    }
    
    func initStatsView() {
        self.menuView.userInteractionEnabled = false
        
        let tapRec = UITapGestureRecognizer()
        tapRec.numberOfTapsRequired = 1
        tapRec.addTarget(self, action: "closeMenuAnimation")
        self.view.addGestureRecognizer(tapRec)
        roundSVBGS()
        getStatsData()
    }
    
    

    
    // MARK: - ViewController Methods
    
    override func viewDidAppear(animated: Bool) {
        revealBGOnViewAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.menuBGView.layer.opacity = 0.0
        self.menuBGView.backgroundColor = self.appColors.getTransparentShade("menu_h_bg")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initStatsView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    //----------------------------------



}
