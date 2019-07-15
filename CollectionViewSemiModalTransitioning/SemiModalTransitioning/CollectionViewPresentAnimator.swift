//
//  CollectionViewPresentAnimator.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/03/13.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

final class CollectionViewPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    struct AnimationCellData {
        enum TargetType {
            case prev
            case target
            case next
        }
        
        let frame: CGRect
        let tag: Int
        let color: UIColor?
        
        init(cell: UICollectionViewCell, targetConvertFrame: CGRect, targetType: TargetType, cellSpacing: CGFloat) {
            switch targetType {
            case .target:
                frame = targetConvertFrame
            case .prev:
                frame = targetConvertFrame.offsetBy(dx: -targetConvertFrame.width - cellSpacing, dy: 0)
            case .next:
                frame = targetConvertFrame.offsetBy(dx: targetConvertFrame.width + cellSpacing, dy: 0)
            }
            tag = cell.tag
            color = cell.contentView.backgroundColor
        }
    }
    
    let isPresent: Bool
    
    init(isPresent: Bool) {
        self.isPresent = isPresent
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            presentTransition(using: transitionContext)
        } else {
            dismissalTransition(using: transitionContext)
        }
    }
    
    /// Present Transition Animator
    private func presentTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as! ViewController
        let toNC = transitionContext.viewController(forKey: .to) as! UINavigationController
        let toVC = toNC.viewControllers.first as! CollectionSemiModalViewController
        let finalToVCFrame = toVC.view.frame
        let containerView = transitionContext.containerView
        
        let selectedIndexPath = fromVC.collectionView.indexPathsForSelectedItems!.first!

        // 通常、このタイミングで取得できる[遷移先]のvisibleCellsは先頭2つのCellとなる。本来はタップしたCell＋前後のCellがほしい。
        // snapshotView(afterScreenUpdates: true)によりスナップショットを取得することで、描画完了後のViewを生成するとともに目的のCellがvisibleCellsに格納されるようになる。
        if toVC.view.snapshotView(afterScreenUpdates: true) != nil {
        
            // 遷移元Cell関連
            // 遷移元Cellの座標をもとにアニメーション開始位置を決める。
            // 今回のアニメーションでは、遷移後の横並びに合わせ、アニメーション開始位置はタップされたCellの両脇を開始位置とする。
            // そのため、左右のセルが改行の関係で上下に位置する場合を考慮し、タップされたCellをもとにCGRectを生成する。
            // なお、遷移元のCell位置関係の取得はCollectionViewが一つであることを想定した実装であるため、複数ある場合はそれを考慮した実装が必要になる。
            
            // 遷移元Cellの生成 TargetCellの前後の存在有無を確認した上でCellを生成
            // cellForItemでは取得出来ない場合(画面外にあるなど)はUICollectionViewCellを生成している。
            // Frame指定する際、前後のCellはCollectionViewの改行を考慮し、TargetCellの左右に並ぶよう調整している
            let targetCell = fromVC.collectionView.cellForItem(at: selectedIndexPath)!
            let targetConvertFrame = targetCell.convert(targetCell.bounds, to: fromVC.view)
            // TODO: minimumLineSpacingはLayoutによって実際のCell間隔とズレが生じる。改行があるため、単純に前後のCell.originの比較では無いため今回は妥協している。
            let cellSpacing = (fromVC.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
            
            var fromCellDataList: [AnimationCellData] = []
            // PrevCell
            let prevTag = targetCell.tag - 1
            if 0 <= prevTag {
                let prevCell = fromVC.collectionView.cellForItem(at: IndexPath(row: prevTag, section: selectedIndexPath.section)) ?? UICollectionViewCell()
                prevCell.tag = prevTag
                fromCellDataList.append(AnimationCellData(cell: prevCell, targetConvertFrame: targetConvertFrame, targetType: .prev, cellSpacing: cellSpacing))
            }
            // TargetCell
            fromCellDataList.append(AnimationCellData(cell: targetCell, targetConvertFrame: targetConvertFrame, targetType: .target, cellSpacing: cellSpacing))
            // NextCell
            let nextTag = targetCell.tag + 1
            if nextTag < fromVC.collectionView.numberOfItems(inSection: selectedIndexPath.section) {
                let nextCell = fromVC.collectionView.cellForItem(at: IndexPath(row: nextTag, section: selectedIndexPath.section)) ?? UICollectionViewCell()
                nextCell.tag = nextTag
                fromCellDataList.append(AnimationCellData(cell: nextCell, targetConvertFrame: targetConvertFrame, targetType: .next, cellSpacing: cellSpacing))
            }
            
            // 遷移先View関連
            let toCells = toVC.collectionView.visibleCells.compactMap { cell -> CollectionSemiModalViewCell? in
                guard let castCell = cell as? CollectionSemiModalViewCell else { return nil }
                castCell.switchTitleColorView(isClear: true)
                return castCell
                }.sorted(by:{ $0.tag < $1.tag })
            
            let finalToCellsFramesWithTag = toCells.map { toCell -> (frame: CGRect, tag: Int) in
                let frame = toCell.convert(toCell.bounds, to: toVC.view)
                return (frame, toCell.tag)
            }
            let finalColorViewsFramesWithTag = toCells.map { toCell -> (frame: CGRect, tag: Int) in
                let frame = toCell.titleColorView?.convert(toCell.titleColorView?.bounds ?? .zero, to: toVC.view) ?? .zero
                return (frame, toCell.tag)
            }
    
            // AnimationView関連（toVCからSnapshotを作成）
            let animationToCells = toCells.map {  toCell -> UIView in
                let snapshotCell = toCell.resizableSnapshotView(from: toCell.bounds, afterScreenUpdates: true, withCapInsets: .zero) ?? UIView()
                snapshotCell.tag = toCell.tag
                snapshotCell.frame = fromCellDataList.first(where: {$0.tag == toCell.tag})?.frame ?? .zero
                snapshotCell.alpha = 0
                return snapshotCell
            }
            let animationColorViews = fromCellDataList.map { tuple -> UIView in
                let view = UIView(frame: tuple.frame)
                view.tag = tuple.tag
                view.backgroundColor = tuple.color
                return view
            }
    
            // アニメーションに関してtoVCを主に操作しているが、containerViewへ追加するのはあくまでUINavigationControllerのViewである必要がある。
            // toVCでも遷移自体は完了するが、遷移後画面がちらついたり詳細への遷移がおかしくなることがある。
            toNC.view.isHidden = true
            containerView.addSubview(toNC.view)
            animationToCells.forEach { containerView.addSubview($0) }
            animationColorViews.forEach { containerView.addSubview($0) }
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options:[.curveEaseInOut], animations: {
                animationToCells.forEach { animationCell in
                    animationCell.frame = finalToCellsFramesWithTag.first(where: { $0.tag == animationCell.tag })?.frame ?? .zero
                    animationCell.alpha = 1
                }
                animationColorViews.forEach { animationColorView in
                    animationColorView.frame = finalColorViewsFramesWithTag.first(where: { $0.tag == animationColorView.tag })?.frame ?? .zero
                }
            }, completion: { _ in
                toNC.view.isHidden = false
                toCells.forEach { $0.switchTitleColorView(isClear: false) }
                animationToCells.forEach { $0.removeFromSuperview() }
                animationColorViews.forEach { $0.removeFromSuperview() }
                transitionContext.completeTransition(true)
            })
        } else {
            // アニメーションさせる遷移先のSnapshotが取得出来なかった場合
            containerView.addSubview(toVC.view)
            toVC.view.frame = CGRect(origin: CGPoint(x: 0, y: finalToVCFrame.size.height), size: finalToVCFrame.size)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.curveEaseOut], animations: {
                toVC.view.frame = finalToVCFrame
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }

    // Dismissal Transition Animator
    private func dismissalTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromNC = transitionContext.viewController(forKey: .from) as! UINavigationController
        let fromVC = fromNC.viewControllers.first as! CollectionSemiModalViewController
        let toVC = transitionContext.viewController(forKey: .to) as! ViewController
        let containerView = transitionContext.containerView

        // 遷移元Cell関連
        let fromCells = fromVC.collectionView.visibleCells.compactMap { cell -> CollectionSemiModalViewCell? in
            guard let castCell = cell as? CollectionSemiModalViewCell else { return nil }
            castCell.switchTitleColorView(isClear: true)
            return castCell
            }.sorted(by:{ $0.tag < $1.tag })

        // 遷移先Cell関連
        let targetToIndexPath = IndexPath(row: fromVC.selectedIndex, section: 0)
        if toVC.collectionView.cellForItem(at: targetToIndexPath) == nil {
            // 遷移先対象Cellが画面外にいる場合、画面内にスクロールさせる。更にスナップショットをとることでcellForItemメソッドで参照可能な状態にしている。
            toVC.collectionView.scrollToItem(at: targetToIndexPath, at: .centeredVertically, animated: false)
            toVC.view.snapshotView(afterScreenUpdates: true)
        }
        let targetToCell = toVC.collectionView.cellForItem(at: targetToIndexPath)!
        let targetConvertFrame = targetToCell.convert(targetToCell.bounds, to: toVC.view)
        // TODO: minimumLineSpacingはLayoutによって実際のCell間隔とズレが生じる。改行があるため、単純に前後のCell.originの比較では無いため今回は妥協している。
        let cellSpacing = (fromVC.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
        var toCellDataList: [AnimationCellData] = []
        // PrevCell
        let prevTag = targetToCell.tag - 1
        if 0 <= prevTag {
            let prevCell = toVC.collectionView.cellForItem(at: IndexPath(row: prevTag, section: targetToIndexPath.section)) ?? UICollectionViewCell()
            prevCell.tag = prevTag
            toCellDataList.append(AnimationCellData(cell: prevCell, targetConvertFrame: targetConvertFrame, targetType: .prev, cellSpacing: cellSpacing))
        }
        // TargetCell
        toCellDataList.append(AnimationCellData(cell: targetToCell, targetConvertFrame: targetConvertFrame, targetType: .target, cellSpacing: cellSpacing))
        // NextCell
        let nextTag = targetToCell.tag + 1
        if nextTag < toVC.collectionView.numberOfItems(inSection: targetToIndexPath.section) {
            let nextCell = toVC.collectionView.cellForItem(at: IndexPath(row: nextTag, section: targetToIndexPath.section)) ?? UICollectionViewCell()
            nextCell.tag = nextTag
            toCellDataList.append(AnimationCellData(cell: nextCell, targetConvertFrame: targetConvertFrame, targetType: .next, cellSpacing: cellSpacing))
        }
        
        // AnimationView関連（fromVCからSnapshotを作成）
        let animationColorViews = toCellDataList.map { toCellData -> UIView in
            let view = fromCells.first(where: {$0.tag == toCellData.tag})?.titleColorView ?? UIView()
            let snapshotView = view.snapshotView(afterScreenUpdates: true) ?? UIView()
            snapshotView.frame = view.convert(view.bounds, to: toVC.view)
            snapshotView.tag = toCellData.tag
            snapshotView.backgroundColor = toCellData.color
            return snapshotView
        }
        let animationFromCells = toCellDataList.map { toCellData -> UIView in
            let cell = fromCells.first(where: {$0.tag == toCellData.tag}) ?? UIView()
            let snapshotCell = cell.snapshotView(afterScreenUpdates: true) ?? UIView()
            snapshotCell.frame = cell.convert(cell.bounds, to: toVC.view)
            snapshotCell.tag = cell.tag
            return snapshotCell
        }
        
        fromVC.view.isHidden = true
        animationFromCells.forEach { containerView.addSubview($0) }
        animationColorViews.forEach { containerView.addSubview($0) }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options:[.curveEaseInOut], animations: {
            animationFromCells.forEach { animationCell in
                animationCell.frame = toCellDataList.first(where: { $0.tag == animationCell.tag })?.frame ?? .zero
                animationCell.alpha = 0
            }
            animationColorViews.forEach { animationColorView in
                animationColorView.frame = toCellDataList.first(where: { $0.tag == animationColorView.tag })?.frame ?? .zero
            }
        }, completion: { _ in
            fromVC.view.isHidden = false
            fromCells.forEach { $0.switchTitleColorView(isClear: false) }
            animationFromCells.forEach { $0.removeFromSuperview() }
            animationColorViews.forEach { $0.removeFromSuperview() }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}



