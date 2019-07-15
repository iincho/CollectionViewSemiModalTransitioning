//
//  CollectionViewController.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/02/16.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

final class CollectionSemiModalViewController: UIViewController, DismissalTransitionable {
    // DismissalTransitionable Property
    let percentThreshold: CGFloat = 0.2
    let shouldFinishVerocityY: CGFloat = 1200
    let interactor = DismissalTransitioningInteractor()
    
    private let visibleNaviBarOffsetY: CGFloat = 100
    private let cellHeaderHeight: CGFloat = 72
    
    var selectedIndex = 0
    private var indexOfCellBeforeDragging = 0
    private var tableViewContentOffsetY: CGFloat = 0
    private var isScrollingCollectionView = false
    private var isFirst = true
    private var dataList: [ViewData] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: CustomCollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupInteractor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirst {
            collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
            isFirst = false
        }
    }
    
    private func setupNavigation() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        navigationItem.leftBarButtonItem?.tintColor = .white
    }

    private func setupViews() {
        view.backgroundColor = .clear

        let collectionViewGesture = UIPanGestureRecognizer(target: self, action: #selector(collectionViewDidDragging(_:)))
        collectionViewGesture.delegate = self
        collectionView.addGestureRecognizer(collectionViewGesture)

        collectionView.register(cellType: CollectionSemiModalViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        layout.prepare()

        // ナビゲーションバーの表示制御を行う場合、表示切り替えごとにcontentInsetが変動し、それにより表示が崩れたりCollectionViewのサイズがおかしくなってスクロールができなくなる。
        // 対策として、contentInsetAdjustmentBehavior の設定をCollectionViewとCell内部のScrollViewで変動しないよう、.neverに設定する。
        // 合わせて、CollectionViewの上方向制約条件はSafeAreaに対してではなく、SuperViewに対して行う必要がある。
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    /// OverCurrentTransitioningInteractorのセットアップ 各種ハンドラーのセット
    private func setupInteractor() {
        interactor.startHandler = { [weak self] in
            self?.collectionView.visibleCells
                .compactMap { $0 as? CollectionSemiModalViewCell }
                .forEach { $0.updateBounces(false) }
        }
        interactor.changedHandler = { [weak self] offsetY in
            self?.collectionView.frame.origin = CGPoint(x: 0, y: offsetY)
        }
        interactor.finishHandler = { [weak self] in
            self?.dismiss(isInteractive: true)
        }
        interactor.resetHandler = { [weak self] in
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self?.collectionView.frame.origin = CGPoint(x: 0, y: 0)
                self?.collectionView.visibleCells
                    .compactMap { $0 as? CollectionSemiModalViewCell }
                    .forEach { $0.updateBounces(true) }
            }, completion: nil)
        }
    }
    
    @objc private func didTapDone() {
        dismiss(isInteractive: false)
    }
    
    /// DismissのAnimation設定
    ///
    /// - Parameter isInteractive: InteractiveなDismissAnimationが必要な場合: true, 通常のDismissAnimationの場合: false
    private func dismiss(isInteractive: Bool) {
        if let delegate = navigationController?.transitioningDelegate as? SemiModalTransitioningDelegate {
            delegate.isInteractiveDismissal = isInteractive
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// CollectionViewの縦方向スクロールをハンドリング
    ///
    /// - Parameter sender: UIPanGestureRecognizer
    @objc private func collectionViewDidDragging(_ sender: UIPanGestureRecognizer) {
        // CollectionViewが横方向にスクロールしている間はInteraction開始処理しない。
        if isScrollingCollectionView { return }
        handleTransitionGesture(sender, tableViewContentOffsetY: tableViewContentOffsetY)
    }
    
    /// CollectionViewの水平方向の位置を元に、中央付近にあるCollectionViewCellのindexを返却
    private func indexOfMajorCell() -> Int {
        let itemWidth = layout.pageWidth
        let proportionalOffset = layout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let safeIndex = max(0, min(numberOfItems - 1, index))
        return safeIndex
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout Methods
extension CollectionSemiModalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: CollectionSemiModalViewCell.self, for: indexPath)
        let baseRect = cell.frame
        let data = dataList[indexPath.row]
        cell.tag = indexPath.row
        cell.configure(headerHeight: cellHeaderHeight, data: data)
        cell.scrollViewDidScrollHandler = { [weak self] offsetY in
            self?.tableViewContentOffsetY = offsetY
            self?.transformCell(cell, baseRect: baseRect)
        }
        cell.tableViewDidSelectHandler = { [weak self] row in
            self?.transitionDetail(data: data, row: row)
        }
        cell.closeTapHandler = { [weak self] in
            self?.dismiss(isInteractive: true)
        }
        return cell
    }
    
    private func transitionDetail(data: ViewData, row: Int) {
        let vc = DetailViewController()
        vc.data = data
        vc.row = row
        vc.popActonHandler = { [weak self] in
            self?.switchDisplayNavigationBar(data: data)
        }        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// NavigationBarの表示制御
    /// 一定以上TableViewがスクロールされている場合にナビバーを表示する。
    private func switchDisplayNavigationBar(data: ViewData) {
        if let nv = navigationController {
            if cellHeaderHeight + visibleNaviBarOffsetY <= abs(tableViewContentOffsetY), nv.isNavigationBarHidden {
                title = data.title
                nv.navigationBar.barTintColor = data.color
                nv.setNavigationBarHidden(false, animated: true)
            }
            if abs(tableViewContentOffsetY) < cellHeaderHeight + visibleNaviBarOffsetY, !nv.isNavigationBarHidden {
                nv.setNavigationBarHidden(true, animated: true)
            }
        }
    }
    
    /// TableViewのスクロールに合わせて、画面内のCollectionViewCellのFrameを制御
    ///
    /// - Parameters:
    ///   - cell: TableViewをスクロールしているCollectionViewCell
    ///   - baseRect: CollectionViewCell初期位置のframe
    private func transformCell(_ cell: CollectionSemiModalViewCell, baseRect: CGRect) {
        switchDisplayNavigationBar(data: cell.data)
        // Cellの拡大中は横スクロールできないよう、TableViewのスクロール位置により制御
        collectionView.isScrollEnabled = tableViewContentOffsetY == 0

        let targetHeight = cellHeaderHeight + visibleNaviBarOffsetY // CellWidthが画面幅まで拡大するのが完了する高さ
        let verticalMovement = tableViewContentOffsetY / targetHeight
        let upwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let upwardMovementPercent = fminf(upwardMovement, 1.0)
        let transformX = Float(view.frame.width - baseRect.size.width) * upwardMovementPercent
        let newPosX = Float(baseRect.origin.x) - transformX / 2
        let newWidth = baseRect.size.width + CGFloat(transformX)
        // 中央のCellを操作
        cell.frame = CGRect(x: CGFloat(newPosX),
                            y: baseRect.origin.y,
                            width: newWidth,
                            height: baseRect.size.height)
        // 前後のCollectionViewCellを動かす
        collectionView.visibleCells.forEach { vCell in
            if vCell.tag < cell.tag {
                vCell.frame.origin.x = (baseRect.origin.x - layout.pageWidth) - CGFloat(transformX / 2)
            } else if cell.tag < vCell.tag {
                vCell.frame.origin.x = (baseRect.origin.x + layout.pageWidth) + CGFloat(transformX / 2)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(with: CollectionSemiModalViewCell.self, for: indexPath)
        cell.scrollToTop()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
        isScrollingCollectionView = true
    }
    
    
    /// CollectionViewの横スクロールを必ず中央で止まるように制御している
    /// ドラッグ完了位置(Cell半分以上スクロール)、もしくは、スワイプ時の速度のどちらかが該当条件を満たしていた場合に、前後のCollectionViewCellの中央までスクロールするよう制御している
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isScrollingCollectionView = false
        // 横スクロールの速度閾値
        let swipeVelocityThreshold: CGFloat = 0.5
        
        // 横スクロールを現在の位置で止め、現在の横スクロール位置から中央に表示されるCollectionViewCellのindexを取得
        targetContentOffset.pointee = scrollView.contentOffset
        let indexOfMajorCell = self.indexOfMajorCell()

        let dataSourceCount = collectionView(collectionView!, numberOfItemsInSection: 0)
        // 横スクロールの速度が次のCellへスライドする閾値を超えているか(かつindexが範囲内)
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
        // 横スクロールの速度が前のCellへスライドする閾値を超えているか(かつindexが範囲内)
        let hasEnoughVelocityToSlideToThePrevCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        // ドラッグ開始前のIndexと現在のIndexが一致しているか
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        // スワイプ速度による前後Cellへのスクロールを行うか
        let didSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePrevCell)

        if didSwipeToSkipCell {
            // スワイプ速度による前後スクロール制御
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = layout.pageWidth * CGFloat(snapToIndex)

            // usingSpringWithDamping: 1 振動なし、initialSpringVelocity: アニメーション初速をCollectionViewの横スクロール速度に設定
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: { _ in
                self.selectedIndex = snapToIndex
            })

        } else {
            // indexによるスクロール位置の更新
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            layout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            selectedIndex = indexOfMajorCell
        }
    }
}

// MARK: - Make Self ViewController
extension CollectionSemiModalViewController {
    static func make(dataList: [ViewData], selectedIndex: Int) -> CollectionSemiModalViewController {
        let sb = UIStoryboard(name: "CollectionSemiModalViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! CollectionSemiModalViewController
        vc.dataList = dataList
        vc.selectedIndex = selectedIndex
        return vc
    }
}

// MARK: - UIGestureRecognizerDelegate Methods
extension CollectionSemiModalViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

/// CustomCollectionViewFlowLayout
final class CustomCollectionViewFlowLayout: UICollectionViewFlowLayout {
    let edgeSideMargin: CGFloat = 24
    
    private let kFlickVelocityThreshold: CGFloat = 0.2
    private let lineSpacing: CGFloat = 8
    
    var pageWidth: CGFloat {
        let width = collectionView!.frame.width - edgeSideMargin * 2
        return width + minimumLineSpacing
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
