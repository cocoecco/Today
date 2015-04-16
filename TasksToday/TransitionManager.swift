//
//  TransitionManager.swift
//  Quotter
//
//  Created by Shachar Udi on 2/2/15.
//  Copyright (c) 2015 Shachar Udi. All rights reserved.
//

import UIKit

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate  {
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    var isPresenting = false
    
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        var fromView: UIView
        var toView: UIView
        
        let container = transitionContext.containerView()
        
        if((NSClassFromString("UITransitionContextToViewKey")) != nil) {
            fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        }
        else {
            let from:UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let to:UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            
            fromView = from.view
            toView = to.view

        }
        
        // set up from 2D transforms that we'll use in the animation
        let offScreenRight = CGAffineTransformMakeTranslation(container.frame.width, 0)
        let offScreenLeft = CGAffineTransformMakeTranslation(-container.frame.width, 0)
        
        // start the toView to the right of the screen
        if (self.isPresenting) {
            toView.transform = offScreenLeft
        }
        else {
            toView.transform = offScreenRight
        }
        
        // add the both views to our view controller
        container.addSubview(toView)
        container.addSubview(fromView)
        
        // get the duration of the animation
        // DON'T just type '0.5s' -- the reason why won't make sense until the next post
        // but for now it's important to just follow this approach
        let duration = self.transitionDuration(transitionContext)
        
        // perform the animation!
        // for this example, just slid both fromView and toView to the left at the same time
        // meaning fromView is pushed off the screen and toView slides into view
        // we also use the block animation usingSpringWithDamping for a little bounce
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: nil, animations: {
            
            fromView.transform = offScreenLeft
            toView.transform = CGAffineTransformIdentity
            
            }, completion: { finished in
                
                // tell our transitionContext object that we've finished animating
                transitionContext.completeTransition(true)
                
        })
        
    }
    
    // return how many seconds the transiton animation will take
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 1.0
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    // remmeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        return self
    }
    
}