//
//  ViewController.swift
//  Motion
//
//  Created by Aleksander Maj on 14/08/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var radarView: RadarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Current.locationManager.requestAuthorization()
        Current.locationManager.locationUpdateHandler = handleLocationUpdate(_:)
        Current.locationManager.startUpdates()
    }

    func handleLocationUpdate(_ location: CLLocation) {
        print(location)
        radarView.location = location
    }
}

