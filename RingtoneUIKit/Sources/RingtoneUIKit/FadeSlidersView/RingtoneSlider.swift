//
//  RingtoneSlider.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 26.04.25.
//

import UIKit

final class RingtoneSlider: UISlider {
    // MARK: - Properties
    private let direction: RingtoneSliderDirection
    
    // MARK: - Methods
    public init(direction: RingtoneSliderDirection, frame: CGRect = .zero) {
        self.direction = direction
        super.init(frame: frame)
        
        setThumbImage(.theme.fadeOut, for: .normal)
        setMinimumTrackImage(.theme.fadeIn, for: .normal)
        
        switch direction {
        case .backward:
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        case .forward:
            transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customHeight: CGFloat = 10
        var newRect = super.trackRect(forBounds: bounds)
        newRect.origin.y = bounds.midY - customHeight / 2
        newRect.size.height = customHeight
        return newRect
    }
}
