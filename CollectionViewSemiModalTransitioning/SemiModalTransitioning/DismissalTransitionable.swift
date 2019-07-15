import UIKit

/// DismissTransition制御関連プロトコル
protocol DismissalTransitionable where Self: UIViewController {
    // Dismiss実行閾値（縦スクロール量の比率）
    var percentThreshold: CGFloat { get }
    // Dismiss実行速度閾値
    var shouldFinishVerocityY: CGFloat { get }
    // DismissTransitionの状態を保持
    var interactor: DismissalTransitioningInteractor { get }
}

extension DismissalTransitionable {
    /// Dismiss開始までの上下スワイプによるアニメーションと、Dismiss実行、中止を制御している
    ///
    /// - Parameters:
    ///   - sender: CollectionViewのPanGestureRecognizer
    ///   - tableViewContentOffsetY: CollectionViewCell内部のTableViewスクロール位置
    func handleTransitionGesture(_ sender: UIPanGestureRecognizer, tableViewContentOffsetY: CGFloat) {
        let translation = sender.translation(in: view)
        interactor.updateStateWithTranslation(y: translation.y, tableViewContentOffsetY: tableViewContentOffsetY)
        if interactor.shouldStopInteraction { return }
        
        // 上下スクロール量の割合を計算
        let dismisalOffsetY = translation.y - interactor.startInteractionTranslationY
        let verticalMovement = dismisalOffsetY / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)

        // UIPanGestureRecognizer.state によるinteractor.stateの更新
        switch sender.state {
        case .changed:
            interactor.changed(by: dismisalOffsetY)
            if progress > percentThreshold || sender.velocity(in: view).y > shouldFinishVerocityY {
                // スクロール量の割合が閾値を超えた、もしくは、スクロール速度がしきい値を超えた場合
                interactor.state =  .shouldFinish
            } else {
                interactor.state =  .hasStarted
            }
        case .cancelled:
            interactor.reset()
        case .ended:
            // パンジェスチャー終了時のinteractor.stateによりDismiss実行有無を判定
            switch interactor.state {
            case .shouldFinish:
                interactor.finish()
            case .hasStarted, .none:
                interactor.reset()
            }
        default:
            break
        }
    }
}
