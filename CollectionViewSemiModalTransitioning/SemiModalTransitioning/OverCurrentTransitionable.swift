import UIKit

protocol OverCurrentTransitionable where Self: UIViewController {
    var percentThreshold: CGFloat { get }
    var interactor: OverCurrentTransitioningInteractor { get }
}

extension OverCurrentTransitionable {
    var shouldFinishVerocityY: CGFloat {
        return 1200
    }
}

extension OverCurrentTransitionable {
    func handleTransitionGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let offsetY = translation.y - interactor.startInteractionTranslationY

        switch interactor.state {
        case .shouldStart:
            interactor.state = .hasStarted
        case .hasStarted, .shouldFinish:
            // 初期位置よりも上へのスクロールの場合、インタラクション終了
            if offsetY < 0 {
                interactor.state = .none
                interactor.reset()
                return
            }
            break
        case .none:
            return
        }
        
        let verticalMovement = offsetY / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)

        switch sender.state {
        case .changed:
            interactor.changed(by: offsetY)
            if progress > percentThreshold || sender.velocity(in: view).y > shouldFinishVerocityY {
                interactor.state =  .shouldFinish
            } else {
                interactor.state =  .hasStarted
            }
        case .cancelled:
            interactor.reset()
        case .ended:
            switch interactor.state {
            case .shouldFinish:
                interactor.finish()
            case .hasStarted, .none, .shouldStart:
                interactor.reset()
            }
        default:
            break
        }
        print("Interactor State: \(interactor.state)")
    }
}
