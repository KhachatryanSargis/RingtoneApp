public protocol RingtoneAudioImportResponder {
    // MARK: - Properties
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var imported: AnyPublisher<[RingtoneAudio], Never> { get }
    
    // MARK: - Methods
    func retryAll()
    func retryByID(_ id: String)
    func clearAll()
    func clearByID(_ id: String)
}