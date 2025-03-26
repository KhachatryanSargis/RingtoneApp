//
//  IRingtoneDataConverterCompatibleItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.03.25.
//

import Foundation

protocol IRingtoneDataConverterCompatibleItem {
    var id: UUID { get }
    var name: String { get }
    var url: URL { get }
}
