//
//  TimeInterval.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 24.04.25.
//

import Foundation

extension TimeInterval {
    func formatted() -> String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        let milliseconds = Int((self - floor(self)) * 1000)
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
        } else {
            return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
        }
    }
    
    func shortFormatted() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = self >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: self) ?? "00:00"
    }
}
