//
//  CollectionViewPresentAnimator.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/03/13.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

final class CollectionViewPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.8
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as! CollectionSemiModalViewController
//        let nv = transitionContext.viewController(forKey: .to) as! UINavigationController
//        let toVC = nv.viewControllers.first as! DetailViewController
        let containerView = transitionContext.containerView
        
        let selectedIndexPath = fromVC.collectionView.indexPathsForSelectedItems!.first!
        let cell = fromVC.collectionView.cellForItem(at: selectedIndexPath) as! CollectionViewCell
        
        let animationView = cell.tableView!
        animationView.frame = containerView.convert(cell.contentView.frame, from: cell.contentView.superview)
//        cell.tableView.isHidden = true
        
//        toVC.view.frame = transitionContext.finalFrame(for: toVC)
//        toVC.view.alpha = 0
//        toVC.tableView.isHidden = true
        
        containerView.addSubview(animationView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
//            toVC.view.alpha = 1
//            animationView.frame = containerView.convert(toVC.tableView.frame, from: toVC.view)
//            animationView.frame = UIApplication.shared.keyWindow!.frame
        }, completion: { _ in
//            toVC.tableView.isHidden = false
//            cell.tableView.isHidden = false
            animationView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}



