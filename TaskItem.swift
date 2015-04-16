//
//  TaskItem.swift
//  TasksToday
//
//  Created by Shachar Udi on 4/8/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import Foundation
import CoreData

class TaskItem: NSManagedObject {

    @NSManaged var task: String
    @NSManaged var date: NSDate
    @NSManaged var taskText: String
    @NSManaged var comp: NSNumber
    @NSManaged var priority: Double

    
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, task: String, date: NSDate, comp: NSNumber, taskText: String, priority: Double) {
        let newItem: TaskItem = NSEntityDescription.insertNewObjectForEntityForName("TaskItem", inManagedObjectContext: moc) as! TaskItem
        newItem.task = task
        newItem.date = date
        newItem.comp = comp
        newItem.taskText = taskText
        newItem.priority = priority
        moc.save(nil)
    }
    
    class func updateItem(moc: NSManagedObjectContext, item: TaskItem) {
        moc.refreshObject(item, mergeChanges: true)
        moc.save(nil)
    }
    
    func dateDay() -> String {
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MM/dd/yy"
        var dateStr = dateFormat.stringFromDate(self.date) as String
        return dateStr
    }
    
    
}








