//
//  ReduxActor.swift
//  ActorDeveloper
//
//  Created by YuCheng on 2021/8/8.
//

import Foundation
import ReSwift

protocol ReduxProtocol {
    @discardableResult
    func beNewState(state: SceneState) -> Self
}
fileprivate class ReduxMaster: StoreSubscriber {
    var delegate: ReduxProtocol?
    func subscribe() {
        appStore.subscribe(self) {
            $0.select {
                $0.sceneState
            }
        }
    }
    func unsubscribe() {
        appStore.unsubscribe(self)
        delegate = nil
    }
    // MARK: - Redux new state
    func newState(state: SceneState) {
        delegate?.beNewState(state: state)
    }
}
actor ReduxActor {
    private let redux = ReduxMaster()
    
    func beComeOn(_ sender: ReduxProtocol) {
        redux.delegate = sender
        redux.subscribe()
    }
    func beStepDown(_ sender: ReduxProtocol) {
        redux.unsubscribe()
        redux.delegate = nil
    }
}
