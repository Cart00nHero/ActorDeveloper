//
//  Scenario.swift
//  NewActorDeveloper
//
//  Created by 林祐正 on 2022/2/23.
//

import Foundation

class Scenario {
    private actor Scenarist {
        func writeDown(_ plot:@escaping() -> Void) {
            plot()
        }
    }
    private let scenarist: Scenarist = Scenarist()
    func tell(_ plot:@escaping() -> Void) {
        Task {
            await scenarist.writeDown(plot)
        }
    }
}
