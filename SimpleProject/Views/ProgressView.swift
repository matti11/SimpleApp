//
//  ProgressView.swift
//  SimpleProject
//
//  Created by Mateusz Wojnar on 14/11/2020.
//  Copyright © 2020 Mateusz Wojnar. All rights reserved.
//

import Foundation
import UIKit

public class ProgressView: UIView {

    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()

    private var config = ProgressViewConfig()

    private var radius: CGFloat {
        return bounds.height/2
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }

    private func configure() {
        backgroundColor = UIColor.clear
    }

    private func circlePath() -> UIBezierPath {
        let startAngle = CGFloat(-Double.pi/2)
        let endAngle = startAngle + CGFloat(Double.pi * 2)

        return UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }

    private func createIndicatorBackground(){
        backgroundLayer.frame = bounds
        backgroundLayer.lineWidth = config.backgroundLineWidth
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.path = circlePath().cgPath
        backgroundLayer.strokeEnd = 1
        layer.addSublayer(backgroundLayer)
    }

    private func createIndicatorLayer(){
        foregroundLayer.frame = bounds
        foregroundLayer.lineWidth = config.foregroundLineWidth
        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.path = circlePath().cgPath
        layer.addSublayer(foregroundLayer)
    }

    private func setupOnLoaderLayer(){
        foregroundLayer.strokeColor = config.layerForegroundColor.cgColor
        backgroundLayer.strokeColor = config.layerBackgroundColor.cgColor
        foregroundLayer.strokeEnd = 0.25
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        createIndicatorBackground()
        createIndicatorLayer()
        setupView()
    }

    private func setupView(){
         setupOnLoaderLayer()
         runLoaderAnimation()
    }

    private func runLoaderAnimation() {
        foregroundLayer.add(rotationAnimation, forKey: "transform.rotation")
    }


    let rotationAnimation: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 4
        animation.repeatCount = MAXFLOAT
        animation.speed = 5

        return animation
    }()
}
