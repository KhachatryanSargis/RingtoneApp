final class RingtoneDiscoverAudioCell: NiblessCollectionViewCell {
    // MARK: - Properties
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .theme.secondaryBackground
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowColor = UIColor.theme.shadowColor.cgColor
        layer.shadowOffset = .init(width: 0, height: 1)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.cornerRadius = 4
    }
}