//
//  Actor.swift
//  iListenOnWatch Extension
//
//  Created by 林祐正 on 2022/3/7.
//  Copyright © 2022 SmartFun. All rights reserved.
//

import Foundation

fileprivate struct ActorMessage {
    let portal:(() -> Void)
}
class Actor {
    private let mailBox: OperationQueue = OperationQueue()
    
    init() {
        mailBox.maxConcurrentOperationCount = 1
    }
    
    func unsafeSend(_ block:@escaping() -> Void) {
        let message: ActorMessage = ActorMessage(
            portal: block
        )
        put(message)
    }
    private func put(_ message: ActorMessage) {
        let newOp: BlockOperation = BlockOperation {
            message.portal()
        }
        let lastOp: Operation? = mailBox.operations.last
        if lastOp != nil {
            newOp.addDependency(lastOp!)
        }
        mailBox.addOperation(newOp)
    }
}
