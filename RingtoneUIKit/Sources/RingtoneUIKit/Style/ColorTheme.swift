//
//  ColorTheme.swift
//  ChallengeUIKit
//
//  Created by Sargis Khachatryan on 07.02.25.
//

import UIKit

extension UIColor {
    public static let theme = ColorTheme()
}

@MainActor
public struct ColorTheme {
    public struct Color: Sendable, Equatable {
        public let lightHex: String
        public let darkHex: String
        public var uiColor: UIColor {
            UIColor { colltion in
                switch colltion.userInterfaceStyle {
                case .dark:
                    return UIColor(hex: darkHex)
                default:
                    return UIColor(hex: lightHex)
                }
            }
        }
    }
    
    public let background = UIColor(named: "AppBackground")!
    public let secondayBackground = UIColor(named: "AppSecondaryBackground")!
    public let shadow = UIColor(named: "AppShadow")!
    public let label = UIColor.label
    public let secondaryLabel = UIColor.secondaryLabel
    public let green = UIColor.systemGreen
    public let orange = UIColor.systemOrange
    public let accent = UIColor(named: "AccentColor")!
}

// MARK: - HEX
extension UIColor {
    public var hex: String {
        let components = cgColor.components ?? [0, 0, 0, 1]
        
        let r = components[0] * 255
        let g = components[1] * 255
        let b = components[2] * 255
        
        return String(format: "#%02X%02X%02X", Int(r), Int(g), Int(b))
    }
    
    convenience public init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        guard hexSanitized.count == 6, let hexValue = Int(hexSanitized, radix: 16) else {
            self.init(white: 1, alpha: 0)
            return
        }
        
        let red = CGFloat((hexValue >> 16) & 0xFF) / 255.0
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hexValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - Inverse
extension UIColor {
    public var inverse: UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let invertedRed = 1.0 - red
        let invertedGreen = 1.0 - green
        let invertedBlue = 1.0 - blue
        
        return UIColor(
            red: invertedRed,
            green: invertedGreen,
            blue: invertedBlue,
            alpha: alpha
        )
    }
}

// MARK: contrast
extension UIColor {
    public var contrast: UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let luminance = (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
        
        return luminance > 0.5 ? UIColor.black : UIColor.white
    }
}
