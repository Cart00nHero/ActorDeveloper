//
//  Scenario.swift
//  NewActorDeveloper
//
//  Created by 林祐正 on 2022/2/23.
//

import Foundation

actor Scenarist {
    func send(_ portal: @escaping() -> Void) {
        portal()
    }
}
class Scenario {
    let scenarist: Scenarist = Scenarist()
}
