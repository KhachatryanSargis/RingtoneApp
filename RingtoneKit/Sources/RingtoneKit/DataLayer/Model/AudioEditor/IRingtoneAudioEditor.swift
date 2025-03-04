public protocol IRingtoneAudioEditor {
    func convertToAudioRingtone(_ url: URL) -> AnyPublisher<RingtoneAudio, RingtoneAudioEditorError>
}