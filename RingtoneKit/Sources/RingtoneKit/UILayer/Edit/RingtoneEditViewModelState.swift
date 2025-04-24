//
//  RingtoneEditViewModelState.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 23.04.25.
//

public enum RingtoneEditViewModelState {
    case isEditing
    case isLoading
    case finished
    case failed(RingtoneAppError)
}
