//
//  HeadingCalculator.swift
//  MotionFramework
//
//  Created by Aleksander Maj on 29/10/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

enum LocationResult {
    case notAuthorized
    case invalidCourse(CLLocation)
    case inaccurate(CLLocation)
    case success(CLLocation)
}

enum MotionResult {
    case inaccurate(CMDeviceMotion)
    case success(CMDeviceMotion)
}

enum HeadingUpdate {
    case accurate(course: Double, heading: Double, smoothedHeading: Double)
    case inaccurate(Double?)
}

class CourseHelper {

    var latestLocation: CLLocation?
    var latestDeviceMotion: CMDeviceMotion?

    var latestLocationUpdate: LocationResult?
    var latestMotionUpdate: MotionResult?

    var referenceLocation: CLLocation?
    var referenceCourse: CLLocationDirection?

    var requiredLocationAccuracy: CLLocationAccuracy = 10

    var onLocationChange: ((LocationResult) -> Void)?
    var onMotionUpdate: ((MotionResult) -> Void)?

    var onHeadingUpdate: ((HeadingUpdate) -> Void)?

    var motionBuffer = MotionBuffer()

    func start() {
        switch Current.location.authorizationStatus() {
        case .notDetermined:
            Current.location.requestAuthorization()
        case .authorizedAlways:
            Current.location.startUpdates { [weak self] in
                self?.handleLocationUpdate($0)
            }
            Current.motion.startUpdates { [weak self] in
                self?.handleDeviceMotionUpdate($0)
            }
        default:
            break
        }
    }

    func handleLocationUpdate(_ location: CLLocation) {
        latestLocation = location
        var result: LocationResult
        if location.course < 0 {
            result = .invalidCourse(location)
        } else if location.horizontalAccuracy > requiredLocationAccuracy {
            result = .inaccurate(location)
        } else {
            result = .success(location)
        }
        latestLocationUpdate = result
        onLocationChange?(result)
    }

    func handleDeviceMotionUpdate(_ deviceMotion: CMDeviceMotion) {
        latestDeviceMotion = deviceMotion
        var result: MotionResult
        if deviceMotion.heading < 0 {
            motionBuffer.flush()
            result = .inaccurate(deviceMotion)
        } else {
            motionBuffer.append(deviceMotion)
            result = .success(deviceMotion)
        }
        latestMotionUpdate = result
        onMotionUpdate?(result)
        computeHeading()
    }

    func computeHeading() {
        guard let location = latestLocationUpdate,
            let motion = latestMotionUpdate else {
                return
        }
        var headingUpdate: HeadingUpdate

        switch (location, motion) {
        case let (.success(loc), .success(mot)):
            headingUpdate = .accurate(
                course: loc.course,
                heading: mot.heading,
                smoothedHeading: motionBuffer.smoothedHeading
            )
        default:
            headingUpdate = .inaccurate(nil)
        }
        onHeadingUpdate?(headingUpdate)
    }

    func reset() {
        referenceLocation = Current.location.latestLocation()
    }
}

struct MotionBuffer {
    private var buffer = [CMDeviceMotion]()
    var maxLength = 10

    mutating func append(_ deviceMotion: CMDeviceMotion) {
        buffer.insert(deviceMotion, at: 0)
        if buffer.count > maxLength {
            buffer = Array(buffer.prefix(10))
        }
    }

    mutating func flush() {
        buffer = []
    }

    var smoothedHeading: Double {
        let angles = buffer
            .map { $0.heading }
        return averageAngle(angles)
    }

    var headingHistory: [Double] {
        return buffer.map { $0.heading }
    }
}

func averageAngle(_ angles: [Double]) -> Double {
    let anglesInRadians = angles
        .map { $0 - 180}
        .map { $0.degreesToRadians }

    let xPart = anglesInRadians
        .map(cos)
        .reduce(0, +)
        / Double(angles.count)

    let yPart = anglesInRadians
        .map(sin)
        .reduce(0, +)
        / Double(angles.count)

    return atan2(yPart, xPart).radiansToDegrees + 180
}
