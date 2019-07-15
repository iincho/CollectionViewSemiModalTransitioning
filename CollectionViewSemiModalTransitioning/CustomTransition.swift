//
//  CustomTransition.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/03/21.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit


class CustomTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning{
//
//    class var sharedInstance : CustomTransition {
//        struct Static {
//            static let instance : CustomTransition = CustomTransition()
//        }
//        return Static.instance
//    }
    
    fileprivate var isPresent = false
    
    // MARK: - UIViewControllerTransitioningDelegate
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 遷移時にTrasitionを担当する（UIViewControllerAnimatedTransitioningプロトコルを実装した）クラスを返す
        isPresent = true
        return self
    }
    
//    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        // 復帰時にTrasitionを担当する（UIViewControllerAnimatedTransitioningプロトコルを実装した）クラスを返す
//        isPresent = false
//        return self
//    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        if isPresent {
            presentTransition(transitionContext: transitionContext)
//        } else {
//            dissmissalTransition(transitionContext: transitionContext)
//        }
    }
    
    // 遷移時のTrastion処理
    func presentTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 遷移元、遷移先及び、遷移コンテナの取得
        let firstViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! CollectionSemiModalViewController
        let secondViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! UINavigationController
//        let secondViewController = navigationController.viewControllers.first as! DetailViewController
        let containerView = transitionContext.containerView
        
        // 遷移元のセルの取得
        
        let cell:CollectionSemiModalViewCell = firstViewController.collectionView?.cellForItem(at: (firstViewController.collectionView?.indexPathsForSelectedItems?.first)!) as! CollectionSemiModalViewCell
        // 遷移元のセルのイメージビューからアニメーション用のビューを作成
        let animationView = UIView()
        animationView.addSubview(cell.tableView!)
        animationView.frame = containerView.convert(cell.contentView.frame, from: cell.contentView.superview)

        // 遷移元のセルのイメージビューを非表示にする
        cell.tableView.isHidden = true
        
        //遷移後のビューコントローラを、予め最後の位置まで移動完了させ非表示にする
        secondViewController.view.frame = transitionContext.finalFrame(for: secondViewController)
        secondViewController.view.alpha = 0
        // 遷移後のイメージは、アニメーションが完了するまで非表示にする
//        secondViewController.tableView.isHidden = true
        
        // 遷移コンテナに、遷移後のビューと、アニメーション用のビューを追加する
        containerView.addSubview(secondViewController.view)
        containerView.addSubview(animationView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            // 遷移後のビューを徐々に表示する
            secondViewController.view.alpha = 1.0
            // アニメーション用のビューを、遷移後のイメージの位置までアニメーションする
            animationView.frame = UIApplication.shared.keyWindow!.frame
        }, completion: {
            finished in
            // 遷移後のイメージを表示する
//            secondViewController.tableView.isHidden = false
            // セルのイメージの非表示を元に戻す
            cell.tableView.isHidden = false

            // アニメーション用のビューを削除する
            cell.tableView.removeFromSuperview()
            animationView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
    
    // 復帰時のTrastion処理
//    func dissmissalTransition(transitionContext: UIViewControllerContextTransitioning) {
//        // 遷移元、遷移先及び、遷移コンテナの取得
//        let secondViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! DetailViewController
//        let firstViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! FirstViewController
//        let containerView = transitionContext.containerView
//
//        // 遷移元のイメージビューからアニメーション用のビューを作成
//        let animationView = secondViewController.photoView.snapshotView(afterScreenUpdates: false)
//        animationView?.frame = containerView.convert(secondViewController.photoView.frame, from: secondViewController.photoView.superview)
//        // 遷移元のイメージを非表示にする
//        secondViewController.photoView.isHidden = true
//
//        // 遷移先のセルを取得
//        let cell:CollectionViewCell = firstViewController.collectionView?.cellForItem(at: secondViewController.indexPath) as! CollectionViewCell
//
//        // 遷移先のセルのイメージを非表示
//        cell.photoView.isHidden = true
//
//        //遷移後のビューコントローラを、予め最後の位置まで移動完了させ非表示にする
//        firstViewController.view.frame = transitionContext.finalFrame(for: firstViewController)
//
//        // 遷移コンテナに、遷移後のビューと、アニメーション用のビューを追加する
//        containerView.insertSubview(firstViewController.view, belowSubview: secondViewController.view)
//        containerView.addSubview(animationView!)
//
//        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
//            // 遷移元のビューを徐々に非表示にする
//            secondViewController.view.alpha = 0
//            // アニメーションビューは、遷移後のイメージの位置まで、アニメーションする
//            animationView?.frame = containerView.convert(cell.photoView.frame, from: cell.photoView.superview)
//        }, completion: {
//            finished in
//            // アニメーション用のビューを削除する
//            animationView?.removeFromSuperview()
//            // 遷移元のイメージの非表示を元に戻す
//            secondViewController.photoView.isHidden = false
//            // セルのイメージの非表示を元に戻す
//            cell.photoView.isHidden = false
//            transitionContext.completeTransition(true)
//        })
//    }
    
}
