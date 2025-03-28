final class CircularProgressView: NiblessView {
    // MARK: - Properties
    var progress: CGFloat = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    var lineWidth: CGFloat = 10 {
        didSet {
            backgroundLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            trackLayer.lineWidth = lineWidth
        }
    }
    
    private var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.theme.secondaryBackground.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 0
        return layer
    }()
    
    private var trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.theme.background.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 20
        layer.lineCap = .round
        layer.strokeEnd = 1.0
        return layer
    }()
    
    private var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.theme.accent.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 20
        layer.lineCap = .round
        layer.strokeEnd = 0.0
        return layer
    }()
    
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.largeTitle
        label.textColor = .theme.label
        label.textAlignment = .center
        label.text = "0%"
        label.backgroundColor = .theme.secondaryBackground
        label.clipsToBounds = true
        return label
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
        layer.addSublayer(backgroundLayer)
        
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            progressLabel.heightAnchor.constraint(equalTo: progressLabel.widthAnchor),
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
            clockwise: true
        )
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
        backgroundLayer.path = circularPath.cgPath
        
        progressLabel.layer.cornerRadius = progressLabel.bounds.width / 2
    }
    
    // Update the progress based on the progress value
    private func updateProgress() {
        progressLayer.strokeEnd = progress
        updateLabel()
    }
    
    // Update the label with the percentage text
    private func updateLabel() {
        let percentage = Int(progress * 100)
        progressLabel.text = "\(percentage)%"
    }
    
    // Animate progress change
    func animateProgress(to progress: CGFloat, duration: CFTimeInterval = 1.0) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = progress
        animation.duration = duration
        progressLayer.add(animation, forKey: "progressAnimation")
        
        self.progress = progress
    }
}
