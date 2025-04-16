//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.02.25.
//

import Foundation

public struct RingtoneAudio: Identifiable, Equatable, Hashable, Sendable {
    // MARK: - Properties
    public let id: String
    public let title: String
    public let desciption: String
    public let categoryID: String
    public let isCreated: Bool
    public let isPlaying: Bool
    public let isFavorite: Bool
    public let failedToImport: Bool
    public let failedToConvert: Bool
    public var isFailed: Bool { failedToImport || failedToConvert }
    public let isSelected: Bool?
    public let url: URL
    public let waveformURL: URL
    
    // MARK: - Methods
    public init(
        id: String,
        title: String,
        desciption: String,
        categoryID: String = "Other",
        isCreated: Bool = false,
        isPlaying: Bool = false,
        isLiked: Bool = false,
        isImporting: Bool = false,
        failedToImport: Bool = false,
        failedToConvert: Bool = false,
        isSelected: Bool? = nil,
        url: URL,
        waveformURL: URL
    ) {
        self.id = id
        self.title = title
        self.desciption = desciption
        self.categoryID = categoryID
        self.isCreated = isCreated
        self.isPlaying = isPlaying
        self.isFavorite = isLiked
        self.failedToImport = failedToImport
        self.failedToConvert = failedToConvert
        self.isSelected = isSelected
        self.url = url
        self.waveformURL = waveformURL
    }
    
    public func decodeWaveform() -> RingtoneAudioWaveform {
        do {
            let waveformData = try Data(contentsOf: waveformURL)
            
            return try JSONDecoder().decode(
                RingtoneAudioWaveform.self,
                from: waveformData
            )
        } catch {
            preconditionFailure("Waveform data could not be loaded.")
        }
    }
}

// MARK: - Like, Unlike
extension RingtoneAudio {
    public func liked() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            desciption: self.desciption,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: self.isPlaying,
            isLiked: true,
            failedToImport: self.failedToImport,
            failedToConvert: self.failedToConvert,
            isSelected: self.isSelected,
            url: self.url,
            waveformURL: self.waveformURL
        )
    }
    
    public func unliked() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            desciption: self.desciption,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: self.isPlaying,
            isLiked: false,
            failedToImport: self.failedToImport,
            failedToConvert: self.failedToConvert,
            isSelected: self.isSelected,
            url: self.url,
            waveformURL: self.waveformURL
        )
    }
}

// MARK: - Play, Pause
extension RingtoneAudio {
    public func played() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            desciption: self.desciption,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: true,
            isLiked: self.isFavorite,
            failedToImport: self.failedToImport,
            failedToConvert: self.failedToConvert,
            isSelected: self.isSelected,
            url: self.url,
            waveformURL: self.waveformURL
        )
    }
    
    public func paused() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            desciption: self.desciption,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: false,
            isLiked: self.isFavorite,
            failedToImport: self.failedToImport,
            failedToConvert: self.failedToConvert,
            isSelected: self.isSelected,
            url: self.url,
            waveformURL: self.waveformURL
        )
    }
}

// MARK: - Select, Deselect, No Selection
extension RingtoneAudio {
    public func selected() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            desciption: self.desciption,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: self.isPlaying,
            isLiked: self.isFavorite,
            failedToImport: self.failedToImport,
            failedToConvert: self.failedToConvert,
            isSelected: true,
            url: self.url,
            waveformURL: self.waveformURL
        )
    }
    
    public func deselected() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            desciption: self.desciption,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: self.isPlaying,
            isLiked: self.isFavorite,
            failedToImport: self.failedToImport,
            failedToConvert: self.failedToConvert,
            isSelected: false,
            url: self.url,
            waveformURL: self.waveformURL
        )
    }
    
    public func noSelection() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            desciption: self.desciption,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: self.isPlaying,
            isLiked: self.isFavorite,
            failedToImport: self.failedToImport,
            failedToConvert: self.failedToConvert,
            isSelected: nil,
            url: self.url,
            waveformURL: self.waveformURL
        )
    }
}

// MARK: - Empty
extension RingtoneAudio {
    public static var empty: RingtoneAudio {
        .init(
            id: "",
            title: "",
            desciption: "",
            categoryID: "",
            isCreated: false,
            isPlaying: false,
            isLiked: false,
            isImporting: false,
            failedToImport: false,
            failedToConvert: false,
            isSelected: nil,
            url: URL(string: "skh.com")!,
            waveformURL: URL(string: "skh.com")!
        )
    }
}

// MARK: - Failed
extension RingtoneAudio {
    public static func importFailed(item: RingtoneDataImporterFailedItem) -> RingtoneAudio {
        .init(
            id: item.id.uuidString,
            title: item.name,
            desciption: "\(item.error)",
            categoryID: "",
            isCreated: false,
            isPlaying: false,
            isLiked: false,
            isImporting: false,
            failedToImport: true,
            failedToConvert: false,
            isSelected: nil,
            url: URL(string: "skh.com")!,
            waveformURL: URL(string: "skh.com")!
        )
    }
    
    public static func conversionFailed(item: RingtoneDataConverterFailedItem) -> RingtoneAudio {
        .init(
            id: item.id.uuidString,
            title: item.name,
            desciption: "\(item.error)",
            categoryID: "",
            isCreated: false,
            isPlaying: false,
            isLiked: false,
            isImporting: false,
            failedToImport: false,
            failedToConvert: true,
            isSelected: nil,
            url: URL(string: "skh.com")!,
            waveformURL: URL(string: "skh.com")!
        )
    }
}
