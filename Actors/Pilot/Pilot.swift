//
//  Pilot.swift
//  WhatToEat
//
//  Created by YuCheng on 2021/2/12.
//  Copyright © 2021 YuCheng. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

enum GPSAccuracy : Int {
    case DEFAULT,BEST_FOR_NAVIGATION,BEST,
         NEAREST_TENMETERS,HUNDRED_METERS,
         KIIOMETER,THREE_KILOMETERS
}
enum PilotAuthorization : Int {
    case always,whenInUse
}
protocol PilotProtocol {
    @discardableResult
    func beLocationManager(didUpdateLocations locations: [CLLocation]) -> Self
    @discardableResult
    func beLocationManager(didFailWithError error: Error) -> Self
    @discardableResult
    func beLocationManager(didChangeAuthorization status: CLAuthorizationStatus) -> Self
}

fileprivate class GPSService: NSObject,CLLocationManagerDelegate {
    static let shared = GPSService()
    private let manager: CLLocationManager = CLLocationManager()
    private var isUpdatingStarted = false
    private var purposeKey = ""
    private var delegates: [String : PilotProtocol] = [:]
    
    func bindProtocol(_ binder: Pilot,_ delegate: PilotProtocol) {
        let nameplate: String = addressOf(binder)
        guard delegates[nameplate] == nil else { return }
        delegates[nameplate] = delegate
    }
    func configureGPS(_ config: PilotConfig) {
        setAccuracy(config.accuracy)
        manager.activityType = config.activeType
        manager.distanceFilter =
        CLLocationDistance(config.filterMeters)
        purposeKey = config.purposeKey
        manager.delegate = self
    }
    
    func setAccuracy(_ accuracy: GPSAccuracy) {
        switch accuracy {
        case .DEFAULT:
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        case .BEST_FOR_NAVIGATION:
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        case .BEST:
            manager.desiredAccuracy = kCLLocationAccuracyBest
        case .NEAREST_TENMETERS:
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        case .HUNDRED_METERS:
            manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        case .KIIOMETER:
            manager.desiredAccuracy = kCLLocationAccuracyKilometer
        case .THREE_KILOMETERS:
            manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        }
    }
    
    func requestAuthorization(_ authorization: PilotAuthorization) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedAlways: break
        case .authorizedWhenInUse: break
        default:
            pilotAuthorize(authorization)
        }
    }
    private func pilotAuthorize(_ authorization: PilotAuthorization) {
        switch authorization {
        case .always:
            if manager.authorizationStatus == .authorizedAlways {
                manager.requestAlwaysAuthorization()
            }
        case .whenInUse:
            manager.requestWhenInUseAuthorization()
        }
    }
    func requestTempFullAccuracyAuthorization() -> Bool {
        let accStatus = manager.accuracyAuthorization
        if accStatus == CLAccuracyAuthorization.reducedAccuracy {
            manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
            return true
        }
        return false
    }
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
        isUpdatingStarted = true
    }
    func requestCurrentLocation() {
        //request onece and accuracy select automatic
        //can't use together with startUpdatingLocation
        manager.requestLocation()
    }
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        isUpdatingStarted = false
    }
    
    func unBind(_ binder: Pilot) {
        let nameplate: String = addressOf(binder)
        delegates.removeValue(forKey: nameplate)
    }
    
    // MARK: - LocationManager delegate
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        for (_, delegate) in delegates {
            delegate.beLocationManager(didUpdateLocations: locations)
        }
    }
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        for (_, delegate) in delegates {
            delegate.beLocationManager(didChangeAuthorization: status)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        for (_, delegate) in delegates {
            delegate.beLocationManager(didFailWithError: error)
        }
    }
}
actor Pilot {
    private let gpsService = GPSService.shared
    
    func beDebut(config: PilotConfig) {
        gpsService.configureGPS(config)
    }
    func beComeOn(_ sender: PilotProtocol) {
        gpsService.bindProtocol(self, sender)
    }
    func beAuthorization(auth: PilotAuthorization) {
        gpsService.requestAuthorization(auth)
    }
    func beStart() {
        gpsService.startUpdatingLocation()
    }
    func beStop() {
        gpsService.stopUpdatingLocation()
    }
    func beCurrentLocation() {
        gpsService.requestCurrentLocation()
    }
    func beTempFullAccuracyAuth() -> Bool {
        return gpsService.requestTempFullAccuracyAuthorization()
    }
    func beRequestRoute(request: RouteRequest) async -> [MKRoute] {
        let directionsReq = MKDirections.Request()
        directionsReq.source = MKMapItem(placemark: MKPlacemark(coordinate: request.source))
        directionsReq.destination = MKMapItem(placemark: MKPlacemark(coordinate: request.destination))
        // if you want multiple possible routes
        directionsReq.requestsAlternateRoutes = request.alternateRoutes
        directionsReq.transportType = request.transportType
        let directions = MKDirections(request: directionsReq)
        do {
            let response: MKDirections.Response = try await directions.calculate()
            return response.routes
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    func beStepDown() {
        gpsService.unBind(self)
    }
    deinit {
        gpsService.unBind(self)
    }
}
