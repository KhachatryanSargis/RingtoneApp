//
//  RingtoneWaveformView.swift
//  RingtoneEditScreen
//
//  Created by Sargis Khachatryan on 08.04.25.
//

import UIKit
import Accelerate
import RingtoneKit

// MARK: - Public API
extension RingtoneWaveformView {
    public func setWaveform(_ waveform: RingtoneAudioWaveform, animated: Bool) {
        self.waveform = waveform
        downsampledPoints = convertToPoints(waveform: waveform, width: bounds.width)
        updateWaveformPath(animated: animated)
    }
}

public final class RingtoneWaveformView: NiblessView {
    // MARK: - Properties
    public override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    private var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }
    
    private var waveform: RingtoneAudioWaveform = .empty
    
    private var downsampledPoints: [CGFloat] = []
    
    // MARK: - Methods
    public override init() {
        super.init()
        backgroundColor = .clear
        configureLayer()
    }
    
    private func configureLayer() {
        shapeLayer.strokeColor = UIColor.theme.accent.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1.0
    }
    
    private func updateWaveformPath(animated: Bool = false) {
        let path = createWaveformPath(points: downsampledPoints, in: bounds).cgPath
        
        if animated {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = shapeLayer.path ?? path
            animation.toValue = path
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            shapeLayer.add(animation, forKey: "path")
        }
        
        shapeLayer.path = path
    }
    
    private func createWaveformPath(points: [CGFloat], in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let midY = rect.height / 2
        let spacing = rect.width / CGFloat(max(points.count - 1, 1))
        var x: CGFloat = 0
        
        for point in points {
            let height = point * rect.height
            let yTop = midY - height / 2
            let yBottom = midY + height / 2
            
            path.move(to: CGPoint(x: x, y: yTop))
            path.addLine(to: CGPoint(x: x, y: yBottom))
            
            x += spacing
        }
        
        return path
    }
    
    private func convertToPoints(waveform: RingtoneAudioWaveform, width: CGFloat) -> [CGFloat] {
        let sampleCount = waveform.count
        guard sampleCount > 0 else { return [] }
        
        let pixelCount = Int(width / 2)
        guard pixelCount > 0 else { return [] }
        
        let samplesPerPixel = max(sampleCount / pixelCount, 1)
        
        var absSamples = [Float](repeating: 0, count: sampleCount)
        
        vDSP_vabs(waveform.samples, 1, &absSamples, 1, vDSP_Length(sampleCount))
        
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)
        let downsampledCount = sampleCount / samplesPerPixel
        
        var downsampled = [Float](repeating: 0, count: downsampledCount)
        
        vDSP_desamp(
            absSamples,
            vDSP_Stride(samplesPerPixel),
            filter,
            &downsampled,
            vDSP_Length(downsampledCount),
            vDSP_Length(samplesPerPixel)
        )
        
        return downsampled.map { CGFloat($0) }
    }
}
