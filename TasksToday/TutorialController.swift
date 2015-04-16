//
//  TutorialController.swift
//  Cronometro
//
//  Created by Shachar Udi on 12/30/14.
//  Copyright (c) 2014 Shachar Udi. All rights reserved.
//

import UIKit

class TutorialController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController?
    var pageImages: Array<String> = ["T1", "T2"]
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController?.dataSource = self
        
        let startingViewController: TutorialPage = viewControllerAtIndex(0)!
        let viewControllers: NSArray = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: false, completion: nil)
        self.pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
                
        addChildViewController(self.pageViewController!)
        view.addSubview(self.pageViewController!.view)
        self.pageViewController?.didMoveToParentViewController(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialPage).pageIndex
        
        if ((index == 0) || (index == NSNotFound)) {
            return nil
        }
        
        index--
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialPage).pageIndex
        
        if (index == NSNotFound) {
            return nil
        }
        
        index++
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> TutorialPage? {
        if (self.pageImages.count == 0 || index >= self.pageImages.count) {
            return nil
        }
        
        let tutorialPage = TutorialPage()
        tutorialPage.pageImage = self.pageImages[index]
        tutorialPage.pageIndex = index
        self.currentIndex = index
        return tutorialPage
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        let pageCount: Int = self.pageImages.count
        return pageCount
    }
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
}











