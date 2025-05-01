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
    
    public func updatePlaybackProgress(from start: CGFloat, to end: CGFloat, current: CGFloat) {
        guard start < end, current >= 0, current <= 1 else { return }
        
        let playbackStartX = start * bounds.width
        let playbackEndX = end * bounds.width
        let playbackRangeWidth = playbackEndX - playbackStartX
        let playedWidth = playbackRangeWidth * current
        
        // When the offset changes or playback progress is 0, animated is false.
        let originXFormatted = String(format: "%.2f", playbackMaskLayer.frame.origin.x)
        let newOriginXFormatted = String(format: "%.2f", playbackStartX)
        let animated = current != 0 && originXFormatted == newOriginXFormatted
        
        setPlaybackMaskLayerFrame(
            offset: playbackStartX,
            width: playedWidth,
            animated: animated
        )
        
        // Removing playback mask layer when playback finishes.
        if current == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                
                self.setPlaybackMaskLayerFrame(
                    offset: nil,
                    width: nil,
                    animated: false
                )
            }
        }
    }
}

public final class RingtoneWaveformView: NiblessView {
    private let waveformShapeLayer = CAShapeLayer()
    private let playbackShapeLayer = CAShapeLayer()
    private let playbackMaskLayer = CALayer()
    
    private var waveform: RingtoneAudioWaveform = .empty
    
    private var downsampledPoints: [CGFloat] = []
    
    // MARK: - Methods
    public override init() {
        super.init()
        backgroundColor = .clear
        configureLayers()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        resizeLayers()
    }
    
    private func resizeLayers() {
        waveformShapeLayer.frame = bounds
        playbackShapeLayer.frame = bounds
        playbackMaskLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: playbackMaskLayer.bounds.width,
            height: bounds.height
        )
    }
    
    private func configureLayers() {
        waveformShapeLayer.strokeColor = UIColor.theme.accent.cgColor
        waveformShapeLayer.fillColor = UIColor.clear.cgColor
        waveformShapeLayer.lineWidth = 1.0
        layer.addSublayer(waveformShapeLayer)
        
        playbackShapeLayer.strokeColor = UIColor.theme.red.cgColor
        playbackShapeLayer.fillColor = UIColor.clear.cgColor
        playbackShapeLayer.lineWidth = 1.0
        
        playbackMaskLayer.backgroundColor = UIColor.black.cgColor
        playbackShapeLayer.mask = playbackMaskLayer
        
        layer.addSublayer(playbackShapeLayer)
    }
    
    private func updateWaveformPath(animated: Bool = false) {
        let path = createWaveformPath(points: downsampledPoints, in: bounds).cgPath
        
        if animated {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = waveformShapeLayer.path ?? path
            animation.toValue = path
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            
            waveformShapeLayer.add(animation, forKey: "path")
            playbackShapeLayer.add(animation, forKey: "path")
        }
        
        waveformShapeLayer.path = path
        playbackShapeLayer.path = path
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
    
    private func setPlaybackMaskLayerFrame(offset: CGFloat?, width: CGFloat?, animated: Bool) {
        let change = { [weak self] in
            guard let self = self else { return }
            
            let offset = offset ?? self.playbackMaskLayer.frame.origin.x
            let width = width ?? 0
            
            self.playbackMaskLayer.frame = CGRect(
                x: offset,
                y: 0,
                width: width,
                height: self.bounds.height
            )
        }
        
        if animated {
            let animator = UIViewPropertyAnimator(duration: 0.1, curve: .linear) {
                change()
            }
            
            animator.startAnimation()
        } else {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            
            change()
            
            CATransaction.commit()
        }
    }
}
