//
//  MotionManager.swift
//  Motion
//
//  Created by Aleksander Maj on 14/08/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import Foundation
import CoreMotion
import Overture

struct MotionManager {
    typealias DeviceMotionHandler = (CMDeviceMotion) -> Void

    private static let manager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.05
        return manager
    }()

    private static let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()

    var startUpdates = { (handler: @escaping DeviceMotionHandler) in
        manager.startDeviceMotionUpdates(
            using: .xTrueNorthZVertical,
            to: operationQueue
        ) { (deviceMotion, error) in
//            deviceMotion.map {
//                print(tag: "H", $0, compactCombineWitness)
//            }
            deviceMotion.map(handler)
        }
    }

    var reference: CMDeviceMotion?
    var latestDeviceMotion = { manager.deviceMotion }
}

struct Describing<A> {
    var describe: (A) -> String
}

let compactGravityWitness = Describing<CMDeviceMotion> {
    compactAccWitness.describe($0.gravity)
}

let compactAttitudeWitness = Describing<CMDeviceMotion> {
    let angles = [$0.attitude.pitch, $0.attitude.roll, $0.attitude.yaw]
        .map { $0.radiansToDegrees }
    return String(format: "[%04.2f, %04.2f, %04.2f]", arguments: angles)
}

let headingWitness = Describing<CMDeviceMotion> {
    String(format: "HEAD: %04.2f", $0.heading)
}

let compactAccWitness = Describing<CMAcceleration> {
    String(format: "[%.2f, %.2f, %.2f]", $0.x, $0.y, $0.z)
}

let compactMagWitness = Describing<CMMagneticField> {
    String(format: "[%.2f, %.2f, %.2f]", $0.x, $0.y, $0.z)
}

let combineWitness = Describing<CMDeviceMotion> {
    return compactAttitudeWitness.describe($0)
        + " " + compactVectorWitness.describe(Vector($0.attitude))
}

let compactCombineWitness = Describing<CMDeviceMotion> {
    return headingWitness.describe($0)
}

let compactVectorWitness = Describing<Vector> {
    String(format: "[%.2f, %.2f, %.2f]", $0.x, $0.y, $0.z)
}

func print<A>(tag: String, _ value: A, _ witness: Describing<A>) {
    print("[\(tag)] \(witness.describe(value))")
}

let attitudeGravityWitness = Describing<CMDeviceMotion> {
    return compactVectorWitness.describe(Vector($0.attitude))
        + " " + compactGravityWitness.describe($0)
}

extension Double {
    var radiansToDegrees: Double {
        return self * 180 / Double.pi
    }

    var degreesToRadians: Double {
        return self * Double.pi / 180
    }
}
