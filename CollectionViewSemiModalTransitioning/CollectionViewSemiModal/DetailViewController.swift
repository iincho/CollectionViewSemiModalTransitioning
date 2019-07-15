//
//  DetailViewController.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by 本山洋一 on 2019/07/14.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {
    var data: ViewData!
    var row: Int!
    var popActonHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(format: "%@ No.%d", data.title, row)
        view.backgroundColor = .white
        
        navigationController?.navigationBar.barTintColor = data.color
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(didTapBack))
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    @objc private func didTapBack() {
        popActonHandler?()
        navigationController?.popViewController(animated: true)
    }
}
