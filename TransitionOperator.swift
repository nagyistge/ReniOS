//
//  TransitionOperator.swift
//  Rendezvous
//
//  Created by John Jin Woong Kim on 9/2/15.
//  Copyright (c) 2015 John Jin Woong Kim. All rights reserved.
//

import Foundation
import UIKit

class TransitionOperator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate{
    
    var snapshot : UIView!
    var isPresenting : Bool = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting{
            presentNavigation(transitionContext)
        }
        else{
            dismissNavigation(transitionContext)
        }
        
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
    return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
    return self
    }
    
    
    func presentNavigation(_ transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let fromView = fromViewController!.view
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let toView = toViewController!.view
        
        let size = toView?.frame.size
        var offSetTransform = CGAffineTransform(translationX: (size?.width)! - 120, y: 0)
        offSetTransform = offSetTransform.scaledBy(x: 0.6, y: 0.6)
        
        snapshot = fromView?.snapshotView(afterScreenUpdates: true)
        
        container.addSubview(toView!)
        container.addSubview(snapshot)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            
            self.snapshot.transform = offSetTransform
            
            }, completion: { finished in
                
                transitionContext.completeTransition(true)
        })

    }

    func dismissNavigation(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let fromView = fromViewController!.view
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let toView = toViewController!.view
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
            
            self.snapshot.transform = CGAffineTransform.identity
            
            }, completion: { finished in
                transitionContext.completeTransition(true)
                self.snapshot.removeFromSuperview()
        })
    }
    
    
    
    
}
