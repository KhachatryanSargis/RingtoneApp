//
//  RingtoneDataConverterFailedItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 14.03.25.
//

import Foundation

public struct RingtoneDataConverterFailedItem {
    var id: UUID { return souce.id }
    var name: String { return souce.suggestedName }
    let souce: RingtoneDataConverterSouce
    let error: RingtoneDataConverterError
}
