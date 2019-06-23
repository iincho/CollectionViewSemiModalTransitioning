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
        customTransition.interactor = vc.interactor
        vc.transitioningDelegate = customTransition
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
}

