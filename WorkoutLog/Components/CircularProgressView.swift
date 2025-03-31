//
//  CircularProgressView.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/31/25.
//

import UIKit

class CircularProgressView: UIView {
    private let progressLayer = CAShapeLayer()
    private let backgroundMask = CAShapeLayer()
    private let progressLabel = UILabel()

    var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = progress
            progressLabel.text = "\(Int(progress * 100))%"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2),
                                        radius: bounds.width / 2 - 10,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 1.5 * CGFloat.pi,
                                        clockwise: true)

        backgroundMask.path = circularPath.cgPath
        backgroundMask.strokeColor = UIColor.lightGray.cgColor
        backgroundMask.lineWidth = 8
        backgroundMask.fillColor = UIColor.clear.cgColor
        layer.addSublayer(backgroundMask)

        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineWidth = 8
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = progress
        layer.addSublayer(progressLayer)

        progressLabel.frame = bounds
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont.boldSystemFont(ofSize: 16)
        addSubview(progressLabel)
    }
}
