//
//  TestScenario.swift
//  NewActorDeveloper
//
//  Created by 林祐正 on 2022/2/23.
//

import Foundation
import CoreLocation

fileprivate class TestArgument {
    var testValue = 1
}
fileprivate var args: TestArgument? = nil

class TestScenario: Scenario {
    private let redux = ReduxActor()
    
    override init() {
        super.init()
        Task {
            await scenarist.send {
                args = TestArgument()
            }
        }
    }
    func showTime() {
        Task {
            await redux.beComeOn(self)
        }
    }
    func test() {
        Task {
            _ = await scenarist.beTest()
        }
    }
    func testThread() {
        Task {
            _ = await scenarist.beTest2()
        }
    }
    deinit {
        args = nil
    }
}
fileprivate extension Scenarist {
    func beTest() -> Bool {
        args?.testValue = 11
        return true
    }
    func beTest2() -> Bool {
        return true
    }
    
    func beNewState(state: SceneState) {
    }
}
extension TestScenario: ReduxProtocol {
    func beNewState(state: SceneState) -> Self {
        Task {
            await scenarist.beNewState(state: state)
        }
        return self
    }
}
