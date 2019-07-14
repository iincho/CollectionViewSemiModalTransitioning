//
//  CollectionViewCell.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/03/09.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

class CollectionSemiModalViewCell: UICollectionViewCell {
    var titleColorView: UIView? {
        guard let titleCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TableViewTitleCell else { return nil }
        return titleCell.colorView
    }
    
    var scrollViewDidScrollHandler: ((_ offsetY: CGFloat) -> Void)?
    
    var tableViewDidSelectHandler: ((_ row: Int) -> Void)?
    
    @IBOutlet weak var tableView: UITableView!
    
    var data: ViewData!
    private var headerHeight: CGFloat!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .clear
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(cellType: TableViewTitleCell.self)
    }
    
    func configure(headerHeight: CGFloat, data: ViewData) {
        self.data = data
        self.headerHeight = headerHeight
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight)
        tableView.reloadData()
    }
    
    func switchTitleColorView(isClear: Bool) {
        titleColorView?.backgroundColor = isClear ? .clear : data.color
    }
    
    func scrollToTop() {
        tableView.scrollRectToVisible(tableView.tableHeaderView!.frame, animated: true)
    }
    
    func updateBounces(_ isBounces: Bool) {
        tableView.bounces = isBounces
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource Methods
extension CollectionSemiModalViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(with: TableViewTitleCell.self, for: indexPath)
            cell.configure(data: data)
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            cell.selectionStyle = .none
            cell.textLabel?.text = String(indexPath.row)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 360
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewDidSelectHandler?(indexPath.row)
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
