final class RingtoneSettingsCell: NiblessCollectionViewCell {
    // MARK: - Properties
    static let reuseID = "RingtoneSettingsCell"
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .theme.headline
        label.textColor = .theme.label
        return label
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroundColor()
        constructHierarchy()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setLayerCornerRadius()
    }
    
    func setImage(_ image: UIImage, andTitle title: String) {
        imageView.image = image
        titleLabel.text = title
    }
}

// MARK: - Style
extension RingtoneSettingsCell {
    private func setBackgroundColor() {
        backgroundColor = .theme.secondaryBackground
    }
    
    private func setLayerCornerRadius() {
        layer.cornerRadius = 8
    }
}

// MARK: - Hierarchy
extension RingtoneSettingsCell {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        stackView.addArrangedSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
        stackView.addArrangedSubview(titleLabel)
    }
}
