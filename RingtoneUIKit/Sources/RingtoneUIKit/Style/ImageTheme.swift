//
//  File.swift
//  ChallengeUIKit
//
//  Created by Sargis Khachatryan on 10.02.25.
//

import UIKit

extension UIImage {
    @MainActor public static let theme = ImageTheme()
}

@MainActor
public struct ImageTheme {
    private static let configuration = UIImage.SymbolConfiguration(scale: .large)
    
    // MARK: - RingtoneDiscoverCategoryCell
    public let icon = UIImage(systemName: "waveform")!.withConfiguration(configuration)
    
    // MARK: - RingtoneDiscoverAudioCell
    public let play = UIImage(systemName: "play.circle.fill")!.withConfiguration(configuration)
    public let puase = UIImage(systemName: "pause.circle")!.withConfiguration(configuration)
    public let edit = UIImage(systemName: "gearshape")!.withConfiguration(configuration)
    public let unlike = UIImage(systemName: "heart.slash.circle.fill")!.withConfiguration(configuration)
    public let like = UIImage(systemName: "heart.circle.fill")!.withConfiguration(configuration)
}
