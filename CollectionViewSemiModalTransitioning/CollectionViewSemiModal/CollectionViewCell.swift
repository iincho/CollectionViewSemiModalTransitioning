//
//  CollectionViewCell.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/03/09.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    var scrollViewDidScrollHandler: ((_ offsetY: CGFloat) -> Void)?
    
    @IBOutlet weak var tableView: UITableView!
    
    private var number: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .clear
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame: .zero)
    }
    
    func configure(headerHeight: CGFloat, number: Int) {
        self.number = number
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight)
        tableView.reloadData()
    }
    
    func scrollToTop() {
        tableView.contentOffset = .zero
    }
    
    func updateBounces(_ isBounces: Bool) {
        tableView.bounces = isBounces
    }
}

extension CollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 10
            cell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            cell.clipsToBounds = true
            cell.textLabel?.text = "No. \(number!)"
        } else {
            cell.textLabel?.text = String(indexPath.row)
        }
        
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollHandler?(scrollView.contentOffset.y)
    }
}
