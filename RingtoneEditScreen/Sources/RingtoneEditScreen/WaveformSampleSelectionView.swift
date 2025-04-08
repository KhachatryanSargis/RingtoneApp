final class WaveformSampleSelectionView: NiblessView {
    // MARK: - Porperites
    private let waveFormView: FDWaveformView = {
        let view = FDWaveformView()
        view.isUserInteractionEnabled = false
        view.wavesColor = .theme.accent
        return view
    }()
    
    private let audio: RingtoneAudio
    
    // MARK: - Methods
    init(audio: RingtoneAudio) {
        self.audio = audio
        super.init()
    }
}
