import UIKit

class OverCurrentTransitioningInteractor {
    enum State {
        case none
        case shouldStart
        case hasStarted
        case shouldFinish
    }

    var state: State = .none

    var startInteractionTranslationY: CGFloat = 0

    var startHandler: (() -> Void)?
    
    var changedHandler: ((_ offsetY: CGFloat) -> Void)?

    var finishHandler: (() -> Void)?
    
    var resetHandler: (() -> Void)?

    func setStartInteractionTranslationY(_ translationY: CGFloat) {
        switch state {
        case .shouldStart:
            /// Interaction開始可能な際にInteraction開始までの間更新し続けることで、開始時のYを保持する
            startInteractionTranslationY = translationY
        case .hasStarted, .shouldFinish, .none:
            break
        }
    }

    func updateStateShouldStartIfNeeded() {
        switch state {
        case .none:
            state = .shouldStart
            startHandler?()
        case .shouldStart, .hasStarted, .shouldFinish:
            break
        }
    }
    
    func changed(by offsetY: CGFloat) {
        changedHandler?(offsetY)
    }

    func finish() {
        finishHandler?()
    }
    
    func reset() {
        state = .none
        startInteractionTranslationY = 0
        resetHandler?()
    }
}

