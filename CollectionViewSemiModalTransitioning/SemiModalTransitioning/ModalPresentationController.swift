import UIKit

final class ModalPresentationController: UIPresentationController {
    private let overlayView = UIView()

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        overlayView.frame = containerView!.bounds
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.0
        containerView!.insertSubview(overlayView, at: 0)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [unowned self] _ in
            self.overlayView.alpha = 0.5
        })
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [unowned self] _ in
            self.overlayView.alpha = 0.0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)

        if completed {
            overlayView.removeFromSuperview()
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        return containerView!.bounds
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        overlayView.frame = containerView!.bounds
        presentedView!.frame = frameOfPresentedViewInContainerView
    }
}
