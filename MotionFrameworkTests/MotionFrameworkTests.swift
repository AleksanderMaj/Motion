//
//  MotionFrameworkTests.swift
//  MotionFrameworkTests
//
//  Created by Aleksander Maj on 25/10/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import XCTest
@testable import MotionFramework


class MotionFrameworkTests: XCTestCase {

    func testProjection() {
        let xs = [
            Vector(1, 0, 0),
            Vector(1, 0, 0),
            Vector(0, 0, 1)
        ]

        let ys = [
            Vector(1, 0, 0),
            Vector(0, 1, 0),
            Vector(0, 0, 1)
        ]

        let references = [
            Vector(1, 0, 0),
            Vector(0, 0, 0),
            Vector(0, 0, 1)
        ]


        for (index, pair) in zip(xs, ys).enumerated() {
            let projection = project(pair.0, onto: pair.1)
            let reference = references[index]
            XCTAssert( projection == reference, "\(projection) != \(reference)")
        }
    }

    func testAverageAngles01() {
        let angles: [Double] = [80, 90, 100, 120, 100, 70]
        let reference: Double = angles.reduce(0, +) / Double(angles.count)
        let result = averageAngle(angles)
        XCTAssert(abs(result - reference) < 1, "Result: \(result), reference: \(reference)")
    }

    func testAverageAngles02() {
        let angles: [Double] = [359, 320, 290, 279, 245, 215]
        let reference: Double = angles.reduce(0, +) / Double(angles.count)
        let result = averageAngle(angles)
        XCTAssert(abs(result - reference) < 1, "Result: \(result), reference: \(reference)")
    }

    func testAverageAngles03() {
        let angles: [Double] = [359, 1, 345, 15, 343, 17]
        let reference: Double = 360
        let result = averageAngle(angles)
        XCTAssert(abs(result - reference) < 1, "Result: \(result), reference: \(reference)")
    }
}
