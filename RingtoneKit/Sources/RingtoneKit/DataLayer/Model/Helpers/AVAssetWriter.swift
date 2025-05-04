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
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channelCount,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsNonInterleaved: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: true
        ]
    }
}
