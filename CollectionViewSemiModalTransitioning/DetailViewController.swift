//
//  DetailViewController.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/03/13.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var num: Int = 0
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        title = "Number \(num)"
        
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(closeDidTap))
        navigationItem.rightBarButtonItem = closeBtn
    }
    
    @objc private func closeDidTap() {
        dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController {
    static func make(num: Int) -> DetailViewController {
        let sb = UIStoryboard(name: "DetailViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! DetailViewController
        vc.num = num
        return vc
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = String(indexPath.row)
        return cell
    }
}
