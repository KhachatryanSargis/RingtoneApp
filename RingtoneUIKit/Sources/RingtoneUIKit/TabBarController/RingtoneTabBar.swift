//
//  RingtoneTabBar.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit

internal final class RingtoneTabBar: NiblessTabBar {
    // MARK: - Methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setBlurEffect()
    }
}

// MARK: - Style
extension RingtoneTabBar {
    private func setBlurEffect() {
        if let existingBlurView = subviews.first(where: { $0 is UIVisualEffectView }) {
            existingBlurView.removeFromSuperview()
        }
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        insertSubview(blurView, at: 0)
    }
}
