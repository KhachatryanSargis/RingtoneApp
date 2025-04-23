public enum RingtoneEditViewModelState {
    case editing
    case isLoading
    case finished
    case failed(RingtoneAppError)
}