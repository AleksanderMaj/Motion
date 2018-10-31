//
//  GraphView.swift
//  MotionFramework
//
//  Created by Aleksander Maj on 26/10/2018.
//  Copyright © 2018 HTD. All rights reserved.
//

import UIKit
import Overture

class GraphView: UIView {
    
    var values = [CGFloat]() {
        didSet {
            setNeedsDisplay()
        }
    }
    let unit = CGFloat(4)

    override func draw(_ rect: CGRect) {
        drawAxes()
        drawGraph()
//        drawAccuracyCircle()
//        drawCourse()
    }

    private func drawAxes() {
        UIColor.lightGray.set()

        let xAxisPath = UIBezierPath()
        xAxisPath.move(to: CGPoint(x: layoutMargins.left, y: bounds.height - layoutMargins.bottom))
        xAxisPath.addLine(to: CGPoint(x: bounds.width - layoutMargins.right, y: bounds.height - layoutMargins.bottom))
        let xAxisEndPoint = xAxisPath.currentPoint
        xAxisPath.addLine(to: xAxisEndPoint.applying(CGAffineTransform(translationX: -10, y: -3)))
        xAxisPath.addLine(to: xAxisEndPoint.applying(CGAffineTransform(translationX: -10, y: 3)))
        xAxisPath.addLine(to: xAxisEndPoint)
        xAxisPath.lineCapStyle = .round
        xAxisPath.stroke()
        xAxisPath.fill()

        let yAxisPath = UIBezierPath()
        yAxisPath.move(to: CGPoint(x: layoutMargins.left, y: bounds.height - layoutMargins.bottom))
        yAxisPath.addLine(to: CGPoint(x: layoutMargins.left, y: layoutMargins.top))
        let yAxisEndPoint = yAxisPath.currentPoint
        yAxisPath.addLine(to: yAxisEndPoint.applying(CGAffineTransform(translationX: -3, y: 10)))
        yAxisPath.addLine(to: yAxisEndPoint.applying(CGAffineTransform(translationX: 3, y: 10)))
        yAxisPath.addLine(to: yAxisEndPoint)
        yAxisPath.lineCapStyle = .round
        yAxisPath.stroke()
        yAxisPath.fill()
    }

    private func drawGraph() {
        let size = CGSize(width: bounds.width - layoutMargins.left - layoutMargins.right,
                          height: bounds.height - layoutMargins.top - layoutMargins.bottom)
        let origin = CGPoint(x: layoutMargins.left, y: layoutMargins.top)
        let graphRect = CGRect(origin: origin, size: size)
        let ys = values
            .map { $0 * graphRect.height }

        let xs = Array(0 ..< ys.count)
            .map { CGFloat($0) }
            .map { $0 * unit }

        let points = zip(with: CGPoint.init)(xs, ys)
            .map { $0.applying(CGAffineTransform(translationX: origin.x, y: origin.y)) }

        let graphPath = UIBezierPath()
        points.first.map { graphPath.move(to: $0) }
        points.forEach { graphPath.addLine(to: $0) }
        graphPath.lineCapStyle = .round
        graphPath.lineJoinStyle = .round
        UIColor.red.set()

        graphPath.stroke()

    }

}
