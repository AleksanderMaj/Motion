//
//  Environment.swift
//  Motion
//
//  Created by Aleksander Maj on 15/08/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import Foundation

struct Environment {
    var date = { Date.init() }
    var location = LocationManager()
    var motion = MotionManager()
}

extension Environment {
    static let mock = Environment(
        date: { Date() },
        location: .mock,
        motion: MotionManager()
    )
}
