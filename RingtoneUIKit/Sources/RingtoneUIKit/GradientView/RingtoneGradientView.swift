//
//  RingtoneGradientView.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 19.04.25.
//

import UIKit

public final class RingtoneGradientView: NiblessView {
    // MARK: - Properties
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    private let color: UIColor
    
    // MARK: - Methods
    public init(color: UIColor) {
        self.color = color
        super.init()
        isUserInteractionEnabled = false
        setGradientColors()
    }
    
    // MARK: - Color Theme Change
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)
        else { return }
        
        setGradientColors()
    }
    
    private func setGradientColors() {
        let transparentColor = color.withAlphaComponent(0).cgColor
        
        gradientLayer.colors = [
            transparentColor,
            color.cgColor,
            color.cgColor,
            transparentColor
        ]
        
        gradientLayer.locations = [0.0, 0.1, 0.9, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
}
