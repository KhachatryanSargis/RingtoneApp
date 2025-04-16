//
//  RingtoneDataConverterCompleteItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 14.03.25.
//

import Foundation

struct RingtoneDataConverterCompleteItem {
    var id: UUID { return souce.id }
    var name: String { return souce.suggestedName }
    let description: String
    let souce: RingtoneDataConverterSouce
    let url: URL
    let waveformURL: URL
}
