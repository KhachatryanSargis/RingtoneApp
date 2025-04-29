//
//  File.swift
//  ChallengeUIKit
//
//  Created by Sargis Khachatryan on 09.02.25.
//

import UIKit

extension UIFont {
    public static let theme = FontTheme()
}

@MainActor
public struct FontTheme {
    public let headline = UIFont.preferredFont(forTextStyle: .headline)
    public let subheadline = UIFont.preferredFont(forTextStyle: .subheadline)
    public let title1 = UIFont.preferredFont(forTextStyle: .title1)
    public let title2 = UIFont.preferredFont(forTextStyle: .title2)
    public let title3 = UIFont.preferredFont(forTextStyle: .title3)
    public let largeTitle = UIFont.preferredFont(forTextStyle: .largeTitle)
}

extension UIFont {
    public func bold() -> UIFont {
        if let descriptor = self.fontDescriptor.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: self.pointSize)
        }
        return self
    }
    
    public func monospace() -> UIFont {
        if let descriptor = self.fontDescriptor.withSymbolicTraits(.traitMonoSpace) {
            return UIFont(descriptor: descriptor, size: self.pointSize)
        }
        return self
    }
}
