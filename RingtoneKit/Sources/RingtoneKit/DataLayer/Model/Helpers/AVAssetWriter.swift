//
//  AVAssetWriter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.05.25.
//

import AVFoundation

extension AVAssetWriter {
    static func settings(sampleRate: Double, channelCount: Int) -> [String: Any] {
        [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channelCount,
            AVEncoderBitRateKey: 192_000
        ]
    }
}
