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

    var courses = [Double]()
    var headings = [Double]()

    override func draw(_ rect: CGRect) {
        drawAxes()
        drawCircles()
        //drawAccuracyCircle()
        drawCourses()
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

//    private func drawAccuracyCircle() {
//        guard let accuracy = location?.horizontalAccuracy else { return }
//        UIColor.blue.set()
//
//        drawCircles(radii: [CGFloat(accuracy)])
//    }

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

    private func drawCourses() {
        drawHeadings(courses, color: .blue, length: 20)
        drawHeadings(headings, color: .red, length: 16)
    }

    private func drawHeadings(_ headings: [Double], color: UIColor, length: CGFloat) {
        let count = headings.count

        color.set()
        for (index, heading) in headings.enumerated() {
            let rotatedHeading = CGFloat(heading - 0)
            let arcPath = UIBezierPath(
                arcCenter: center,
                radius: scale * length,
                startAngle: (rotatedHeading - 1).toRadians(),
                endAngle: (rotatedHeading + 1).toRadians(),
                clockwise: true)
            let armPath = UIBezierPath()
            armPath.move(to: arcPath.currentPoint)
            armPath.addLine(to: center)
            armPath.addLine(to: arcPath.reversing().currentPoint)

            //armPath.stroke()
            armPath.fill(with: .normal, alpha: CGFloat(count - index) / CGFloat(count))
        }
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
