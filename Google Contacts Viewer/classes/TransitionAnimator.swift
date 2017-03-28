//
//  TransitionAnimator.swift
//  Google Contacts Viewer
//
//  Created by Kalyan Vishnubhatla on 3/25/17.
//
//

import UIKit

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: .to)
        let fromViewController = transitionContext.viewController(forKey: .from)
        
        transitionContext.containerView.addSubview(toViewController!.view)
        toViewController!.view.alpha = 0
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            fromViewController!.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            toViewController!.view.alpha = 1
        }) { (finished) in
            fromViewController!.view.transform = CGAffineTransform.identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
