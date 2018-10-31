//
//  ViewController.swift
//  Motion
//
//  Created by Aleksander Maj on 14/08/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import Overture

class ViewController: UIViewController {

    let courseHelper = CourseHelper()

    var values = [CGFloat]()
    var delta: Double?

    lazy var radarView: RadarView = with(
        RadarView(),
        concat(
            autolayoutStyle,
            mut(\.backgroundColor, .white)
        )
    )

    lazy var startButton: UIButton = with(
        UIButton(type: .system),
        concat(
            autolayoutStyle,
            mut(\.normalTitle, "I/O")
        )
    )

    lazy var resetCourseButton: UIButton = with(
        UIButton(type: .system),
        concat(
            autolayoutStyle,
            mut(\.normalTitle, "Reset course")
        )
    )

    lazy var stackView: UIStackView = with(
        UIStackView(),
        concat(
            autolayoutStyle,
            mut(\.axis, .vertical)
        )
    )

    lazy var buttonsStackView: UIStackView = with(
        UIStackView(),
        concat(
            autolayoutStyle,
            mut(\.axis, .horizontal)
        )
    )

    lazy var locationStatusLabel: UILabel = with(
        UILabel(),
        concat(
            infoLabelStyle,
            mut(\.text, "Location:")
        )
    )

    lazy var motionStatusLabel: UILabel = with(
        UILabel(),
        concat(
            infoLabelStyle,
            mut(\.text, "Heading:")
        )
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(stackView)

        stackView.addArrangedSubview(locationStatusLabel)
        stackView.addArrangedSubview(motionStatusLabel)
        stackView.addArrangedSubview(radarView)
        stackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(startButton)
        buttonsStackView.addArrangedSubview(resetCourseButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])

        startButton.addTarget(self, action: #selector(onStartButtonTap), for: .touchUpInside)
        resetCourseButton.addTarget(self, action: #selector(onResetButtonTap), for: .touchUpInside)

        courseHelper.onLocationChange = { [weak self] in
            self?.handleLocationUpdate(locationResult: $0)
        }

        courseHelper.onHeadingUpdate = { [weak self] in
            self?.onHeadingUpdate($0)
        }
    }

    func handleLocationUpdate(locationResult: LocationResult) {
        locationStatusLabel.text = locationText(locationResult)
        switch locationResult {
        case .success:
            locationStatusLabel.textColor = .green
        default:
            locationStatusLabel.textColor = .red
        }
    }

    func onHeadingUpdate(_ update: HeadingUpdate) {
        DispatchQueue.main.async {
            switch update {
            case let .accurate(course, heading, smoothed):
                self.motionStatusLabel.text = "C: \(compactDoubleWitness.describe(course)), H: \(compactDoubleWitness.describe(heading)) / \(compactDoubleWitness.describe(smoothed))"
                self.motionStatusLabel.textColor = .green
                self.radarView.headings = self.courseHelper.motionBuffer.headingHistory
                self.radarView.courses = [course]
                self.radarView.setNeedsDisplay()
            case .inaccurate:
                self.motionStatusLabel.text = "Heading: inaccurate"
                self.motionStatusLabel.textColor = .red
            }
        }
    }

    private func locationText(_ locationResult: LocationResult) -> String {
        var result = "Location: "
        switch locationResult {
        case .notAuthorized:
            result += "Unauthorized"
        case let .invalidCourse(location), let .inaccurate(location), let .success(location):
            let currentAccuracyText = compactDoubleWitness.describe(location.horizontalAccuracy)
            let requiredAccuracyText = compactDoubleWitness.describe(courseHelper.requiredLocationAccuracy)
            let courseText = compactDoubleWitness.describe(location.course)

            result += "Accuracy: \(currentAccuracyText) / \(requiredAccuracyText). Course: \(courseText)"
        }
        return result
    }

    @objc func onStartButtonTap() {
        courseHelper.start()
    }

    @objc func onResetButtonTap() {
        Current.motion.reference = Current.motion.latestDeviceMotion()
        Current.location.reference = Current.location.latestLocation()
        values = []
    }
}

let compactDoubleWitness = Describing<Double> {
    String(format: "%.1f", $0)
}

private let infoLabelStyle = concat(
    autolayoutStyle,
    mut(\UILabel.numberOfLines, 0),
    mut(\UILabel.lineBreakMode, .byWordWrapping),
    mut(\UILabel.font, .systemFont(ofSize: 12))
)
