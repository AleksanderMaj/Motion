//
//  LocationManager.swift
//  Motion
//
//  Created by Aleksander Maj on 15/08/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import Foundation
import CoreLocation
import Overture

class LocationManager: NSObject {
    typealias LocationHandler = (CLLocation) -> Void

    fileprivate lazy var manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()

    var locationUpdateHandler: LocationHandler = { _ in }

    var startUpdates = { (handler: @escaping LocationHandler) in
        Current.location.locationUpdateHandler = handler
        Current.location.manager.startUpdatingLocation()
    }
    var authorizationStatus = { CLLocationManager.authorizationStatus() }
    var requestAuthorization = requestAuthotizationImpl

    var reference: CLLocation?
    var latestLocation = { Current.location.manager.location }
}

private func startUpdatesImpl() {
    Current.location.manager.startUpdatingLocation()
}

private func requestAuthotizationImpl() {
    Current.location.manager.requestAlwaysAuthorization()
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        locationUpdateHandler(lastLocation)
    }
}

extension LocationManager {
    static let mock = with(LocationManager(), concat(
//        set(\LocationManager.startUpdates, mockStartUpdates),
        set(\LocationManager.requestAuthorization, mockRequestAuthotization)
    ))
}

private func mockStartUpdates() {
    let courseValues: [CLLocationDirection] = Array(-10...10).map(Double.init)
    let accuracyValues: [CLLocationDistance] = Array(5...26).reversed().map(Double.init)
    let zippedValues = zip(courseValues, accuracyValues)
    let locations = zippedValues.map(CLLocation.mock(course:accuracy:))

    for (index, location) in locations.enumerated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index), execute: {
            Current.location.locationUpdateHandler(location)
        })
    }
}

private func mockRequestAuthotization() {
    print("Mock request authotization")
}

extension CLLocation {
    static func mock(course: CLLocationDirection, accuracy: CLLocationDistance) -> CLLocation{
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 51.798, longitude: 19.409),
            altitude: 280,
            horizontalAccuracy: accuracy,
            verticalAccuracy: 20,
            course: course,
            speed: 3,
            timestamp: Current.date()
        )
    }

    static let mock = CLLocation(
        coordinate: CLLocationCoordinate2D(latitude: 51.798, longitude: 19.409),
        altitude: 280,
        horizontalAccuracy: 20,
        verticalAccuracy: 20,
        course: 15,
        speed: 3,
        timestamp: Current.date()
    )
}
