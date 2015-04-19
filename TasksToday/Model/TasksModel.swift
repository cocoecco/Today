//
//  TasksModel.swift
//  TasksToday
//
//  Created by Shachar Udi on 4/7/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import UIKit
import CoreData

public class TasksModel: NSFetchedResultsControllerDelegate {
   
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    func getTasksOfDate(date: NSDate) -> NSFetchedResultsController {
        var taskItems = [TaskItem]()
        
        let fetchRequest = NSFetchRequest(entityName: "TaskItem")
        let sortDescriptor = NSSortDescriptor(key: "comp.0", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "comp.1", ascending: true)
        
        let sortDescriptor3 = NSSortDescriptor(key: "priority", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptor2, sortDescriptor3]
        
        let cal = NSCalendar.currentCalendar()
        var comps = cal.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate:date)
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let midnightOfToday = cal.dateFromComponents(comps)!

        comps.hour = 23
        comps.minute = 59
        comps.second = 59
        let lastSecondOfDay = cal.dateFromComponents(comps)!
        
        let predictAM = NSPredicate(format: "date > %@", midnightOfToday)
        let predictPM = NSPredicate(format: "date < %@", lastSecondOfDay)

        let predict = NSCompoundPredicate.andPredicateWithSubpredicates([predictAM,predictPM])
        fetchRequest.predicate = predict

        let FRController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "comp", cacheName: nil)
        FRController.delegate = self
        var error: NSError? = nil
        if !FRController.performFetch(&error) {
            return FRController
        }
        else {
            return FRController
        }
    }
    
    func getHistoryTasks(date: NSDate) -> NSFetchedResultsController {
        var taskItems = [TaskItem]()
        var dayLess = date.dateByAddingTimeInterval(-24*60*60)
        
        var midComponents:NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate: NSDate())
        midComponents.hour = 0
        midComponents.minute = 0
        midComponents.second = 0
        let midnight = NSCalendar.currentCalendar().dateFromComponents(midComponents)
 
        let fetchRequest = NSFetchRequest(entityName: "TaskItem")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptor3 = NSSortDescriptor(key: "priority", ascending: false)

        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptor3]
        //for some reason we need to compare to anything smaller then the day before today
        fetchRequest.predicate = NSPredicate(format: "date < %@", midnight!)
        
        let FRController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "dateDay", cacheName: nil)
        FRController.delegate = self
        var error: NSError? = nil
        if !FRController.performFetch(&error) {
            return FRController
        }
        else {
            return FRController
        }
    }

    func getFutureTasks(date: NSDate) -> NSFetchedResultsController {
        var taskItems = [TaskItem]()
        
        let fetchRequest = NSFetchRequest(entityName: "TaskItem")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptor3 = NSSortDescriptor(key: "priority", ascending: false)

        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptor3]
        fetchRequest.predicate = NSPredicate(format: "date > %@", date)
        
        let FRController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "dateDay", cacheName: nil)
        FRController.delegate = self
        var error: NSError? = nil
        if !FRController.performFetch(&error) {
            return FRController
        }
        else {
            return FRController
        }
    }
    
    func saveNewTask(taskItem: NSDictionary) {
        let itemTask = taskItem.objectForKey("task") as! String
        let itemDate = taskItem.objectForKey("date") as! NSDate
        let itemText = taskItem.objectForKey("taskText") as! String
        let itemPriority = taskItem.objectForKey("priority") as! Double
        TaskItem.createInManagedObjectContext(moc!, task: itemTask, date: itemDate, comp: false, taskText: itemText, priority: itemPriority)
    }
    
    
    func getFormattedDayDate(ofDate: NSDate) -> String {
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEE,MM/dd"
        return dateFormat.stringFromDate(NSDate()) as String
    }
    
    func saveEditedTask(taskItem: TaskItem) {
        TaskItem.updateItem(moc!, item: taskItem)
    }
    
    
    func deleteTask(taskItem: TaskItem) {
        moc!.deleteObject(taskItem)
        moc!.save(nil)
    }
    
    
    
    // MARK: Stats Data
    
    func getDailyStats() -> NSDictionary {
        var totals = NSMutableDictionary()
        totals.setObject(0, forKey: "total")
        totals.setObject(0, forKey: "comp")
        
        let fetchRequest = NSFetchRequest(entityName: "TaskItem")
        
        let cal = NSCalendar.currentCalendar()
        var comps = cal.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate:NSDate())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let midnightOfToday = cal.dateFromComponents(comps)!
        
        comps.hour = 23
        comps.minute = 59
        comps.second = 59
        let lastSecondOfDay = cal.dateFromComponents(comps)!
        
        let predictAM = NSPredicate(format: "date > %@", midnightOfToday)
        let predictPM = NSPredicate(format: "date < %@", lastSecondOfDay)
        
        let predict = NSCompoundPredicate.andPredicateWithSubpredicates([predictAM,predictPM])
        fetchRequest.predicate = predict
        
        var error = NSError()
        var resArray = self.moc!.executeFetchRequest(fetchRequest, error: nil) as NSArray?
        var totalComp = 0
        
        if (resArray!.count > 0) {
            for (var i=0;i<resArray!.count;i++) {
                if var item = resArray?.objectAtIndex(i) as? TaskItem {
                    if (item.comp == true) {
                        totalComp++
                    }
                }
            }
            totals.setObject(resArray!.count, forKey: "total")
            totals.setObject(totalComp, forKey: "comp")
        }
        return NSDictionary(dictionary: totals)
    }
    
    func getTotalStats() -> NSDictionary {
        var totals = NSMutableDictionary()
        totals.setObject(0, forKey: "total")
        totals.setObject(0, forKey: "comp")
        
        let fetchRequest = NSFetchRequest(entityName: "TaskItem")
        
        var error = NSError()
        var resArray = self.moc!.executeFetchRequest(fetchRequest, error: nil) as NSArray?
        var totalComp = 0
        
        if (resArray!.count > 0) {
            for (var i=0;i<resArray!.count;i++) {
                if var item = resArray?.objectAtIndex(i) as? TaskItem {
                    if (item.comp == true) {
                        totalComp++
                    }
                }
            }
            totals.setObject(resArray!.count, forKey: "total")
            totals.setObject(totalComp, forKey: "comp")
        }
        return NSDictionary(dictionary: totals)
    }
    
    
    func getLastSunday() -> NSDate {
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        var comps = cal!.components(NSCalendarUnit.CalendarUnitWeekday, fromDate:NSDate())
        let weekday = comps.weekday
        
        var comps2 = cal!.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate:NSDate())
        comps2.hour = 0
        comps2.minute = 0
        comps2.second = 0
        
        var nowDate = cal?.dateFromComponents(comps2)
        
        var t = -3600*24*(weekday-1)
        var timeInt: NSTimeInterval = Double(t)
        var zeroSunday = nowDate!.dateByAddingTimeInterval(timeInt)
        return zeroSunday
    }
    
    func dateDay(theDate: NSDate) -> Int {
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        var comps = cal!.components(NSCalendarUnit.CalendarUnitWeekday, fromDate:theDate)
        let weekday = comps.weekday
        return weekday
    }
    
    
    func getWeeklyStats() -> NSDictionary {
        var totals = NSMutableDictionary()
        totals.setObject(0, forKey: "total")
        totals.setObject(0, forKey: "1")
        totals.setObject(0, forKey: "2")
        totals.setObject(0, forKey: "3")
        totals.setObject(0, forKey: "4")
        totals.setObject(0, forKey: "5")
        totals.setObject(0, forKey: "6")
        totals.setObject(0, forKey: "7")

        let fetchRequest = NSFetchRequest(entityName: "TaskItem")
        var lastSunday = self.getLastSunday()
        
        
        let predictAM = NSPredicate(format: "date > %@", lastSunday)
        let predictPM = NSPredicate(format: "date < %@", NSDate())
        
        let predict = NSCompoundPredicate.andPredicateWithSubpredicates([predictAM,predictPM])
        fetchRequest.predicate = predict
        
        var error = NSError()
        var resArray = self.moc!.executeFetchRequest(fetchRequest, error: nil) as NSArray?
        var totalComp = 0
        
        if (resArray!.count > 0) {
            for (var i=0;i<resArray!.count;i++) {
                if var item = resArray?.objectAtIndex(i) as? TaskItem {
                    if (item.comp == true) {
                        var dayInt = dateDay(item.date)
                        var existingDayKey = String(format: "%d", dayInt)
                        if var existingSum = totals.objectForKey(existingDayKey) as? Int {
                            existingSum++
                            totals.setObject(existingSum, forKey: existingDayKey)
                        }
                    }
                }
            }
            totals.setObject(resArray!.count, forKey: "total")
        }
        return NSDictionary(dictionary: totals)
    }
    
    
    
    
    
    public init () {}
}


















