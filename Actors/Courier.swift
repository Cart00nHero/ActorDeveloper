//
//  Courier.swift
//  ActorDeveloper
//
//  Created by 林祐正 on 2021/5/6.
//

import Foundation

struct Parcel<T> {
//    let type: T.Type = T.self
    var sender: String = ""
    let content: T
}

fileprivate class LogisticsCenter {
    static let shared = LogisticsCenter()
    private var warehouse: [String: NSSet] = [:]
    
    func storeParcel<T>(_ recipient: String,_ parcel: Parcel<T>) {
        let parcelSet: NSMutableSet
        if warehouse[recipient] == nil {
            parcelSet = NSMutableSet()
        } else {
            parcelSet = NSMutableSet(set: warehouse[recipient]!)
        }
        if !parcelSet.contains(parcel) {
            parcelSet.add(parcel)
            warehouse[recipient] = parcelSet
        }
    }
    func collectParcels(_ recipient: Scenario) -> NSSet {
        let nameplate = String(describing: type(of: recipient))
        let parcelSet = NSSet(set: warehouse[nameplate] ?? NSSet())
        warehouse.removeValue(forKey: nameplate)
        return parcelSet
    }
    func cancelExpress<T>(_ recipient: String, _ parcel: Parcel<T>) {
        guard let parcelSet: NSSet = warehouse[recipient] else { return }
        let newSet = NSMutableSet.init(set: parcelSet)
        if newSet.contains(parcel) {
            newSet.remove(parcel)
            if newSet.count == 0 {
                warehouse.removeValue(forKey: recipient)
            } else {
                warehouse[recipient] = newSet
            }
        }
    }
}
actor Courier {
    private let center = LogisticsCenter.shared
    func beApplyExpress<T>(
        _ sender: Scenario, recipient: String, content: T
    ) -> Parcel<T> {
        let senderName = String(describing: type(of: sender))
        let parcel = Parcel(sender: senderName, content: content)
        center.storeParcel(recipient, parcel)
        return parcel
    }
    func beClaim(recipient: Scenario) -> NSSet {
        return center.collectParcels(recipient)
    }
    func beCancel<T>(recipient:String, parcel: Parcel<T>) {
        center.cancelExpress(recipient, parcel)
    }
}
