public enum RingtoneDataTrimmerError: Error {
    case failedToCreateReader(Error)
    case failedToAddReaderOutput
    case failedToCreateWriter(Error)
    case failedToAddWriterInput
    case exportSessionError(Error)
    case loadAudioTrackError(Error)
    case unexpected
}