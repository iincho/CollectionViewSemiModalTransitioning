//
//  CollectionViewPresentAnimator.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/03/13.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

final class CollectionViewPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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
    
    private func presentTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as! ViewController
        let nv = transitionContext.viewController(forKey: .to) as! UINavigationController
        let toVC = nv.viewControllers.first as! CollectionSemiModalViewController
        let containerView = transitionContext.containerView
        
        toVC.beginAppearanceTransition(true, animated: true)
        toVC.endAppearanceTransition()
        
        let selectedIndexPath = fromVC.collectionView.indexPathsForSelectedItems!.first!

        // 遷移元Cell関連
        let fromCells = fromVC.collectionView.visibleCells.compactMap { cell -> UICollectionViewCell? in
            return cell.tag == selectedIndexPath.row - 1 ||
                cell.tag == selectedIndexPath.row ||
                cell.tag == selectedIndexPath.row + 1 ? cell : nil }.sorted(by: { $0.tag < $1.tag })
        let fromCellsFramesWithTagColor = fromCells.map {  fromCell -> (frame: CGRect, tag: Int, color: UIColor?) in
            let frame = fromCell.convert(fromCell.bounds, to: fromVC.view)
            return (frame, fromCell.tag, fromCell.contentView.backgroundColor)
        }
        
        let fromTargetCell = fromVC.collectionView.cellForItem(at: selectedIndexPath)! as UICollectionViewCell
        let finalToVCFrame = toVC.view.frame
        
        // 通常、このタイミングで取得できるvisibleCellsは先頭2つのCellとなる。本来はタップしたCell＋前後のCellがほしい。
        // resizableSnapshotView(from: afterScreenUpdates: withCapInsets:)を使い、afterScreenUpdates: trueとしてスナップショットを取得することで、
        // 描画完了後のViewを生成するとともに、目的のCellがvisibleCellsに格納されるようになる。
        
        if let _ = toVC.view.resizableSnapshotView(from: finalToVCFrame, afterScreenUpdates: true, withCapInsets: .zero) {
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
                snapshotCell.frame = fromCells.first(where: {$0.tag == toCell.tag})?.frame ?? .zero
                snapshotCell.alpha = 0
                return snapshotCell
            }
            let animationColorViews = fromCellsFramesWithTagColor.map { tuple -> UIView in
                let view = UIView(frame: tuple.frame)
                view.tag = tuple.tag
                view.backgroundColor = tuple.color
                return view
            }
    
            toVC.view.alpha = 0
            
            containerView.addSubview(toVC.view)
            animationToCells.forEach { containerView.addSubview($0) }
            animationColorViews.forEach { containerView.addSubview($0) }
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                animationToCells.forEach { animationCell in
                    animationCell.frame = finalToCellsFramesWithTag.first(where: { $0.tag == animationCell.tag })?.frame ?? .zero
                    animationCell.alpha = 1
                }
                animationColorViews.forEach { animationColorView in
                    animationColorView.frame = finalColorViewsFramesWithTag.first(where: { $0.tag == animationColorView.tag })?.frame ?? .zero
                }
                
            }, completion: { _ in
                toVC.view.alpha = 1
                toCells.forEach { $0.switchTitleColorView(isClear: false) }
                animationToCells.forEach { $0.removeFromSuperview() }
                animationColorViews.forEach { $0.removeFromSuperview() }
                transitionContext.completeTransition(true)
            })
        } else {
            // アニメーションさせる遷移先のSnapshotが取得出来なかった場合
            containerView.addSubview(toVC.view)
            toVC.view.frame = CGRect(origin: CGPoint(x: 0, y: finalToVCFrame.size.height), size: finalToVCFrame.size)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                toVC.view.frame = finalToVCFrame
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
    
    private func copyToVC(_ vc: CollectionSemiModalViewController) -> CollectionSemiModalViewController {
        return vc
    }

    private func dismissalTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
    }
}



