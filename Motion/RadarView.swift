//
//  RadarView.swift
//  Motion
//
//  Created by Aleksander Maj on 15/08/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import UIKit
import CoreLocation

class RadarView: UIView {
    private let scale = CGFloat(5.0) // 1 meter == 5 points
    private let circleRadii = [CGFloat(5.0), 10.0, 20.0, 30.0, 50.0]

    var location: CLLocation? {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        drawAxes()
        drawCircles()
        drawAccuracyCircle()
        drawCourse()
    }

    private func drawAxes() {
        UIColor.lightGray.set()

        let xAxisPath = UIBezierPath()
        xAxisPath.move(to: CGPoint(x: layoutMargins.left, y: center.y))
        xAxisPath.addLine(to: CGPoint(x: bounds.width - layoutMargins.right, y: center.y))
        let xAxisEndPoint = xAxisPath.currentPoint
        xAxisPath.addLine(to: xAxisEndPoint.applying(CGAffineTransform(translationX: -10, y: -3)))
        xAxisPath.addLine(to: xAxisEndPoint.applying(CGAffineTransform(translationX: -10, y: 3)))
        xAxisPath.addLine(to: xAxisEndPoint)
        xAxisPath.lineCapStyle = .round
        xAxisPath.stroke()
        xAxisPath.fill()

        let yAxisPath = UIBezierPath()
        yAxisPath.move(to: CGPoint(x: center.x, y: bounds.height - layoutMargins.bottom))
        yAxisPath.addLine(to: CGPoint(x: center.x, y: layoutMargins.top))
        let yAxisEndPoint = yAxisPath.currentPoint
        yAxisPath.addLine(to: yAxisEndPoint.applying(CGAffineTransform(translationX: -3, y: 10)))
        yAxisPath.addLine(to: yAxisEndPoint.applying(CGAffineTransform(translationX: 3, y: 10)))
        yAxisPath.addLine(to: yAxisEndPoint)
        yAxisPath.lineCapStyle = .round
        yAxisPath.stroke()
        yAxisPath.fill()
    }

    private func drawCircles() {
        UIColor.clear.setFill()
        UIColor.lightGray.setStroke()
        drawCircles(radii: circleRadii)
    }

    private func drawAccuracyCircle() {
        guard let accuracy = location?.horizontalAccuracy else { return }
        UIColor.blue.set()

        drawCircles(radii: [CGFloat(accuracy)])
    }

    private func drawCircles(radii: [CGFloat]) {
        let ovalPaths = radii
            .map {
                CGRect(center: center, size: CGSize(width: $0 * scale, height: $0 * scale))
            }
            .map(UIBezierPath.init(ovalIn:))

        ovalPaths.forEach {
            $0.stroke()
            $0.fill(with: .normal, alpha: 0.25)
        }
    }

    private func drawCourse() {
        guard let course = location?.course,
            course >= 0 else { return }
        UIColor.red.set()
        let transformedCourse = CGFloat(course - 90 )
        let arcPath = UIBezierPath(
            arcCenter: center,
            radius: scale * 8.0,
            startAngle: (transformedCourse - 15).toRadians(),
            endAngle: (transformedCourse + 15).toRadians(),
            clockwise: true)
        let armPath = UIBezierPath()
        armPath.move(to: arcPath.currentPoint)
        armPath.addLine(to: center)
        armPath.addLine(to: arcPath.reversing().currentPoint)

        armPath.stroke()
        armPath.fill(with: .normal, alpha: 0.25)
        //arcPath.stroke()
    }
}

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat.pi / 180
    }
}

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - 0.5 * size.width,
                             y: center.y - 0.5 * size.height)
        self.init(origin: origin, size: size)
    }
}
