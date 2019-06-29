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
    private var headerHeight: CGFloat!
    
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
        self.headerHeight = headerHeight
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight)
        tableView.reloadData()
    }
    
    func scrollToTop() {
        tableView.scrollRectToVisible(tableView.tableHeaderView!.frame, animated: true)
    }
    
    func updateBounces(_ isBounces: Bool) {
        tableView.bounces = isBounces
    }
}

extension CollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight))
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        /// TableViewが慣性でスクロール終了した際、最上部のCellが表示されていれば先頭までスクロール
        scrollToTopIfNeeded(offsetY: scrollView.contentOffset.y)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        /// TableViewをドラッグしてスクロール終了した際、最上部のCellが表示されていれば先頭までスクロール
        scrollToTopIfNeeded(offsetY: scrollView.contentOffset.y)
    }
    
    private func scrollToTopIfNeeded(offsetY scrollViewContentOffsetY: CGFloat) {
        if scrollViewContentOffsetY < headerHeight {
            scrollToTop()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// TableView ScrollDown
        print("offsetY: \(scrollView.contentOffset.y)")
        scrollViewDidScrollHandler?(scrollView.contentOffset.y)
    }
}
