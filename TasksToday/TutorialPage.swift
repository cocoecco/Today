//
//  TutorialPage.swift
//  Cronometro
//
//  Created by Shachar Udi on 12/30/14.
//  Copyright (c) 2014 Shachar Udi. All rights reserved.
//

import UIKit

class TutorialPage: UIViewController {

    var pageIndex: Int = 0
    var pageImage: String = ""
    var closeBtn: UIButton = UIButton()
    
    let appColors = AppColors()
    
    func closeTutorial() {
        self.dismissViewControllerAnimated(true, completion: {
           // NSNotificationCenter.defaultCenter().postNotificationName("showagreement", object: nil)
        })
    }
    
    override func viewDidLoad() {
        let pageImage = UIImageView(frame: self.view.bounds)
        pageImage.image = UIImage(named: self.pageImage)
        self.view.addSubview(pageImage)
        
        var btnTitle = "Skip"
        if (pageIndex == 3) {
            btnTitle = "Start"
        }
        
        let selfSize = self.view.frame.size
        self.closeBtn = UIButton(frame: CGRectMake(selfSize.width-50, selfSize.height-65, 40, 20))
        self.closeBtn.setTitle(btnTitle, forState: .Normal)
        self.closeBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
        
        let blackColor = self.appColors.colorForObjectName("menu_btn_font_color")
        
        self.closeBtn.setTitleColor(blackColor, forState: .Normal)
        self.closeBtn.setTitleColor(blackColor, forState: .Selected)

        
        
        self.closeBtn.addTarget(self, action: "closeTutorial", forControlEvents: .TouchUpInside)
        //self.closeBtn.titleLabel?.textColor = UIColor.whiteColor()
        self.view.addSubview(self.closeBtn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
