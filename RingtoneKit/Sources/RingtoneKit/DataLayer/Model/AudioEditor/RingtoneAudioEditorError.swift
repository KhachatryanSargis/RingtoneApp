public enum RingtoneAudioEditorError: Error, Sendable {
    case unsupportedFileType
    case failedToCreateExportSession
    case exportSession(RingtoneAssetExportSessionError)
}