//
//  MotionManager.swift
//  Motion
//
//  Created by Aleksander Maj on 14/08/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import Foundation
import CoreMotion

struct MotionManager {
    typealias DeviceMotionHandler = (CMDeviceMotion) -> Void

    var magneticNorthHandler: DeviceMotionHandler? = {
        print(String(format: "MAGNETIC: %.2f", $0.heading))
    }

    var zVerticalHandler: DeviceMotionHandler? = {
        print(String(format: "ZVERTICAL: %.2f", $0.heading))
    }

    private let manager: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 1.0
        return manager
    }()

    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()

    func startUpdates() {

        let availableReferenceFrames = CMMotionManager.availableAttitudeReferenceFrames()
        print("AVAILABLE REFERENCE FRAMES: \(availableReferenceFrames)")

        manager.startDeviceMotionUpdates(
            using: .xTrueNorthZVertical,
            to: operationQueue
        ) { (deviceMotion, error) in
            guard let motion = deviceMotion else { return }
            self.magneticNorthHandler?(motion)
        }

//        manager.startDeviceMotionUpdates(
//            using: .xArbitraryCorrectedZVertical,
//            to: operationQueue
//        ) { (deviceMotion, error) in
//            guard let motion = deviceMotion else { return }
//            self.zVerticalHandler?(motion)
//        }
    }
}
