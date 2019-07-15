import UIKit

class OverCurrentTransitioningInteractor {
    enum State {
        case none
        case hasStarted
        case shouldFinish
    }

    var state: State = .none

    var startInteractionTranslationY: CGFloat = 0

    var startHandler: (() -> Void)?
    
    var changedHandler: ((_ offsetY: CGFloat) -> Void)?

    var finishHandler: (() -> Void)?
    
    var resetHandler: (() -> Void)?

    var shouldStopInteraction: Bool {
        switch state {
        case .none: return true
        case .hasStarted, .shouldFinish: return false
        }
    }
    
    /// State更新
    ///
    ///
    /// - Parameters:
    ///   - translationY: CollectionViewGestrueTranslationY
    ///   - tableViewContentOffsetY: TableViewのScrollContentOffsetY　ドラッグによる更新されたOffsetY (慣性スクロールは含まない)
    func updateState(translationY: CGFloat, tableViewContentOffsetY: CGFloat) {
        switch state {
        case .none:
            if tableViewContentOffsetY <= 0 {
                // Interaction開始できる状態になったら、現在のCollectionViewGestureのtranslationYを記憶し、Interaction中のstateへ更新
                // startInteractionTranslationYを記憶することで、TableViewスクロール中から連続的にDismissアニメーションにつなげることができる
                startInteractionTranslationY = translationY
                state = .hasStarted
                startHandler?()
            }
        case .hasStarted, .shouldFinish:
            // 初期位置よりも上へのスクロールの場合、インタラクション終了
            if translationY - startInteractionTranslationY < 0 {
                state = .none
                reset()
            }
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

