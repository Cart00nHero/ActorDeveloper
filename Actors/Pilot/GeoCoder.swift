//
//  GeoCoder.swift
//  WhatToEat
//
//  Created by YuCheng on 2021/2/13.
//  Copyright © 2021 YuCheng. All rights reserved.
//

import Foundation
import MapKit

actor GeoCoder {
    func beCodeAddress(address: String) async -> [CLPlacemark] {
        let geoCoder = CLGeocoder()
        do {
            let places: [CLPlacemark] = try await geoCoder.geocodeAddressString(address)
            return places
        } catch {
            print(error)
        }
        return []
    }
    func beReverseLocation(location: CLLocation) async -> [CLPlacemark] {
        let geoCoder = CLGeocoder()
        do {
            let places: [CLPlacemark] = try await geoCoder.reverseGeocodeLocation(location)
            return places
        } catch  {
            print(error)
        }
        return []
    }
}
