//
//  CustomPresentingAnimation.swift
//  Loans
//
//  Created by Ankit Deshmukh on 05/05/23.
//

import Foundation
import UIKit

class CustomPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        //        return 0.3
        return 3.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        let bounds = UIScreen.main.bounds
        toViewController.view.frame = finalFrameForVC.offsetBy(dx: 0, dy: bounds.size.height)
        toViewController.view.frame.origin.y = bounds.size.height - (toViewController.view.frame.height-68)
        toViewController.view.alpha = 0.0
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: ({
            var toVCFrame = toViewController.view.frame
            
            toVCFrame.origin.y = (bounds.size.height - (toViewController.view.frame.height))
            toViewController.view.alpha = 1.0
            
            toViewController.view.frame = toVCFrame
        }), completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
    
}

