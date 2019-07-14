//
//  OverCurrentTransitioning.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by 本山洋一 on 2019/06/22.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

final class OverCurrentTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CollectionViewPresentAnimator(isPresent: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CollectionViewPresentAnimator(isPresent: false)
    }    
}
