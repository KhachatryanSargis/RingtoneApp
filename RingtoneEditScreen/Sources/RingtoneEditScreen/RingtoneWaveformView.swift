//
//  RingtoneWaveformView.swift
//  RingtoneEditScreen
//
//  Created by Sargis Khachatryan on 08.04.25.
//

import UIKit
import Accelerate
import RingtoneUIKit
import RingtoneKit

final class RingtoneWaveformView: NiblessView {
    // MARK: - Properties
    private var waveform: RingtoneAudioWaveform = .empty
    private var downsampledPoints: [CGFloat] = []
    private var lastWidth: CGFloat = 0
    
    // MARK: - Public API
    func setWaveform(_ waveform: RingtoneAudioWaveform) {
        self.waveform = waveform
        setNeedsDisplay()
    }
    
    override init() {
        super.init()
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        downsampledPoints = convertToPoints(waveform: waveform, width: rect.width)
        
        let midY = rect.height / 2
        let spacing: CGFloat = 2.0
        
        let path = UIBezierPath()
        path.lineWidth = 1.0
        
        var x: CGFloat = 0
        
        for point in downsampledPoints {
            let height = point * rect.height
            let yTop = midY - height / 2
            let yBottom = midY + height / 2
            
            path.move(to: CGPoint(x: x, y: yTop))
            path.addLine(to: CGPoint(x: x, y: yBottom))
            
            x += spacing
        }
        
        UIColor.theme.accent.setStroke()
        path.stroke()
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
