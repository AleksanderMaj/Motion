//
//  Vector.swift
//  MotionFramework
//
//  Created by Aleksander Maj on 29/10/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import Foundation
import CoreMotion
import Overture

struct Vector: Equatable {
    let x, y, z: Double

    init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    var negative: Vector {
        return Vector(-x, -y, -z)
    }
}

extension Vector {
    init(_ attitude: CMAttitude) {
        self.x = cos(attitude.yaw) * cos(attitude.pitch)
        self.y = sin(attitude.yaw) * cos(attitude.pitch)
        self.z = sin(attitude.pitch)
    }
}

extension Vector {
    init(_ acceleration: CMAcceleration) {
        self.x = acceleration.x
        self.y = acceleration.y
        self.z = acceleration.z
    }
}

extension Vector {}

func negative(_ a: Vector) -> Vector {
    return Vector(-a.x, -a.y, -a.z)
}

func dotProduct(_ a: Vector, _ b: Vector) -> Double {
    return a.x * b.x + a.y * b.y + a.z * b.z
}

func length(_ a: Vector) -> Double {
    return with((a, a), pipe(dotProduct, sqrt))
}

func multiply(_ a: Vector, by k: Double) -> Vector {
    return Vector(
        a.x * k,
        a.y * k,
        a.z * k
    )
}

func project(_ a: Vector, onto b: Vector) -> Vector {
    return multiply(b, by: (dotProduct(a, b) / length(b)))
}
