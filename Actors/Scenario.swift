//
//  Scenario.swift
//  NewActorDeveloper
//
//  Created by 林祐正 on 2022/2/23.
//

import Foundation

actor Scenarist {
    fileprivate func writeDown(_ story:@escaping() -> Void) {
        story()
    }
}
class Scenario {
    let scenarist: Scenarist = Scenarist()
    func tell(_ story:@escaping() -> Void) {
        Task {
            await scenarist.writeDown(story)
        }
    }
}
