public protocol RingtoneFavoriteAudiosMediator {
    // MARK: - Properties
    var favoriteAudiosPublisher: AnyPublisher<[RingtoneAudio], Never> { get }
    
    // MARK: - Methods
    // Selection
    func enableFavoriteAudiosSelection()
    func disableFavoriteAudiosSelection()
    func toggleFavoriteAudioSelection(_ audio: RingtoneAudio)
    func selectAllFavoriteAudios()
    func deselectAllFavoriteAudios()
    // Favorite
    func changeAudioFavoriteStatus(_ audio: RingtoneAudio)
}