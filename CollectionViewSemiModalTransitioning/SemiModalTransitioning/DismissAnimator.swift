import UIKit

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }

        let containerView = transitionContext.containerView

        containerView.addSubview(fromVC.view)

        let screenBounds = UIScreen.main.bounds

        let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)
        let option: UIView.AnimationOptions = transitionContext.isInteractive ? .curveLinear : .curveEaseIn

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: [option],
                       animations: {
                           fromVC.view.frame = finalFrame
                       },
                       completion: { _ in
                           transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                       }
        )
    }
}
