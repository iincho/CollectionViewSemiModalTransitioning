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
    func handleTransitionGesture(_ sender: UIPanGestureRecognizer, tableViewContentOffsetY: CGFloat) {
        let translation = sender.translation(in: view)
        interactor.updateState(translationY: translation.y, tableViewContentOffsetY: tableViewContentOffsetY)
        if interactor.shouldStopInteraction { return }
        
        let dismisalOffsetY = translation.y - interactor.startInteractionTranslationY
        let verticalMovement = dismisalOffsetY / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)

        switch sender.state {
        case .changed:
            interactor.changed(by: dismisalOffsetY)
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
            case .hasStarted, .none:
                interactor.reset()
            }
        default:
            break
        }
    }
}
