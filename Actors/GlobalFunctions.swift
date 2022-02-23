//
//  GlobalFunctions.swift
//  PrivateKitchen
//
//  Created by YuCheng on 2021/11/6.
//

import Foundation
import SwiftUI

let mapPurposeKey = "AskAccurateLocation"

func addressOf(_ o: UnsafeRawPointer) -> String {
    let addr = Int(bitPattern: o)
    return String(format: "%p", addr)
}
func addressOf<T: AnyObject>(_ o: T) -> String {
    let addr = unsafeBitCast(o, to: Int.self)
    return String(format: "%p", addr)
}
