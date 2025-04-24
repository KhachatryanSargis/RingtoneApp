//
//  RingtoneAppError.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 21.02.25.
//

public enum RingtoneAppError: Error {
    case categoriesRepository(RingtoneCategoriesRepositoryError)
    case audioRepository(RingtoneAudioRepositoryError)
    case dataEditor(RingtoneDataEditorError)
}
