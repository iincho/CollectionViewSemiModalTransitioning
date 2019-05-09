//
//  ViewController.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/02/12.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func collectionViewDidTap(_ sender: Any) {
        let vc = CollectionSemiModalViewController.make()
        present(vc, animated: true, completion: nil)
    }
}

