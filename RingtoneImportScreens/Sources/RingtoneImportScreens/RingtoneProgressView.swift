//
//  CircularProgressView.swift
//  RingtoneImportScreens
//
//  Created by Sargis Khachatryan on 27.03.25.
//

import UIKit
import RingtoneUIKit

final class RingtoneProgressView: NiblessView {
    // MARK: - Properties
    private var trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemGray4.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 20
        layer.lineCap = .round
        layer.strokeEnd = 1.0
        return layer
    }()
    
    private var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.theme.accent.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 20
        layer.lineCap = .round
        layer.strokeEnd = 0.0
        return layer
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.largeTitle
        label.textColor = .theme.label
        label.textAlignment = .center
        label.text = "🔍"
        label.backgroundColor = .theme.secondaryBackground
        label.clipsToBounds = true
        return label
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructHierarchy()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayers()
    }
    
    func setProgress(to progress: CGFloat) {
        self.progressLayer.strokeEnd = progress
        
        let percentage = Int(progress * 100)
        self.progressLabel.text = "\(percentage)%"
    }
    
    func startPulsingAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.2
        pulseAnimation.duration = 0.5
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.autoreverses = true
        progressLabel.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    func stopPulsingAnimation() {
        progressLabel.layer.removeAnimation(forKey: "pulse")
    }
}

// MARK: - Hierarchy
extension RingtoneProgressView {
    private func configureLayers() {
        let circularPath = createCircularPath()
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
        
        progressLabel.layer.cornerRadius = progressLabel.bounds.width / 2
    }
    
    private func createCircularPath() -> UIBezierPath {
        let radius = (min(bounds.width, bounds.height) - 20) / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        return UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
            clockwise: true
        )
    }
    
    private func constructHierarchy() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
        
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            progressLabel.heightAnchor.constraint(equalTo: progressLabel.widthAnchor),
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
