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
    public let pause = UIImage(systemName: "pause.circle")!.withConfiguration(configuration)
    public let like = UIImage(systemName: "heart")!
    public let liked = UIImage(systemName: "heart.fill")!
    public let edit = UIImage(systemName: "gearshape")!
    public let use = UIImage(systemName: "square.and.arrow.up")!
    
    // MARK: - RingtoneDiscoverViewContrller
    public let discover = UIImage(systemName: "waveform.badge.magnifyingglass")!
    
    // MARK: - RingtoneFavoritesViewContrller
    public let favorites = UIImage(systemName: "heart.square")!
    
    // MARK: - RingtoneCreatedViewContrller
    public let myRingtones = UIImage(systemName: "music.note.house")
    
    // MARK: - RingtoneCreatedEmptyCell
    public let `import` = UIImage(systemName: "square.and.arrow.down")!.withConfiguration(configuration)
}
