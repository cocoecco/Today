//
//  AppColors.swift
//  TasksToday
//
//  Created by Shachar Udi on 4/8/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import UIKit

public class AppColors {
   
    func colorForPriority(priority: Double) -> UIColor {
        if (priority == 4.0) {
            return UIColor(red: 189/255.0, green: 195/255.0, blue: 199/255.0, alpha: 1.0)
        }
        else if (priority == 3.0) {
            return UIColor(red: 231/255.0, green: 76/255.0, blue: 60/255.0, alpha: 1.0)
        }
        else if (priority == 2.0) {
            return UIColor(red: 243/255.0, green: 156/255.0, blue: 18/255.0, alpha: 1.0)
        }
        else if (priority == 1.0) {
            return UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
        }
        else {
            return UIColor(red: 189/255.0, green: 195/255.0, blue: 199/255.0, alpha: 1.0)
        }
    }
    
    func getTransparentShade(color: String) -> UIColor {
        if (color == "menu_h_bg") { //main menu holder background color
            return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        }
        else {
            return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        }
    }
    
    
    func colorForObjectName(objName: String) -> UIColor {
        var objColor = UIColor.lightGrayColor()
        if (objName == "menu_seperator") {
            return UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0) //light gray
        }
        else if (objName == "menu_btn_font_color") {
            return UIColor(red: 12/255.0, green: 151/255.0, blue: 237/255.0, alpha: 1.0) //Blue Color
        }
        else if (objName == "tableview_header") {
            return UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0)
        }
        else if (objName == "section_header_text") {
            return UIColor(red: 81/255.0, green: 81/255.0, blue: 81/255.0, alpha: 1.0) //Dark Gray Color
        }
        else if (objName == "tasks_amount_text") {
            return UIColor(red: 12/255.0, green: 151/255.0, blue: 237/255.0, alpha: 1.0) //Blue Color
        }
        
        
        
        return objColor
    }
    
    func colorForType(type: String) -> UIColor {
        var color = self.colorForObjectName("tasks_amount_text")
        return color
    }
    
    public init() {}
}




// MARK - Constant Definitions
//----------------------------------
// MARK: - Storyboard IBOutlets
//----------------------------------
// MARK: - Storyboard IBActions
//----------------------------------
// MARK: - Class Variables
//----------------------------------
// MARK: - App Data Models
//Data Models ------------------------
//----------------------------------
// MARK: - Class Functions
// MARK: - Event Listeners
//----------------------------------
// MARK: - Alert view delegate
//----------------------------------
//Transition Manager
//----------------------------------
// MARK: - ViewController Methods
//ViewController Methods ----------
//----------------------------------



