//
//  CollectionViewController.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/02/16.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

final class CollectionSemiModalViewController: UIViewController, OverCurrentTransitionable {
    var percentThreshold: CGFloat = 0.8
    var interactor = OverCurrentTransitioningInteractor()
    
    private var tableViewContentOffsetY: CGFloat = 0
    private var isScrollingCollectionView: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: CustomCollectionViewFlowLayout!
    
    private var indexOfCellBeforeDragging = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupViews()
        
        interactor.startHandler = { [weak self] in
            self?.collectionView.visibleCells
                .compactMap { $0 as? CollectionViewCell }
                .forEach { $0.updateBounces(false) }
        }
        interactor.resetHandler = { [weak self] in
            self?.collectionView.visibleCells
                .compactMap { $0 as? CollectionViewCell }
                .forEach { $0.updateBounces(true) }
        }
    }
    
    private func setupViews() {
        let collectionViewGesture = UIPanGestureRecognizer(target: self, action: #selector(collectionViewDidScroll(_:)))
        collectionViewGesture.delegate = self
        collectionView.addGestureRecognizer(collectionViewGesture)

        collectionView.register(cellType: CollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        layout.prepare()

    }
    
    @objc private func collectionViewDidScroll(_ sender: UIPanGestureRecognizer) {
        if isScrollingCollectionView { return }
        if tableViewContentOffsetY <= 0 {
            interactor.updateStateShouldStartIfNeeded()
        }
        interactor.setStartInteractionTranslationY(sender.translation(in: view).y)
        handleTransitionGesture(sender)
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = layout.pageWidth
        let proportionalOffset = layout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let safeIndex = max(0, min(numberOfItems - 1, index))
        return safeIndex
    }
}

extension CollectionSemiModalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: CollectionViewCell.self, for: indexPath)
        cell.configure(headerHeight:150, number: indexPath.row)
        cell.scrollViewDidScrollHandler = { [weak self] offsetY in
            self?.tableViewContentOffsetY = offsetY
            print("No: \(indexPath.row) offsetY: \(offsetY)")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(with: CollectionViewCell.self, for: indexPath)
        cell.scrollToTop()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
        isScrollingCollectionView = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isScrollingCollectionView = false
        
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset

        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()

        // calculate conditions:
        let dataSourceCount = collectionView(collectionView!, numberOfItemsInSection: 0)
        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

        if didUseSwipeToSkipCell {

            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = layout.pageWidth * CGFloat(snapToIndex)

            // Damping equal 1 => no oscillations => decay animation:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)

        } else {
            // This is a much better way to scroll to a cell:
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            layout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension CollectionSemiModalViewController {
    static func make() -> CollectionSemiModalViewController {
        let sb = UIStoryboard(name: "CollectionSemiModalViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! CollectionSemiModalViewController
        return vc
    }
}

extension CollectionSemiModalViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

final class CustomCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private let kFlickVelocityThreshold: CGFloat = 0.2
    private let edgeSideMargin: CGFloat = 24
    private let lineSpacing: CGFloat = 10
    
    var pageWidth: CGFloat {
        return itemSize.width + minimumLineSpacing
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        let width = collectionView.frame.width - edgeSideMargin * 2
        let height = collectionView.frame.height
        itemSize = CGSize(width: width, height: height)
        minimumLineSpacing = lineSpacing
        sectionInset = UIEdgeInsets(top: 0, left: edgeSideMargin, bottom: 0, right: edgeSideMargin)
        scrollDirection = .horizontal
    }
}
