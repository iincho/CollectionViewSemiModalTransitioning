//
//  ViewController.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/02/12.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let customTransition = OverCurrentTransitioningDelegate()
    
    @IBAction func collectionViewDidTap(_ sender: Any) {
        let vc = CollectionSemiModalViewController.make()
        let nv = UINavigationController(rootViewController: vc)
        customTransition.interactor = vc.interactor
        nv.transitioningDelegate = customTransition
        nv.modalPresentationStyle = .custom
        present(nv, animated: true, completion: nil)
    }
}

